#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

collect_media() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo '[]'
    return
  fi

  find "$dir" -type f \
    | LC_ALL=C sort \
    | awk 'BEGIN{IGNORECASE=1} $0 ~ /\.(jpg|jpeg|png|webp|gif|bmp|svg|mp4|mov|m4v)$/ {print}' \
    | jq -R . \
    | jq -s .
}

singapore_json="$(collect_media "Singapore")"
arizona_json="$(collect_media "arizona")"
bali_json="$(collect_media "bali")"
seattle_json="$(collect_media "seattle")"
thailand_json="$(collect_media "thailand")"
abu_dhabi_json="$(collect_media "abu-dhabi")"
food_json="$(collect_media "food")"
music_json="$(collect_media "music")"
paintings_json="$(collect_media "paintings")"

jq -n \
  --argjson singapore "$singapore_json" \
  --argjson arizona "$arizona_json" \
  --argjson bali "$bali_json" \
  --argjson seattle "$seattle_json" \
  --argjson thailand "$thailand_json" \
  --argjson abu_dhabi "$abu_dhabi_json" \
  --argjson food "$food_json" \
  --argjson music "$music_json" \
  --argjson paintings "$paintings_json" \
  '{
    travel: {
      Singapore: $singapore,
      arizona: $arizona,
      bali: $bali,
      seattle: $seattle,
      thailand: $thailand,
      "abu-dhabi": $abu_dhabi
    },
    food: $food,
    music: $music,
    paintings: $paintings
  }' > media-manifest.json

echo "Updated media-manifest.json"
