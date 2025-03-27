import fsp from "fs/promises";
import fs from "fs";
import readline from "readline";
import path from "path";

const ARCH = process.argv[2] ?? "amd64";
const ROOT_DIR = `build/${ARCH}`;

const checkFileExists = async (filePath) => {
  try {
    await fsp.access(filePath);
    return true;
  } catch {
    return false;
  }
};

const getFilesInDir = async (dirPath, pattern) => {
  try {
    const files = await fsp.readdir(dirPath);
    return files.filter((file) => pattern.test(file)).sort();
  } catch {
    return [];
  }
};

const getVersionAndSha256 = async (pkgIdDir) => {
  const versionFile = path.join(pkgIdDir, "version");
  const sha256File = path.join(pkgIdDir, "SHA256SUMS");

  const versionExists = await checkFileExists(versionFile);
  const sha256Exists = await checkFileExists(sha256File);

  const version = versionExists
    ? (await fsp.readFile(versionFile, { encoding: "utf-8" })).trim()
    : null;
  const sha256sum = sha256Exists;

  return { version, sha256sum };
};
const getLastScreenFiles = (screenFiles) => {
  /** @type {Record<string,string>} */
  const groups = {};

  screenFiles.forEach((file) => {
    const match = file.match(/^screen(\d+)-\d+\.jpg$/);
    if (match) {
      const group = match[1];
      groups[group] = file;
    }
  });

  return Object.values(groups);
};
const generateStatistic = async (rootDir, pkgId, repo, arch) => {
  const pkgIdDir = path.join(rootDir, pkgId);
  if (!(await checkFileExists(pkgIdDir))) {
    return null;
  }
  const testsDir = path.join(pkgIdDir, "tests");

  const screenFiles = await getFilesInDir(testsDir, /^screen.*\.jpg$/);
  const testResults = getLastScreenFiles(screenFiles)
    .map((item) => `![${item}](./${pkgId}/tests/${item})`)
    .join(" ");

  const { version, sha256sum } = await getVersionAndSha256(pkgIdDir);

  return {
    id:pkgId,
    PKGID: `[${pkgId}](./${pkgId})`,
    ARCH: arch,
    VERSION: version || "N/A",
    TEST: testResults || "失败",
    REPO: repo,
    SHA256SUM: sha256sum ? `[SHA256SUM](./${pkgId}/SHA256SUMS)` : "N/A",
  };
};

const readIndex = async (filePath) => {
  const fileStream = fs.createReadStream(filePath);
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity,
  });

  const indexes = [];
  for await (const line of rl) {
    const chunks = line.split(",").map(x=>x?.trim());
    indexes.push({
      name: chunks[0],
      version: chunks[1],
      repo: chunks[2],
      url: chunks[3],
      filename: chunks[4],
    });
  }

  return indexes;
};
const formatPercentage = (value, max, decimalPlaces = 2) => {
  return ((value / (max || 1)) * 100).toFixed(decimalPlaces) + "%";
};

const main = async () => {
  const indexes = await readIndex(`${ROOT_DIR}/index.csv`);
  const stats = (
    await Promise.all(
      indexes.map((item) =>
        generateStatistic(ROOT_DIR, item.name, item.repo, ARCH),
      ),
    )
  ).filter((x) => x != null);
  // console.table(stats)
  const total = stats.length;
  const success = stats.reduce(
    (x, item) => x + (item.TEST != "失败" ? 1 : 0),
    0,
  );
  const fail = total - success;
  const indexTotal = indexes.length;

  const statMap = stats.reduce((obj, item) => {
    obj[item.id] = item;
    return obj;
  }, {});
  const repoStats = Object.values(
    indexes.reduce((obj, item) => {
      const stat = obj[item.repo] || {
        name: item.repo,
        index: 0,
        total: 0,
        success: 0,
      };
      stat.index++;
      const pkgStat = statMap[item.name];
      if (pkgStat) {
        stat.total++;
        if (pkgStat.TEST != "失败") {
          stat.success++;
        }
      }
      obj[item.repo] = stat;
      return obj;
    }, {}),
  );
  const markdown = [
    `# ${ARCH} - 构建统计`,
    "| 索引数  | 构建数 | 成功数 | 失败数  | 成功率  | 完成度  |",
    "|--------|--------|-------|---------| -------|-----|",
    `|${indexTotal}|${total}|${success} |${fail} | ${formatPercentage(success, total)}| ${formatPercentage(success, indexTotal)}|`,
    `## 仓库统计`,
    "| 仓库  | 索引数 |构建数| 成功数 | 失败数  | 成功率  | 完成度  |",
    "|--------|------|-----|-------|---------| -------|-----|",
    ...repoStats.map(
      (item) =>
        `|${item.name}|${item.index}|${item.total}|${item.success} |${item.total - item.success} | ${formatPercentage(item.success, item.total)}| ${formatPercentage(item.success, item.index)}|`,
    ),
    "## 详细结果",
    "| 包名   | 架构 |仓库| 版本    | 测试结果 | SHA256SUM |",
    "|-------|------|-----|----|---------|-----------|",
    ...stats.map(
      (stat) =>
        `| ${stat.PKGID} | ${stat.ARCH}  | ${stat.REPO} | ${stat.VERSION} | ${stat.TEST} | ${stat.SHA256SUM} |`,
    ),
  ];

  console.log(markdown.join("\n"));
};
await main();
