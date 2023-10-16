#!/bin/bash

# 引数からURLを取得
url="$1"

# domains.jsonからドメインとトークンのペアを取得
domain=$(echo "$url" | awk -F/ '{print $3}')
echo $domain
token=$(jq -r --arg domain "$domain" '.[] | select(.domain == $domain) | .token' domains.json)

# ドメインとトークンが見つからなかった場合のエラーチェック
if [ -z "$domain" ] || [ -z "$token" ]; then
  echo "ドメインとトークンのペアが見つかりませんでした。"
  exit 1
fi

# クリップIDを取得
clip_id=$(echo "$url" | awk -F/ '{print $5}')

echo クリップID $clip_id

# APIリクエストを実行し、結果を変数に格納
files=$(curl "https://$domain/api/clips/notes" \
  -H 'content-type: application/json' \
  --data-raw "{\"clipId\":\"$clip_id\",\"limit\":100,\"i\":\""$token"\"}" \
  --compressed -s | jq -r -c '.[].files[] | select(.url) | {name, url}')

# 今日の年月日（yyMMdd）を取得
date=$(date +"%y%m%d")

# 出力ディレクトリを作成
output_dir="./${domain}_${date}"
mkdir -p "$output_dir"

# ループで各ファイルをダウンロード
echo "$files" | while read -r file; do
   echo $file
    name=$(echo "$file" | jq -r '.name')
    url=$(echo "$file" | jq -r '.url')
    # echo "ダウンロード中: $name URL: $url"
    
    # ファイルをダウンロードして指定ディレクトリに保存
    wget -q -O "$output_dir/$name" "$url"
done

echo "ダウンロードが完了しました。ファイルは $output_dir ディレクトリに保存されました。"