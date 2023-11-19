const axios = require('axios');
const fs = require('fs');

// 引数からURLとfolderIdを取得
const url = process.argv[2];
const folderId = process.argv[3];

// ドメインとトークンをdomains.jsonから取得
const domain = new URL(url).hostname;
const domainsData = JSON.parse(fs.readFileSync('domains.json'));
const domainInfo = domainsData.find(item => item.domain === domain);

if (!domainInfo) {
  console.error('ドメインとトークンのペアが見つかりませんでした。');
  process.exit(1);
}

const token = domainInfo.token;

async function processLine(line) {
  console.log(line)
  const { name, id } = line;

  // ここで必要な処理を行う
  // 例えば、取得したnameとidを使って新しいHTTPリクエストを作成し、それを実行するなどの処理を実施できます

  // この例では、nameとidを表示するだけです
  console.log(`name: ${name}, id: ${id}`);

  try {
    const response = await axios.post(`https://${domain}/api/admin/emoji/add`, {
      name: name,
      category: null,
      aliases: [],
      license: null,
      isSensitive: false,
      localOnly: false,
      roleIdsThatCanBeUsedThisEmojiAsReaction: [],
      fileId: id,
      i: token,
    });

    console.log(`HTTPリクエスト成功: ${response.status}`);
  } catch (error) {
    console.error(`HTTPリクエストエラー: ${error}`);
  }
}

// メインの処理
(async () => {
  try {
    const response = await axios.post(url, {
      folderId,
      limit: 100,
      i: token,
    });

    const data = response.data;
    data.sort((a, b) => {
      if(!a.name) console.error(a)
      return a.name > b.name ? 1 : -1
    })
    if (Array.isArray(data)) {
      for (const item of data) {
        await processLine({ name: item.name.replace(/.*?_+/, "").replace(/\..*$/, ""), id: item.id });
      }
      // console.log(item)

    } else {
      console.error('レスポンスデータが配列ではありません。');
    }
  } catch (error) {
    console.error(`HTTPリクエストエラー: ${error}`);
  }
})();
