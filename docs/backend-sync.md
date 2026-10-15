# 共享条码的后端

这条链路只同步用户贡献的猫粮条码。不上传猫名、体重、健康记录、照片文件和主人姓名。手机上的照护数据仍然只在本机。

## 选定

用仓库里已有的 Dart 服务 `server/`，部署在**阿里云轻量应用服务器**。

| 项 | 选择 |
| --- | --- |
| 机器 | 轻量应用服务器，2 核 2 GB 或 2 核 4 GB，系统盘 40 GB。地域选华东或华北。新用户常有试用，之后大约每月十几到几十元。 |
| 进程 | `server/`（Shelf）。对外 HTTPS，端口由前面的 Nginx 转到 `8094`。 |
| 数据库 | 设了 `DATABASE_URL` 就写 Postgres 表 `shared_barcodes`。没设时只留在进程内存，用来本机试接口，不当正式库。正式库用同地域的阿里云 RDS PostgreSQL 入门规格，或先放在这台轻量机上的 Postgres。 |
| 域名 | 国内域名做 ICP 备案，解析到这台轻量机。备案完成前，手机用 `--dart-define=BARCODE_SHARE_URL=` 指向临时地址也可以。 |

不把这条数据放在 Cloudflare Workers 或海外边缘上。从大陆访问那些节点不稳定，而这张表要落在自己能备份的库里。腾讯云轻量是同一套接口的备选，已经有备案主体时再换。更完整的整包同步（猫咪、健康、照片）仍见 [国内服务器与桥接方案](国内服务器与桥接方案.md)，和这条条码库不是同一张表，也不共用用户 JWT。

现在的安装包**不带**服务器地址。没配地址时修正只留在手机上，应用照常打开。以后在构建时加上地址，下面的客户端就会开始同步，不用再改查询顺序。

## 打开方式

手机（密钥不要写进仓库）：

```bash
flutter run \
  --dart-define=BARCODE_SHARE_URL=https://你的域名 \
  --dart-define=BARCODE_SHARE_KEY=一串口令
```

同名环境变量盖过 dart-define。`BARCODE_SHARE_KEY` 可以空着；服务端也没设口令时，读写接口不加鉴权。

服务端：

```bash
cd server
BARCODE_SHARE_KEY=一串口令 PORT=8094 dart run bin/server.dart
```

口令和手机上的一致。设了口令之后，`/v1/shared-barcodes/` 要带 `Authorization: Bearer <口令>`。这不是登录用户的 JWT。

## 配置接口

`GET /v1/barcode-share` 不需要口令，也不需要用户 JWT。手机在提交和重试之前先读它。返回的 `contract` 是 `shared-barcodes` 且 `version` 不小于 1、`enabled` 为 true 时，才去读写条码。否则把这条修正留在队列里，下次再问。

```json
{
  "contract": "shared-barcodes",
  "version": 1,
  "enabled": true,
  "conflict": "updatedAt-then-contributorId",
  "privacy": "barcode-metadata-only",
  "lookup": "GET /v1/shared-barcodes/{code}",
  "submit": "PUT /v1/shared-barcodes/{code}"
}
```

## 表和读写

表 `shared_barcodes`，一条条码一行。字段只有：

| 字段 | 说明 |
| --- | --- |
| `barcode` | 只留数字。8、12、13、14 位。前导 0 去掉后当成同一个码。 |
| `brand` | 品牌，最长 40。 |
| `name` | 名称，最长 80。 |
| `spec` | 规格，最长 40。 |
| `ingredients` | 配料，可空，最长 500。后来的空配料不会擦掉已经记下的配料。 |
| `imageUrl` | 仅 http 或 https。本机照片路径不上传。 |
| `contributorId` | 匿名设备号，形如 `dev-` 加数字，匹配 `^[A-Za-z0-9_-]+$`。不是姓名。 |
| `createdAt` | 第一次写入的时间，后来的提交改不掉。 |
| `updatedAt` | 这次修正的时间。 |

`GET /v1/shared-barcodes/{code}` 找到返回这一行，没有则 404。

`PUT /v1/shared-barcodes/{code}` 提交上面的字段。成功返回留下的那一行，并带 `applied`。路径里的码和正文里的码规范化之后必须相同。

## 冲突

`updatedAt` 更晚的留下。时间相同则 `contributorId` 字典序更大的留下。更早的提交仍返回 200，`applied` 为 false，正文是当前留下的那条，不会把旧字盖回去。

手机上的查询顺序不变：这台手机自己的修正，然后共享库，然后内置 66 条，然后公开商品库。自己的修正不会被更新的共享行盖掉。

## 离线队列和重试

同意提交之后，如果配置接口没就绪、请求超时或返回失败，这条修正写入本机设置 `barcodeShareQueue`（JSON，不是新的数据库表，Drift 结构版本不动）。队列里同一条码只留最新的一条，最多 40 条。内容就是上表那些字段，没有猫咪和健康记录。

重试间隔：第一次失败后 30 秒，然后 2 分钟、10 分钟，之后每小时一次。应用启动时会清一次队列。还没到点的留着。服务器明确收下（包括 `applied: false`，表示别人的更新更晚）就从队列删掉。没配 `BARCODE_SHARE_URL` 时队列留在手机上，下一次带上地址的构建会接着发。

点「只记在手机」之后不再入队。

## 测试

```bash
cd server && dart test
flutter test test/barcode_share_test.dart test/scan_flow_test.dart
```

服务端测试覆盖配置接口在设了口令时仍然公开，以及更新时间冲突。手机测试用假的共享客户端：第一次提交失败会进队列，配置未就绪时不会发出去，到点且服务器就绪后再发出去。
