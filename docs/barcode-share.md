# 共享条码库

用户用「拍包装」「选品牌」或手动补全记下的猫粮，可以交给已有的肉垫本 API，给其他手机查询。本机内置的 66 条常见猫粮仍然在，不依赖这台服务器。

查一条码的顺序：

1. 这台手机上你自己记下的结果
2. 共享库里 `updatedAt` 最新的一条
3. 内置常见猫粮表
4. 公开商品库（缓存，然后 Open Pet Food Facts、Open Food Facts、Open Products Facts、ProductGuru、UPCitemdb）

没配 `BARCODE_SHARE_URL` 时第 2 步跳过，应用照常打开，不会因为连不上服务器而崩溃。共享库超时、返回打不开或一条坏数据时，也继续查内置表和公开库；已经缓存的共享结果只在这次请求失败时顶上，服务器明确说没有这条时不再用旧缓存挡住内置表。

## 上传什么

只上传商品条码元数据：`barcode`、`brand`、`name`、`spec`、可选 `ingredients`、可选 `imageUrl`（仅 http 或 https 链接；本机照片不上传）、匿名 `contributorId`（设备号，不是姓名）、`createdAt`、`updatedAt`。

不上传猫的名字、健康记录、体重和你的姓名。第一次可以提交时，页面会先说明这句话，点「提交」之后才发出去。点「只记在手机」则以后也不上传，直到卸掉应用里的这项设置。

## 修正日期

同一条码再提交一次就是修正：品牌、名称、规格、配料和图片按新内容覆盖，`updatedAt` 改成这次的时间，`createdAt` 保持第一次写入的时间。

服务器只留下 `updatedAt` 更晚的那条。时间相同则留下 `contributorId` 字典序更大的那条。更早的提交会收到当前保留的内容，`applied` 为 false，不会把旧字盖回去。

商品页在有修正时间时写「修正于 2026-10-15」。你这台手机上的记录仍优先于共享库，即使别人后来又改过。

## 配置

手机（不要把真密钥写进仓库）：

```bash
flutter run \
  --dart-define=BARCODE_SHARE_URL=https://your-api.example \
  --dart-define=BARCODE_SHARE_KEY=换一串只有你知道的口令
```

也可以把 [barcode-share.example.json](barcode-share.example.json) 抄成不提交的本地文件再 `--dart-define-from-file=`。同名环境变量会盖过 dart-define。`BARCODE_SHARE_KEY` 可以为空；服务端也没设口令时，接口不加鉴权。

服务端用仓库里的 `server/`。共享条码和猫咪、健康记录不是同一张表。

```bash
cd server
BARCODE_SHARE_KEY=换一串只有你知道的口令 PORT=8094 dart run bin/server.dart
```

有 `DATABASE_URL` 时写入 Postgres 表 `shared_barcodes`，没有则只留在进程内存里。口令和手机上的 `BARCODE_SHARE_KEY` 要一致。设了口令之后，请求要带 `Authorization: Bearer <口令>`。这不是登录用户的 JWT。

## 接口

`GET /v1/shared-barcodes/{code}`  
找到返回 JSON。没有这条返回 404。

`PUT /v1/shared-barcodes/{code}`

```json
{
  "brand": "麦富迪",
  "name": "三文鱼双拼全价全期猫粮",
  "spec": "2千克",
  "ingredients": "",
  "imageUrl": null,
  "contributorId": "dev-1",
  "createdAt": "2026-10-01T00:00:00.000Z",
  "updatedAt": "2026-10-15T00:00:00.000Z"
}
```

条码用路径里的数字。8、12、13、14 位都可以，前导 0 会当成同一个码。成功时返回留下的那条，并带 `applied`。

## 测试

```bash
cd server && dart test
flutter test test/barcode_share_test.dart
```

手测：

1. 不带 `BARCODE_SHARE_URL` 启动，拍包装记下一条，确认没有弹出「提交到共享库」。
2. 配上地址和口令，再记一条，弹出说明。点「提交」后，另一台配了同一地址的手机扫这个码，应看到品牌、名称、规格和「修正于」。
3. 改名称再提交一次。后提交的那台 `updatedAt` 更新，先提交的内容不再被查到。把手机时间调早再提交，服务器仍保留较新的那条。
