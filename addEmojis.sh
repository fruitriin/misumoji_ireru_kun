#!/bin/bash

# 引数からURLとfolderIdを取得
url="$1"
folderId="$2"

# domains.jsonからドメインとトークンのペアを取得
domain=$(echo "$url" | awk -F/ '{print $3}')
echo $domain
token=$(jq -r --arg domain "$domain" '.[] | select(.domain == $domain) | .token' domains.json)

# ドメインとトークンが見つからなかった場合のエラーチェック
if [ -z "$domain" ] || [ -z "$token" ]; then
  echo "ドメインとトークンのペアが見つかりませんでした。"
  exit 1
fi

# Curlコマンドを生成し実行
curl_result=$(curl "$url" \
  -H 'content-type: application/json' \
  --data-raw "{\"folderId\":\"$folderId\",\"limit\":100,\"i\":\"$token\"}" \
  --compressed -s | jq -c ".[] | {name: (.name | split(\".\")[0]), id}")

echo $curl_result

# jqを使って結果を行ごとに処理
echo "$curl_result" | while read -r line; do
  # 各行を処理

  # ドメインとトークンのペアからnameとidを取得
  name=$(echo "$line" | jq -r '.name')
  id=$(echo "$line" | jq -r '.id')

  # ここで必要な処理を行う
  # 例えば、取得したnameとidを使って新しいcurlリクエストを作成し、
  # それを実行するなどの処理を実施できます

  # この例では、nameとidを表示するだけです
  echo "name: $name, id: $id"
  
  curl 'https://'$domain'/api/admin/emoji/add' \
  -H 'content-type: application/json' \
  --data-raw '{
    "name": "'"${name}"'",
    "category": null,
    "aliases": [],
    "license": null,
    "isSensitive": false,
    "localOnly": false,
    "roleIdsThatCanBeUsedThisEmojiAsReaction": [],
    "fileId": "'"$id"'",
    "i": "'"${token}"'"
  }' \
  --request POST \
  --compressed
done