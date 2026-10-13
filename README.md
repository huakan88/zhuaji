# 爪记

猫咪喂养与健康记录的本地原型。数据留在手机里，不需要账号和服务器。界面是简体中文。

爪记给每只猫记疫苗、驱虫、就医、体重和按年龄的体检，也保留疾病养护。其次是扫猫粮条码，登记保质期和开封倒计时。这些记录只供家庭参考，不能代替兽医。

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

- `CAMERA`：扫条码、拍头像、拍包装日期
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

1. **多猫**：添加、编辑、删除。首页一屏放下今天要处理的事，点名字切换当前猫。底部是今天、健康、我的。粮仓在「我的」里。
2. **照片**：建档只必填照片和名字。相机或相册之后会给出毛色、品种候选，点一下即可。识别走可替换接口 `CoatBreedRecognizer`：优先尝试 Google ML Kit 图像标注，失败时用内置示例模型。
3. **健康**：这一页的主操作是记体重，步进器默认上次的数。下面是按年龄体检、疾病养护、疫苗、驱虫和就医。体检按生日计算幼猫、成年、成熟、老年，并结合品种给出项目（血常规、生化、SDMA、T4、尿检、血压、口腔、疫苗、驱虫；缅因/布偶增加心脏超声，波斯/英短增加 PKD）。疾病库覆盖慢性肾病（可记 IRIS 分期和饮水）、下泌尿道、糖尿病、甲亢、HCM、口炎、肥胖、肠道与胰腺炎、FIP、上呼吸道、皮肤和关节炎。疫苗下次日期按幼猫 4 周、成年 1 年自动算。内容注明 AAHA/AAFP、WSAVA、ISFM、IRIS 出处，页面写明仅供参考、请遵医嘱。
4. **猫粮**：首页主操作是扫条码。内置皇家、Orijen、Acana、网易严选、麦富迪、诚实一口的示例图鉴，条码和热量都标了“示例数据”。`mobile_scanner` 扫 EAN/UPC 后显示品牌、规格和储存方式。条码本身没有日期。生产日期和保质期可以：
   - 解析 GS1 元素串（AI 11 生产日期、AI 17 失效日期、AI 15 仅作最佳赏味期提示、AI 10 批号）
   - 用 ML Kit 中文文字识别包装上的日期，再由你确认
   - 手动填写
   保质期前 30 天和 7 天提醒。新登记的粮默认今天开封。开封后，干粮按约 4–6 周（图鉴里多为 35–42 天）、湿粮按冷藏并尽快喂完（示例为 2 天）倒计时。不认识的条码可以自己补一条产品。
5. **通知**：`flutter_local_notifications` 负责体检、疫苗、驱虫、复查、保质期和开封提醒。每次打开或改记录时会重排。首页直接列出即将到期的事项。

首次启动会放入两只示例猫和两袋示例粮，方便直接看界面。删掉之后不会再自动加回来。

## 测试

- `test/gs1_parser_test.dart`：括号形式、GS 分隔符、连写日期、日为 `00`、AI 15、普通 EAN 不含日期
- `test/ocr_date_parser_test.dart`：中文日期、EXP、全角数字、保质期月数推算
- `test/reminder_planner_test.dart`：30/7 天保质期、已过期的不排、疫苗驱虫、开封倒计时
- `test/widget_test.dart`：免责声明和日期卡片
- `test/cjk_font_test.dart`：中文笔画被画出来，而不是缺字方框
- `test/screenshots_test.dart`：在无设备环境下渲染今天、健康、体检、疾病、我的、扫码和建档（测试里会加载同一套中文字体）

## 局限

- 示例图鉴的营养成分、规格和条码不是真实商品数据。
- ML Kit 基础图像模型认不出可靠的中文毛色和品种，所以识别结果默认是可插拔的示例实现，映射到的品种只供确认。
- 文字识别依赖印刷清晰程度，保存前需要人工确认。
- 不是每袋粮都印 GS1 日期码。普通商品条码不能反推日期。
- 通知不是精确到秒的闹钟，部分国产系统还会限制后台提醒。
- 本仓库在 Linux 上验证了 `flutter analyze`、`flutter test` 和 Android 构建。iOS 需要在 Mac 上编译。
- 没有云同步、账号和真实兽医内容。
