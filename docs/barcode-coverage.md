# 条码数据源实测（2026-10-15）

肉垫本 2.13 按这个顺序查，查到名称或品牌就停。结果存在本机设置里，不新增数据表。某一次请求失败时不把「没有这款」写进缓存，下次扫码会再试。单次请求 4 秒，整次查询 12 秒。

69 开头（或 069 的 14 位）并且配置了国内密钥时，国内接口排在前面：

1. 本机缓存
2. 聚合数据、阿里云市场条码、顶想云（只在有密钥时）
3. [Open Pet Food Facts](https://world.openpetfoodfacts.org/api/v2/product/)
4. [Open Food Facts](https://world.openfoodfacts.org/api/v2/product/)
5. [Open Products Facts](https://world.openproductsfacts.org/api/v2/product/)
6. [ProductGuru](https://myproduct.guru/lookup/)（免密钥，须注明 Data: ProductGuru）
7. [UPCitemdb 试用接口](https://api.upcitemdb.com/prod/trial/lookup)
8. Go-UPC、EAN-Search（只在有密钥时）

其它条码先走第 3 到第 7 步，再走配置了密钥的国内接口和 Go-UPC、EAN-Search。

请求带 `User-Agent: PawPad/2.13 (com.maokangji.maokangji)`。没有登录，也没有绕过任何接口。中国物品编码中心没有免密钥、可写进应用的公开 API；网站自己的后台地址没有公开文档，没有接入。

## 接口本身

| 接口 | 密钥 | 2026-10-15 实测 |
| --- | --- | --- |
| Open Pet Food Facts | 不要 | 下午全站 HTTP 502。上午同一环境里，皇家、渴望、希尔斯能打开，麦富迪和网易天成是 404 |
| Open Food Facts | 不要 | 能连上。进口三条提示商品类型是 petfood，国产六条是 product not found |
| Open Products Facts | 不要 | 与 Open Food Facts 相同 |
| ProductGuru | 不要。公平使用大约每秒 20 次、每天 1 万次，展示时要写 Data: ProductGuru 并带页面链接 | 能连上。进口三条有品牌、名称、净含量，没有配料、成分和图片。国产六条 HTTP 404 |
| UPCitemdb trial | 不要 | 能连上。下面九条都是 `total: 0` |
| BarcodeFinder `api.barcodefinder.info` | 文档写免密钥 | 文档里的示例 `5901234123457` 和这些猫粮都是 404。没有接入 |
| 聚合数据 `https://v.juhe.cn/barcode/query` | 要 key。[申请](https://www.juhe.cn/docs/api/id/52) 后实名，变量 `JUHE_BARCODE_KEY` | 不带 key 返回 `error_code: 10001`（错误的请求 KEY）。接口是活的。当前环境没有 key，没有拿到商品 |
| 阿里云市场 `https://ali-barcode.showapi.com/barcode` | 要 AppCode。云市场购买或领取试用后，请求头 `Authorization: APPCODE …`，变量 `ALIYUN_BARCODE_APPCODE` | 不带 AppCode 返回 HTTP 400、空正文。当前环境没有 AppCode，没有拿到商品 |
| 顶想云 `https://api.topthink.com/barcode/query` | 要访问令牌。[文档](https://www.topthink.com/api/16)。请求头 `Authorization: Bearer …`，变量 `TOPTHINK_BARCODE_TOKEN` | 不带令牌返回 `访问令牌不能为空`。随便写一个 Bearer 返回 `访问令牌不存在`。当前环境没有真令牌，没有拿到商品 |
| Go-UPC | 要 key。[注册](https://go-upc.com/docs/)，变量 `GO_UPC_KEY` | 不带 key 返回 HTTP 401 |
| EAN-Search | 要 token。[注册](https://www.ean-search.org/ean-api-intro.html)，变量 `EAN_SEARCH_TOKEN` | 不带 token 返回 HTTP 401，`Invalid token` |
| 中国物品编码中心 | 企业接口申请电话 400-7000-690 | 没有免密钥公开 API，未接入 |

密钥可以写成 `--dart-define=JUHE_BARCODE_KEY=…`，或把 [barcode-keys.example.json](barcode-keys.example.json) 抄一份填上再 `--dart-define-from-file=`。环境变量同名时盖过 dart-define。空字符串不会发出请求。

## 九个条码

进口三条的条码来自 Open Pet Food Facts 能打开的商品页。国产六条来自公开的商品条码页面，校验位核对过。公司分别是乖宝宠物食品集团、杭州网易严选贸易、烟台顽皮宠物用品销售、雀巢（中国）、玛氏食品（中国）。网易这一条是罐头零食，不是干粮。

| 商品 | 条码 | OPFF | OFF | OPF | ProductGuru | UPCitemdb |
| --- | --- | --- | --- | --- | --- | --- |
| 皇家 Neutered Satiety Balance，12 kg | `3182550799669` | HTTP 502（上午曾命中，有配料、成分和图片） | 404，类型是 petfood | 404，类型是 petfood | 命中。Royal Canin，名称，12 kg。无配料、无成分、无图片 | `total: 0` |
| 渴望 Orijen Original Cat，17 kg | `0064992280178` | HTTP 502（上午曾命中） | 404，类型是 petfood | 404，类型是 petfood | 命中。Orijen，Original Cat，17 kg。无配料、无成分、无图片 | `total: 0` |
| 希尔斯 Sterilised Cat young adult with duck，3 kg | `0052742035963` | HTTP 502（上午曾命中名称和图片，来源里没有配料和成分） | 404，类型是 petfood | 404，类型是 petfood | 命中。Hill's，名称，3 kg。无配料、无成分、无图片 | `total: 0` |
| 麦富迪 三文鱼双拼全价全期猫粮，2 kg | `6958862134620` | HTTP 502（上午是 404） | 404 | 404 | 404 | `total: 0` |
| 网易天成 浓汤红肉罐头金枪鱼鸡丝，85 克 × 12 | `6906628275179` | HTTP 502（上午是 404） | 404 | 404 | 404 | `total: 0` |
| 顽皮 白身吞拿鱼猫罐，85 克 | `6945496203099` | HTTP 502 | 404 | 404 | 404 | `total: 0` |
| 冠能 鸡肉配方成年期全价猫粮，2.5 kg | `6917878081946` | HTTP 502 | 404 | 404 | 404 | `total: 0` |
| 伟嘉 全价成猫猫粮海洋鱼，1.3 kg | `6914973700871` | HTTP 502 | 404 | 404 | 404 | `total: 0` |
| 伟嘉妙鲜包 幼猫海洋鱼，85 克 | `6914973107519` | HTTP 502 | 404 | 404 | 404 | `total: 0` |

聚合数据、阿里云市场、顶想云、Go-UPC、EAN-Search 这五家本次都没有可用密钥，所以上表没有它们的商品命中。无密钥时的错误码见上一节，客户端不会用空密钥去查。

## 国产粮

6 个 69 开头的条码里，每一个在已经回应的免密钥接口上都没有品牌或名称。覆盖率是 0/6。Open Pet Food Facts 下午整站 502，麦富迪和网易天成在上午的同一次检查里是 404，另外四条今天下午没有拿到 404，只能记成没连上。

进口 3 条在 ProductGuru 能看到品牌、名称和净含量。配料、成分和图片仍以 Open Pet Food Facts 上午的结果为准；它恢复之后，查询会先用它，因为它带配料和图片。希尔斯在那个来源里没有配料和成分。

没有密钥时，国产粮的扫码结果仍然是：拍包装识别，或点选品牌，然后把条码记在这台手机上。配了聚合数据、阿里云市场或顶想云的密钥之后，69 码会先问那几家。
