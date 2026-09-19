#!/bin/bash
# 发布行程页（仓库自包含版，任何电脑可用）
# 用法: bash publish.sh "更新说明"
# 依赖: git, python3, (可选) Edge/Chrome 用于重新生成 PDF
set -e
MSG="${1:-行程页更新}"
cd "$(dirname "$0")"

# 1. 重新打 zip（手机下载解压即得 trip.html，扁平结构）
python - <<'EOF'
import zipfile
with zipfile.ZipFile('travel-plan.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    z.write('trip.html')
print('zip ok')
EOF

# 2. 重新生成 PDF（找不到浏览器就跳过，不影响 html/zip 发布）
BROWSER=""
for b in \
  "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
  "/c/Program Files/Microsoft/Edge/Application/msedge.exe" \
  "/c/Program Files/Google/Chrome/Application/chrome.exe" \
  "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
  chromium google-chrome-stable google-chrome; do
  if [ -f "$b" ] || command -v "$b" >/dev/null 2>&1; then BROWSER="$b"; break; fi
done

if [ -n "$BROWSER" ]; then
  if command -v cygpath >/dev/null 2>&1; then
    PDFOUT=$(cygpath -w "$PWD/trip.pdf"); PAGEURL="file:///$(cygpath -m "$PWD")/trip.html"; TMPD="$TEMP"
  else
    PDFOUT="$PWD/trip.pdf"; PAGEURL="file://$PWD/trip.html"; TMPD="${TMPDIR:-/tmp}"
  fi
  OLD=$(python -c "import os;print(int(os.path.getmtime('trip.pdf')) if os.path.exists('trip.pdf') else 0)")
  "$BROWSER" --headless=new --disable-gpu --user-data-dir="$TMPD/edge_pdf_profile" \
    --no-pdf-header-footer --print-to-pdf="$PDFOUT" "$PAGEURL" &
  for i in $(seq 1 40); do
    NEW=$(python -c "import os;print(int(os.path.getmtime('trip.pdf')) if os.path.exists('trip.pdf') else 0)")
    [ "$NEW" -gt "$OLD" ] && break
    sleep 1
  done
  NEW=$(python -c "import os;print(int(os.path.getmtime('trip.pdf')) if os.path.exists('trip.pdf') else 0)")
  if [ "$NEW" -gt "$OLD" ]; then echo "pdf ok ($(stat -c %s trip.pdf 2>/dev/null || wc -c < trip.pdf) bytes)"; else echo "!! PDF 生成失败，本次发布将不含新 PDF"; fi
else
  echo "!! 未找到 Edge/Chrome，跳过 PDF 重新生成"
fi

# 3. 提交并推送（gitee 为主仓库，github 供 jsdelivr CDN 使用）
git add -A
git commit -m "$MSG" || echo "内容无变化"
git push gitee main && echo "gitee ok" || echo "!! gitee 推送失败"
git push github main && echo "github ok" || echo "!! github 推送失败（PDF 直链将保持旧版，需补推）"

# 4. 清 jsdelivr 缓存，直链立即生效
curl -s --max-time 20 "https://purge.jsdelivr.net/gh/UncleJokerly/trip-plan@main/trip.pdf" > /dev/null || true
curl -s --max-time 20 "https://purge.jsdelivr.net/gh/UncleJokerly/trip-plan@main/trip.html" > /dev/null || true

echo "发布完成"
