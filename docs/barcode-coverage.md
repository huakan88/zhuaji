# 条码数据源实测（2026-10-15）

肉垫本 2.12 按这个顺序查，查到就停，并把结果存在本机设置里（不新增数据表）：

1. 本机缓存
2. [Open Pet Food Facts](https://world.openpetfoodfacts.org/api/v2/product/)
3. [Open Food Facts](https://world.openfoodfacts.org/api/v2/product/)
4. [Open Products Facts](https://world.openproductsfacts.org/api/v2/product/)
5. [UPCitemdb 试用接口](https://api.upcitemdb.com/prod/trial/lookup)

请求带 `User-Agent: PawPad/2.12 (com.maokangji.maokangji)`。没有登录，也没有绕过任何接口。

中国物品编码中心的公开查询是网页逐条查，企业接口要申请（400-7000-690）。没有免密钥、可写进应用的公开 API，所以没有接入。第三方需要 API key 的条码接口也没有调用。

## 五款真实条码

| 商品 | 条码 | Open Pet Food Facts | Open Food Facts | Open Products Facts | UPCitemdb |
| --- | --- | --- | --- | --- | --- |
| 皇家 Royal Canin Neutered Satiety Balance，12 kg | `3182550799669` | 命中。有品牌、名称、净含量、法语配料、粗蛋白 35%、粗脂肪 10%、粗纤维 9.2%、粗灰分 9.3%，以及正面图 | HTTP 404 | HTTP 404 | `total: 0` |
| 渴望 Orijen Original Cat，17 kg | `0064992280178` | 命中。有品牌、名称、净含量、英文配料、粗蛋白 40%、粗脂肪 20%、水分 10%，以及正面图 | HTTP 404 | HTTP 404 | `total: 0` |
| 希尔斯 Hill's Sterilised Cat young adult with duck，3 kg | `0052742035963` | 命中名称、品牌、净含量和正面图。没有配料，也没有成分表 | HTTP 404 | HTTP 404 | `total: 0` |
| 麦富迪 三文鱼双拼全价全期猫粮，2 kg | `6958862134620` | HTTP 404 | HTTP 404 | HTTP 404 | `total: 0` |
| 网易天成 浓汤红肉罐头金枪鱼鸡丝，85 克 × 12 | `6906628275179` | HTTP 404 | HTTP 404 | HTTP 404 | `total: 0` |

皇家、渴望、希尔斯的条码来自 Open Pet Food Facts 能打开的商品页。麦富迪和网易天成的条码来自公开的商品条码页面（厂商识别代码分别是 69588621 和 6906628）。网易这一条是罐头零食，不是干粮；公开页面上没有查到一款网易严选干粮的 EAN。

## 国产粮

上面两款 69 开头的国产商品，四个免密钥接口全部未命中。用中文品牌名在 Open Pet Food Facts 里搜索，麦富迪和网易严选也是 0 条。进口粮（皇家、渴望、希尔斯）可以查到名称和图片；希尔斯这一条没有配料和成分。国产粮要靠拍包装识别，或点选品牌，然后把条码记在手机里。
