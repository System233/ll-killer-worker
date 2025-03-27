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
  const sha256sum = sha256Exists ? sha256File : null;

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
const generateStatistics = async (rootDir, arch) => {
  const pkgDirs = await fsp.readdir(rootDir, { withFileTypes: true });

  const stats = await Promise.all(
    pkgDirs
      .filter((x) => x.isDirectory() && !x.name.startsWith("."))
      .map(async (entry) => {
        const pkgId = entry.name;
        const pkgIdDir = path.join(rootDir, pkgId);
        const testsDir = path.join(pkgIdDir, "tests");

        const screenFiles = await getFilesInDir(testsDir, /^screen.*\.jpg$/);
        const testResults = getLastScreenFiles(screenFiles)
          .map((item) => `![${item}](./${pkgId}/tests/${item})`)
          .join(" ");

        const { version, sha256sum } = await getVersionAndSha256(pkgIdDir);

        return {
          PKGID: `[${pkgId}](./${pkgId})`,
          ARCH: arch,
          VERSION: version || "N/A",
          TEST: testResults || "失败",
          SHA256SUM: sha256sum ? `[SHA256SUM](${sha256sum})` : "N/A",
        };
      }),
  );

  return stats;
};

const countLines = async (filePath) => {
  const fileStream = fs.createReadStream(filePath);
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity,
  });

  let lineCount = 0;

  for await (const line of rl) {
    lineCount++;
  }

  return lineCount;
};
const formatPercentage = (value, decimalPlaces = 2) => {
  return (value * 100).toFixed(decimalPlaces) + "%";
};
const main = async () => {
  const stats = await generateStatistics(ROOT_DIR, ARCH);
  // console.table(stats)
  const total = stats.length;
  const success = stats.reduce(
    (x, item) => x + (item.TEST != "失败" ? 1 : 0),
    0,
  );
  const fail = total - success;
  const index = await countLines(`${ROOT_DIR}/index.csv`);
  const markdown = [
    `# ${ARCH} - 构建统计`,
    "| 索引数  | 构建数 | 成功数 | 失败数  | 完成度  |",
    "|--------|--------|-------|---------| -------|",
    `|${index}|${total}|${success} |${fail} | ${formatPercentage(success / index)}|`,
    "## 详细结果",
    "| 包名   | 架构 | 版本    | 测试结果 | SHA256SUM |",
    "|-------|------|---------|---------|-----------|",
    ...stats.map(
      (stat) =>
        `| ${stat.PKGID} | ${stat.ARCH} | ${stat.VERSION} | ${stat.TEST} | ${stat.SHA256SUM} |`,
    ),
  ];

  console.log(markdown.join("\n"));
};
await main();
