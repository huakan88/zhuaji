# 爪记

克隆：`git clone` 当前 Origin 远程，进入目录后执行 `flutter pub get`。
分支：日常集成在 `develop`，功能用 `feature/*`，修复用 `fix/*`，`main` 只接受合并。
发版：先改 `pubspec.yaml` 的版本号，用 `release/x.y.z` 合并进 `main`，再打附注标签 `vX.Y.Z`。详见 [Git 工作流](docs/git-workflow.md)。

猫咪喂养与健康记录的本地原型。数据留在手机里，不需要账号和服务器。界面是简体中文。

版本 2.3。底部五个入口：今天、健康、扫粮（中间大按钮）、粮仓、猫咪。除了建档时的猫名，其它都用点选或滚轮，不再弹出键盘。界面是奶油底、珊瑚和鼠尾草，顶栏是渐变。

手机仍然先写本地数据库。配了云端令牌之后，才会把增量推到 `server/` 里的 API。怎么在本机把后端跑起来，见下面的「后端」。国内云和桥接说明在 `docs/国内服务器与桥接方案.md`。

界面字体是随包附带的 Noto Sans SC 静态字重（Regular / Bold），并设为 `ThemeData.fontFamily` 和 `textTheme`。不要改回可变字体：Flutter 不会套用字重轴，默认 Thin 主字重会让中文变成方框。

## 环境

- Flutter 3.47（Dart 3.13）或兼容的稳定版
- Android：Android SDK，`minSdk` 24，建议用 Android Studio
- iOS：macOS、Xcode，部署目标 iOS 15.5（ML Kit 要求）

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

`lib/data/db/app_database.g.dart` 已提交。改了 Drift 表之后再跑一次 `build_runner`。

## 运行

Android：

```bash
flutter run -d android
```

打 arm64 release 包。必须带 `--no-tree-shake-icons`，否则 Material 和 Cupertino 图标字体会被裁成几个字形，真机上变成方框：

```bash
flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons
```

iOS（需要 Mac）：

```bash
cd ios
pod install   # 若工程使用 CocoaPods；新版 Flutter 也可能走 Swift Package Manager
cd ..
flutter run -d ios
```

模拟器或真机出现后，`flutter devices` 能看到设备名。

## 权限

Android `AndroidManifest.xml`：

- `CAMERA`：扫条码、拍头像、拍包装日期
- `POST_NOTIFICATIONS`：Android 13+ 的通知。第一次进入会请求，拒绝后记录仍留在手机上。
- `RECEIVE_BOOT_COMPLETED`：重启后由系统拉起已登记的提醒。
- `SCHEDULE_EXACT_ALARM`：Android 12+ 的精确提醒。允许时用精确闹钟，拒绝时退回非精确闹钟，避免提醒直接消失。第一次进入才会打开系统授权页。
- `VIBRATE`
- `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE`（最高到 API 32）：从相册选图

能申请到精确闹钟时按点送达；否则用非精确闹钟，时间可能略有延迟。通知图标是 `res/drawable/ic_stat_paw.xml`。冷启动先画出界面，再打开数据库和通知。

iOS `Info.plist`：

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

本地通知在 `AppDelegate` 里把 `UNUserNotificationCenter` 的 delegate 交给 Flutter。首次进入会请求通知权限。iOS 最多保留 64 条待发送通知，应用只登记最近的 60 条。

## 功能说明

1. **今天**：到期粮、疫苗、驱虫、体重异常。点一下就办完。粮还留在粮仓。疫苗和驱虫会把下次日期往后算。体重打开步进页，点保存。
2. **健康**：体重、疫苗、驱虫、就医、体检、看病六个格子。每个子页一屏，底部一个主按钮。品牌、疫苗、驱虫药、就医原因都是点选。日期默认今天，改的时候用滚轮。
3. **扫粮**：中间大按钮直接开相机。扫到就进确认；扫不到点「选品牌」。确认页点品牌和粮名，核对三个日期和开封天数，点「记下」。记下后出现在今天，也出现在粮仓。
4. **粮仓**：已登记的粮和还剩几天。点进去可以标已吃完或删除。
5. **猫咪**：横滑头像切换，看照片、名字和体重。添加猫咪仍是一张照片加一个名字，这是唯一要打字的地方。
6. **体检和看病**：体检按年龄点选项目再点完成。看病点病名，能看到红灯和喂养，点记下记在这只猫身上。

首次启动会放入两只示例猫和两袋示例粮，方便直接看界面。删掉之后不会再自动加回来。

## 测试

- `test/gs1_parser_test.dart`：括号形式、GS 分隔符、连写日期、日为 `00`、AI 15、普通 EAN 不含日期
- `test/ocr_date_parser_test.dart`：中文日期、EXP、全角数字、保质期月数推算
- `test/reminder_planner_test.dart`：30/7 天保质期、已过期的不排、疫苗驱虫、开封倒计时
- `test/widget_test.dart`：免责声明和日期卡片
- `test/cjk_font_test.dart`：中文笔画被画出来，而不是缺字方框
- `test/screenshots_test.dart`：渲染今天、健康、扫粮、确认、粮仓、猫咪、疫苗
- `test/local_sync_test.dart`：迁移步骤、出站队列、照片压缩、提醒裁剪、API 地址

## 后端

API 在 `server/`，用 Dart Shelf 写。没有 `DATABASE_URL` 时用内存库，方便本机看接口。有地址时连 PostgreSQL。

只跑 API（内存库，端口 8080）：

```bash
cd server
dart pub get
AUTH_DEV=1 dart run bin/server.dart
```

`AUTH_DEV=1` 时，手机号验证码就是号码后四位，并写在响应的 `devCode` 里。这只给本地联调用，不要开在正式环境。`AUTH_DEV=0` 时验证码不会回在响应里，短信通道还没接。

微信登录是 `POST /v1/auth/wechat`。默认返回 501。设 `WECHAT_MOCK=1` 才会发一个试用令牌。

带 Postgres 和 Nginx（本机端口 8094）：

```bash
cd server
docker compose up --build
```

接口在 `http://127.0.0.1:8094`。App 默认的 local 地址是模拟器看宿主机的 `http://10.0.2.2:8094`。真机或别的地址用：

```bash
flutter run --dart-define=API_ENV=local --dart-define=API_BASE_URL=http://127.0.0.1:8094
```

`API_ENV` 可以是 `local`、`staging`、`prod`。`API_BASE_URL` 有值时覆盖环境地址。

冲突规则：比较 `updatedAt`（UTC），较新的留下。时间相同则 `deviceId` 字典序更大的留下。删除是 `deletedAt` 墓碑，旧的删除盖不过新的修改。手机先落本地，界面不等网络。

后端测试：

```bash
cd packages/zhuaji_sync && dart test
cd server && dart test
```

## 局限

- 示例图鉴的营养成分、规格和条码不是真实商品数据。
- 毛色来自照片颜色，品种只是候选，不能当成鉴定。
- 文字识别依赖印刷清晰程度，保存前需要人工确认。
- 不是每袋粮都印 GS1 日期码。普通商品条码不能反推日期。
- 通知不是精确到秒的闹钟，部分国产系统还会限制后台提醒。
- 本仓库在 Linux 上验证了 `flutter analyze`、`flutter test` 和 Android 构建。iOS 需要在 Mac 上编译。
- 云同步骨架已接上，默认没有令牌，界面仍只读写手机。短信、微信开放平台、OSS 和厂商推送都是接口，不是已经开通的账号。
