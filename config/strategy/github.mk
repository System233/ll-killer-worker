REPO?=
TAG?=latest
URL?=https://api.github.com/repos/$(REPO)/releases/$(TAG)
PATTERN?= \\.deb

TARGET_INDEX=$(INDEX)

$(TARGET_INDEX):
	@RESP=$$(curl -fsSL "$(URL)");\
	TAG_NAME=$$(printf "%s" "$$RESP" | jq -r '.tag_name');\
	ASSETS=$$(printf "%s" "$$RESP" | jq 'limit(1; .assets[] | select(.name | test("$(PATTERN)")))');\
	URL=$$(printf "%s" "$$ASSETS" | jq -r '.browser_download_url');\
	FILENAME=$$(printf "%s" "$$ASSETS" | jq -r '.name');\
	test -n "$$URL"&&echo "$(PKGID),$$TAG_NAME,$$CONFIG,$$URL,$$FILENAME"|tee "$@~"&&mv $@~ $@||echo "找不到匹配项:$(PKGID)"

INDEX_TARGET=$(TARGET_INDEX)
include config/strategy/base.mk