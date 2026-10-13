# 爪记

猫咪喂养与健康记录的本地原型。数据留在手机里，不需要账号和服务器。界面是简体中文。

版本 2.0。打开只有两页：今天、猫。今天最多 3 条待办，点一下就完成，主按钮是扫粮。猫页看照片、名字和体重，体检和看病从这里进去。

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

1. **今天**：当前猫的头像，最多 3 条待办（30 天内到期的粮、30 天内的疫苗、体重变化超过 5%）。点一条就完成：粮从列表里拿掉，疫苗记成今天打过并自动排下次，体重这条先收起。下面一个按钮「扫粮」。
2. **猫**：顶部横滑头像切换。中间是照片、名字和体重大数字，点数字改体重，点名字改照片和名字。两个入口：「体检」「看病」。
3. **建档**：一张照片加一个名字，保存结束。
4. **扫粮**：全屏相机。扫到 GS1 日期码会自动填生产日期和到期日，确认页只点一次「记下」。普通商品条码没有日期，确认后先把这袋记下来。
5. **体检和看病**：体检仍按年龄和品种给项目。看病仍是疾病条目，记下后挂在这只猫名下。没有独立的粮仓页、健康页和我的页。

首次启动会放入两只示例猫和两袋示例粮，方便直接看界面。删掉之后不会再自动加回来。

## 测试

- `test/gs1_parser_test.dart`：括号形式、GS 分隔符、连写日期、日为 `00`、AI 15、普通 EAN 不含日期
- `test/ocr_date_parser_test.dart`：中文日期、EXP、全角数字、保质期月数推算
- `test/reminder_planner_test.dart`：30/7 天保质期、已过期的不排、疫苗驱虫、开封倒计时
- `test/widget_test.dart`：免责声明和日期卡片
- `test/cjk_font_test.dart`：中文笔画被画出来，而不是缺字方框
- `test/screenshots_test.dart`：渲染今天、猫、扫粮、建档、体检五张图

## 局限

- 示例图鉴的营养成分、规格和条码不是真实商品数据。
- 毛色来自照片颜色，品种只是候选，不能当成鉴定。
- 文字识别依赖印刷清晰程度，保存前需要人工确认。
- 不是每袋粮都印 GS1 日期码。普通商品条码不能反推日期。
- 通知不是精确到秒的闹钟，部分国产系统还会限制后台提醒。
- 本仓库在 Linux 上验证了 `flutter analyze`、`flutter test` 和 Android 构建。iOS 需要在 Mac 上编译。
- 没有云同步、账号和真实兽医内容。
