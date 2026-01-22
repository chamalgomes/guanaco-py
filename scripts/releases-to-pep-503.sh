#!/usr/bin/env bash
set -euo pipefail

OUT_ROOT="$1"
TAG_REGEX="$2"

if [ -z "$OUT_ROOT" ] || [ -z "$TAG_REGEX" ]; then
  echo "Usage: releases-to-pep-503.sh <output-root> <tag-regex>"
  exit 0
fi

RELEASES_FILE="all_releases.txt"
if [ ! -f "$RELEASES_FILE" ]; then
  echo "No releases data found, skipping"
  exit 0
fi

echo "Generating wheel index at $OUT_ROOT for tags matching $TAG_REGEX"
mkdir -p "$OUT_ROOT"

RELEASE_TAGS="$(jq -r '.[] | select(.tag_name | test("'"$TAG_REGEX"'")) | .tag_name' "$RELEASES_FILE" 2>/dev/null || true)"

if [ -z "$RELEASE_TAGS" ]; then
  echo "No matching releases."
  exit 0
fi

echo "Tags found:"
echo "$RELEASE_TAGS"

while read -r TAG; do
  ASSETS="$(jq -r --arg TAG "$TAG" '
    .[] | select(.tag_name == $TAG) |
    .assets[]? | select(.name | endswith(".whl")) |
    "\(.browser_download_url)|\(.name)"
  ' "$RELEASES_FILE" 2>/dev/null || true)"

  if [ -z "$ASSETS" ]; then
    echo "No wheels for $TAG"
    continue
  fi

  while IFS="|" read -r URL NAME; do
    echo "Processing wheel $NAME from $TAG"

    PACKAGE="$(echo "$NAME" | sed -E 's/-[0-9].*//')"

    PACKAGE_DIR="$OUT_ROOT/$PACKAGE"
    mkdir -p "$PACKAGE_DIR"

    WHEEL_PATH="$PACKAGE_DIR/$NAME"
    if [ ! -f "$WHEEL_PATH" ]; then
      echo "Downloading $NAME ..."
      curl -sSL "$URL" -o "$WHEEL_PATH"
    else
      echo "$NAME already exists, skipping download"
    fi

  done <<< "$ASSETS"
done <<< "$RELEASE_TAGS"

for PACKAGE_DIR in "$OUT_ROOT"/*/; do
  PKG="$(basename "$PACKAGE_DIR")"
  echo "Writing index for package $PKG"
  cat > "$PACKAGE_DIR/index.html" <<HTML
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Index of $PKG</title></head>
  <body>
    <h1>Index of $PKG</h1>
    <ul>
HTML

  for FILE in "$PACKAGE_DIR"*.whl; do
    F="$(basename "$FILE")"
    echo "      <li><a href=\"./$F\">$F</a></li>" >> "$PACKAGE_DIR/index.html"
  done

  cat >> "$PACKAGE_DIR/index.html" <<HTML
    </ul>
  </body>
</html>
HTML
done

echo "Done generating wheels index"
exit 0
