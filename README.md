# 爪记

猫咪喂养与健康记录的本地原型。数据留在手机里，不需要账号和服务器。界面是简体中文。

爪记可以管理多只猫，给每只猫分开记疫苗、驱虫、就医、体重、喂食和体态照片；也可以扫猫粮条码，登记生产日期、保质期和开封后的倒计时。热量、换粮比例和日期提醒只是家庭记录，不能代替兽医。

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

打调试包：

```bash
flutter build apk --debug
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

- `CAMERA`：扫条码、拍头像、拍包装日期、拍体态
- `POST_NOTIFICATIONS`：Android 13+ 的通知
- `RECEIVE_BOOT_COMPLETED`：重启后恢复已安排的提醒
- `VIBRATE`
- `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE`（最高到 API 32）：从相册选图

提醒使用非精确闹钟（`inexactAllowWhileIdle`），不申请精确闹钟权限，送达时间可能略有延迟。通知图标是 `res/drawable/ic_stat_paw.xml`。

iOS `Info.plist`：

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

本地通知在 `AppDelegate` 里把 `UNUserNotificationCenter` 的 delegate 交给 Flutter。首次进入会请求通知权限。iOS 最多保留 64 条待发送通知，应用只登记最近的 60 条。

## 功能说明

1. **多猫**：添加、编辑、删除。首页圆形头像切换当前猫，记录互不混用。
2. **照片**：相机或相册作为头像。识别毛色和大致品种走可替换接口 `CoatBreedRecognizer`：优先尝试 Google ML Kit 图像标注，失败或标签无法映射时用内置示例模型，结果必须经你确认才写入档案。体态页可以隔一段时间再拍，并排看较早和最近的照片。
3. **健康**：疫苗、体内/体外驱虫、就医、体重曲线、健康笔记，以及即将到来的日期。首页、健康页、喂养页和提醒页都有“不能替代兽医诊断”的说明。
4. **喂养**：记录食物类型和克数，按体重估算每日热量（幼猫、绝育、减重用不同系数）。可设早餐、晚餐提醒。换粮按 7 天比例提醒：25% → 50% → 75% → 100%。
5. **猫粮**：内置皇家、Orijen、Acana、网易严选、麦富迪、诚实一口的示例图鉴，条码和热量都标了“示例数据”。`mobile_scanner` 扫 EAN/UPC 后显示品牌、规格和储存方式。条码本身没有日期。生产日期和保质期可以：
   - 解析 GS1 元素串（AI 11 生产日期、AI 17 失效日期、AI 15 仅作最佳赏味期提示、AI 10 批号）
   - 用 ML Kit 中文文字识别包装上的日期，再由你确认
   - 手动填写
   保质期前 30 天和 7 天提醒。标记开封后，干粮按约 4–6 周（图鉴里多为 35–42 天）、湿粮按冷藏并尽快喂完（示例为 2 天）倒计时。不认识的条码可以自己补一条产品。
6. **通知**：`flutter_local_notifications` 负责上述提醒。每次打开或改记录时会重排。

首次启动会放入两只示例猫和两袋示例粮，方便直接看界面。删掉之后不会再自动加回来。

## 测试

- `test/gs1_parser_test.dart`：括号形式、GS 分隔符、连写日期、日为 `00`、AI 15、普通 EAN 不含日期
- `test/ocr_date_parser_test.dart`：中文日期、EXP、全角数字、保质期月数推算
- `test/reminder_planner_test.dart`：30/7 天保质期、已过期的不排、疫苗驱虫、开封倒计时、喂食顺延、七日换粮
- `test/widget_test.dart`：免责声明和日期卡片
- `test/cjk_font_test.dart`：中文笔画被画出来，而不是缺字方框
- `test/screenshots_test.dart`：在无设备环境下渲染首页、健康、粮仓、日期卡片、我的和档案（测试里会加载同一套中文字体）

## 局限

- 示例图鉴的营养成分、规格和条码不是真实商品数据。
- 热量和换粮比例是通用估算，不是处方。
- ML Kit 基础图像模型认不出可靠的中文毛色和品种，所以识别结果默认是可插拔的示例实现，映射到的品种只供确认。
- 文字识别依赖印刷清晰程度，保存前需要人工确认。
- 不是每袋粮都印 GS1 日期码。普通商品条码不能反推日期。
- 通知不是精确到秒的闹钟，部分国产系统还会限制后台提醒。
- 本仓库在 Linux 上验证了 `flutter analyze`、`flutter test` 和 Android 构建。iOS 需要在 Mac 上编译。
- 没有云同步、账号和真实兽医内容。
