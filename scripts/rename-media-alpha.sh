#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

folders=(Singapore arizona bali seattle thailand abu-dhabi food music paintings)

is_media() {
  local f="$1"
  shopt -s nocasematch
  [[ "$f" =~ \.(jpg|jpeg|png|webp|gif|bmp|svg|mp4|mov|m4v)$ ]]
}

to_alpha() {
  local n=$1
  local s=""
  local rem
  while (( n > 0 )); do
    rem=$(( (n - 1) % 26 ))
    s="$(printf "\\$(printf %o $((65 + rem)))")$s"
    n=$(( (n - 1) / 26 ))
  done
  printf '%s' "$s"
}

for dir in "${folders[@]}"; do
  [[ -d "$dir" ]] || continue

  media_files=()
  while IFS= read -r path; do
    base="${path##*/}"
    if is_media "$base"; then
      media_files+=("$path")
    fi
  done < <(find "$dir" -maxdepth 1 -type f -print | LC_ALL=C sort)

  i=1
  for old in "${media_files[@]}"; do
    tmp="$dir/__tmp_rename_${i}__"
    mv "$old" "$tmp"
    i=$((i + 1))
  done

  idx=1
  for src in "${media_files[@]}"; do
    src_base="${src##*/}"
    src_ext="${src_base##*.}"
    alpha="$(to_alpha "$idx")"
    tmp="$dir/__tmp_rename_${idx}__"
    new="$dir/${alpha}.${src_ext}"
    mv "$tmp" "$new"
    idx=$((idx + 1))
  done

  echo "Renamed $dir (${#media_files[@]} files)"
done

echo "Done. Run ./scripts/generate-media-manifest.sh next."
