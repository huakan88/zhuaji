# 花爪

主仓是 GitHub：[huakan88/zhuaji](https://github.com/huakan88/zhuaji)。克隆：`git clone https://github.com/huakan88/zhuaji.git`，进入目录后执行 `flutter pub get`。
分支：日常集成在 `develop`，功能用 `feature/*`，修复用 `fix/*`，`main` 只接受合并。
发版：先改 `pubspec.yaml` 的版本号，用 `release/x.y.z` 合并进 `main`，再打附注标签 `vX.Y.Z`。详见 [Git 工作流](docs/git-workflow.md)。

猫咪喂养与健康记录的本地原型。数据留在手机里，不需要账号和服务器。界面是简体中文。

版本 2.20.1。显示名是花爪。包名和 Bundle ID 仍是 `com.maokangji.maokangji`，覆盖安装不会清掉手机里的记录。仓库名仍是 zhuaji。底部四个入口：今天、健康、粮仓、猫咪。今天页顶部左边是全局搜索，右边是相机。粮仓页仍保留本页搜索和相机。固定选项旁边可以手写，写上的按原文保存。性别仍是点选。体重按千克记。日期用滚轮。浅色是浅绿底和白卡片，深色是深灰绿，默认跟随系统。猫咪页可以改成「跟随系统 / 浅色 / 深色」。照片用大圆角，没有大面积渐变。

2.18 把用户看得到的名字改成花爪。启动图标、启动页、空状态、没有照片时的头像，以及协议页上的标志，都用同一张奶油色绒毛肉垫（粉色肉垫，深绿色底）。包名仍是 `com.maokangji.maokangji`。通知栏小图标仍是白色剪影，避免状态栏显示成彩色方块。

2.18.1 扫到本机猫粮表里的商品，或已经在粮仓里的那一袋，直接打开确认页或这袋粮，不再先停在商品列表。本机表里有、粮仓还没有的，确认页会带上品牌和名称。二维码里如果写着条码或商品链接，和扫那个条码走同一条路。今天页顶部仍是搜索和扫码挨在一起，搜索覆盖猫咪、健康记录、猫粮和食谱。底栏还是今天、健康、粮仓、猫咪。

2.20.1 条码不在本机表里时，可以手写品牌、名称和规格并保存。拍包装用手机上的 ML Kit 认字，到期日没读到就留空，不再默认成一年后。没写完的扫描和识别留在本机，关掉页面还能从「最近识别」接着填。

2.20 搜不到时把条码、末位不对和网址分开说。扫到无关二维码会说明这不是猫粮条码，不再套上一款粮。相机打不开、校验没过，页面上直接写下一步。健康页「接着上次」可以今天再记疫苗或驱虫，同一天再点不会多记一条。没有猫时，健康录入会请你去建档。猫咪页可以点性别、绝育和生日。同一天的体重改的是这一条，不会再叠一条。粮仓空的时候写清楚，吃完一袋会先确认。共享库没发出去的修正，今天和粮仓都能看见。

2.19 搜不到时可以扫码；搜的是条码就去查这串数字。扫到本机猫粮或已经在粮仓里的那一袋，页面上直接写品牌、品名和规格，有配料、成分也写在同一页。健康页可以再记上次的疫苗。手写项空着时会说明要写原因、医院、药名、疫苗、项目或病名。共享库没连上时，条码修正马上留在队列里，回到前台或稍后再发；提交失败仍会等一会儿再试。已经记下的袋，校验位不对也能扫开。无关的二维码不会写进条码。今天没有到期时，会写明是疫苗、驱虫和粮。

2.18.2 固定选项都还在，旁边多了「其他 / 手动输入」。驱虫药、疫苗、就医原因和医院、体检项目、病名、化验种类和单位、猫粮的口味、规格和形态、品种、每天克数、鲜食的提醒天数，空着不能记下，写上的按原文保存。拍疫苗贴纸时也可以手写名称。性别仍是点选。体重按千克记，没有单位开关。

2.17 为国内应用商店补了首次打开的隐私政策和用户协议。同意之前不初始化通知、扫码和联网，也可以只使用基本功能或退出。相机和相册仍在使用时才申请。猫咪页可以打开协议、撤回同意或删除本机数据。发布签名改读 `android/key.properties`，没有密钥时仍用 debug 签名。说明见 [隐私政策](docs/privacy-policy.md)、[用户协议](docs/user-agreement.md)、[权限说明](docs/permissions.md) 和 [发布签名](docs/release-signing.md)。

2.16.1 定了共享条码的后端：国内阿里云轻量加上现有的 `server/`。提交失败会留在手机队列里，配置接口就绪后再发。扫码会核对应校验位，相机页可以开手电筒，也可以手输条码。粮仓快捷入口、日期行和日历格子的点按收到 48dp。说明见 [共享条码的后端](docs/backend-sync.md)。

2.16 把粮仓每一袋收成一句状态：还能吃几天、快吃完，或快到期；没开封就写没开封。这袋粮的详情先给这句话。健康页可以点「再记」上次的驱虫药。猫咪档案把体重放进品种和年龄下面，点一下去称。底栏、包名和启动图标不动。

2.15 按公开产品的节奏收了一下四个页面，不改底栏，也不改启动图标。今天分成当天要办和接下来；健康顶部是记体重、记疫苗、记驱虫，下面是时间线；扫到的粮按品牌、规格、配料分开；猫咪档案多了品种和年龄。空状态是简单的小山，点按有轻触感。对照笔记在 [可学之处](docs/competitive-learnings.md)。

2.14 在手机里放了一份常见猫粮和猫罐头条码表。扫码先认你自己拍包装或点选品牌记下的结果，再查共享库里较新的修正，然后是这张表，最后才走缓存和免密钥公开库。表里有的码不访问网络，页面显示品牌、名称和规格；来源写了配料或成分才显示那一栏。没有配图的条目不放图片。配了共享库地址时，第一次提交前会说明并确认，只上传商品条码资料。没配地址时只留在本机。付费接口仍然只在构建时带了密钥才调用，这次没有申请任何密钥。条数、品牌和九个实测条码见 [条码数据源](docs/barcode-coverage.md)。共享库见 [共享条码库](docs/barcode-share.md)。

2.13 在原来的公开库后面加上 [ProductGuru](https://myproduct.guru/lookup/)（免密钥，页面上保留 Data: ProductGuru）。69 开头的条码如果构建时带了密钥，会先查聚合数据、阿里云市场条码和顶想云，再走公开库；Go-UPC 和 EAN-Search 也只在有密钥时调用。没有密钥就不会请求这些付费接口。每次请求限时 4 秒，整次查询限时 12 秒。某个库没连上时不把「没有这款」写进缓存。查到什么显示什么，没有配料或成分就不显示那一栏。密钥放在 `--dart-define` 或环境变量里，示例见 [docs/barcode-keys.example.json](docs/barcode-keys.example.json)。实测覆盖见 [条码数据源](docs/barcode-coverage.md)。

2.12 让扫到的 EAN-13 或 UPC 去公开商品库查真实资料，并在今天页加上全局搜索。今天的搜索覆盖猫咪、粮仓、猫粮库、自制食谱、疫苗、驱虫、体重、化验、就诊和提醒，支持拼音首字母和最近搜索。长按图标的「扫粮」会先回到今天，再打开相机。查不到就提示拍包装或点选品牌，记下后下次能认出。

2.11 把扫粮收进粮仓。底栏不再放单独的扫码圆钮。粮仓顶部左边是搜索，可以按品牌、名字、条码找已经入库的粮，也可以搜猫粮库。右边是相机。扫到已经入库的条码，直接打开这袋粮；还没入库的，进入确认页。搜索栏下面是拍贴纸、自定义猫粮、自制鲜食和图鉴。

2.10 在粮仓里加了「自制鲜食」。卡片列出安全提示、禁忌食材、克数写法和慢煮步骤、每天喂量的算法，以及牛磺酸、钙磷、鱼油、维生素 E、复合维生素 B、碘。数字和句子都带来源链接，资料在本地，离线能看。点进详情后可以一键加入粮仓并按开封天数提醒。这些机构没有公布一张通用的全价克数食谱，页面写明必须经兽医或认证营养师确认才能长期当主食。

2.9 把整套颜色换成浅绿和白，并补上黑夜主题。图表、日历、化验偏高偏低、猫照片卡、弹窗、底栏、通知和桌面小组件跟着同一套色。Android 小组件在系统是深色时用深灰绿；如果手机和 App 的外观不一致，小组件按 App 里选的来。iPhone 小组件源码用同一套色板，还没编进安装包。

2.5 参考同类 App 的评价（见 [竞品调研](docs/competitor-research.md)）加了四件事：体重页和猫咪页的体重走势线；猫咪页「最近」的照护时间线；一键「复制健康卡」，可以直接发给医生或寄养；家里有多只猫时，今天页顶部可以切换猫咪，并显示每只猫的待办数。

2.6 让记录少点几下（方案见 [输入与设备调研](docs/input-and-devices-research.md)）：

- 日期胶囊「今天 / 昨天 / 前天 / 更早」，更早才开滚轮。驱虫默认上次的种类和产品，就医默认上次去的医院，体重从上次的值微调。
- 今天页点勾直接记下，底部条可以「撤销」，疫苗、驱虫和到期粮都能退回原样。
- 疫苗和驱虫的到期通知带「已完成」按钮。长按桌面图标有「称体重 / 记驱虫 / 扫粮」三个快捷方式。
- 记住条码：图鉴里没有的条码，选一次品牌记下后，下次扫到直接认出；认错了点「不是这个」重选。
- 蓝牙秤：体重页「用蓝牙秤（抱猫称）」，先称自己、再抱猫称，相减就是猫的体重，自己的体重会记住下次带出。支持小米体脂秤 2（广播 0x181B）和标准蓝牙体重秤（0x181D / 0x2A9D），顺带认小米体重秤 1 代。**解析按公开协议写成并有单元测试，还没用真秤测过。** 没有秤、蓝牙没开、没权限或连不上时，页面会说明原因，随时可以点「手动输入」。

2.8 把近期的事收进一张日历，并补上余粮、贴纸和桌面小组件：

- 今天页「未来 30 天」：疫苗、驱虫、体检、粮到期、开封、补货和复诊在同一张日历上。点某一天看当天的事，点一下完成或顺延 7 天。
- 粮仓按规格和每天喂食量（点选 30 到 100 克）估算还能吃几天。快吃完时日历和早上的提醒会说该补货。
- 疫苗页「拍贴纸」：离线识别名称、批号和日期，对一下再记下。
- Android 桌面小组件「今天的事」显示今天和下一个提醒，点一下进对应页。日历页可以改成不显示待办。iPhone 的小组件源码已经放在工程里，还没编进安装包，桌面上还不会出现。
- 「复制健康卡」加上最近的化验单、自定义猫粮，体重仍在卡上。

2.7 补了图鉴和化验单：

- 自定义猫粮：扫不到或搜不到时可以自己添加。拍包装正面后，离线 OCR 填上品牌和名称，口味、干粮/湿粮/主食罐/冻干/零食、规格用点选，保质期可以拍照或用滚轮。存进本地图鉴，可以改、可以删。同一个条码下次直接认出。图鉴搜索也能找到自己加的。
- 扫码页写明「条形码、二维码都能扫」，相机按 EAN-13、EAN-8、UPC、GS1（DataBar / DataMatrix / 数字链接二维码）和 QR 来认。认不出时有「拍包装识别」和「自己添加」。
- 健康里的「化验单」：拍照或从相册选多张，点选类型（血常规 / 生化 / 尿检 / 影像 / 其他）和日期胶囊，按时间线留档，点开可以放大原图。离线 OCR 读常见血常规和生化指标，对照 IDEXX 猫的参考范围标出偏高、偏低、正常，并写一句白话。页上写着「仅供参考，以兽医诊断为准」，范围来源也写在下面。没认出的数值点一下用加减改，不用手打整张单子。同一项多次检查能看变化。体检里点「完成」后，血常规、生化和影像这类项目会直接去存化验单。

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

iOS 只能在 Mac 上编译。这台 Linux 环境里 `flutter build ios` 不是可用命令，产不出模拟器包，也产不出未签名真机包。步骤、限制和还缺的账号见下面的「iOS」。

## 权限

Android `AndroidManifest.xml`：

- `CAMERA`：扫条码、拍头像、拍包装、拍化验单、拍疫苗贴纸
- `POST_NOTIFICATIONS`：Android 13+ 的通知。第一次进入会请求，拒绝后记录仍留在手机上。
- `RECEIVE_BOOT_COMPLETED`：重启后由系统拉起已登记的提醒。
- `SCHEDULE_EXACT_ALARM`：Android 12+ 的精确提醒。允许时用精确闹钟，拒绝时退回非精确闹钟，避免提醒直接消失。第一次进入才会打开系统授权页。
- `VIBRATE`
- `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE`（最高到 API 32）：从相册选图
- `BLUETOOTH_SCAN`（`neverForLocation`）/ `BLUETOOTH_CONNECT`：Android 12+ 读蓝牙秤。打开蓝牙秤页才会申请。
- `BLUETOOTH` / `BLUETOOTH_ADMIN` / `ACCESS_FINE_LOCATION`（最高到 API 30）：Android 11 及更早扫描蓝牙的系统要求，不读取位置。

隐私政策见 [docs/privacy-policy.md](docs/privacy-policy.md)，应用里在第一次打开和「猫咪 → 隐私政策」。用户协议、权限说明在同一处。

能申请到精确闹钟时按点送达；否则用非精确闹钟，时间可能略有延迟。通知图标是 `res/drawable/ic_stat_paw.xml`。冷启动先画出界面，再打开数据库和通知。

iOS `Info.plist`：

- `NSCameraUsageDescription`：今天和粮仓扫码、拍包装、拍化验单、拍疫苗贴纸、拍猫
- `NSPhotoLibraryUsageDescription`：从相册选猫的照片、包装或化验单。疫苗贴纸目前只走相机
- `NSBluetoothAlwaysUsageDescription` / `NSBluetoothPeripheralUsageDescription`：前台读蓝牙秤，不定位、不后台扫描
- 没有通知用途字符串。iOS 的本地通知不需要这条。第一次进入时由系统弹窗询问
- 没有后台蓝牙。秤只在打开蓝牙秤页时读
- `ITSAppUsesNonExemptEncryption` 为 false。只用系统 HTTPS，不含自行实现的加密

本地通知在 `AppDelegate` 里把 `UNUserNotificationCenter` 的 delegate 交给 Flutter。疫苗和驱虫的到期通知在 iOS 上同样有「已完成」，点了会打开 App 再记下。iOS 最多保留 64 条待发送通知，应用只登记最近的 60 条。

## iOS

Bundle ID 是 `com.maokangji.maokangji`，和 Android 的包名一样。主屏幕显示名是「花爪」。部署目标 iOS 15.5。工程里没有 `DEVELOPMENT_TEAM`，没有描述文件，也没有把签名身份写死。`Runner.entitlements` 里写了 App Group，但没有挂到编译目标上，避免没有 Team ID 时签名失败。

依赖分两路：

- 有 Swift Package 的插件走 Swift Package Manager，工程里没有单独再声明。
- 蓝牙秤和 ML Kit 中文识别只有 CocoaPods。`ios/Podfile` 会装它们，并额外加上 `GoogleMLKit/TextRecognitionChinese`。不装这个中文模型，包装、化验单和疫苗贴纸在 iPhone 上认不出中文。在 Mac 上先 `flutter pub get`，再在 `ios/` 里 `pod install`，然后用 `ios/Runner.xcworkspace` 打开。`pod install` 会生成 `Podfile.lock`，生成后可以提交。

能和 Android 共用的功能（蓝牙秤、扫码、拍照、化验单、自定义猫粮、日历、余粮、健康卡）是同一套 Dart。权限说明已经按这些用途写进 `Info.plist`。日历页的「小组件显示待办 / 不显示」两端都生效。这些功能要在 Mac 上编译之后，才能在模拟器或真机上点。这里没有 iPhone 模拟器，没有真机点过。

蓝牙秤：iPhone 不能由 App 直接打开蓝牙开关。没开时，页面会请你先到控制中心打开再重试。只在前台扫描，没有后台模式。解析仍是按公开协议写的，没有用真秤测过。

长按图标的「称体重 / 记驱虫 / 扫粮」在 iOS 上使用模板图标，名字和 Android 的 drawable 相同。

桌面小组件：Android 已经能加。iOS 的界面在 `ios/TodayWidget/TodayWidget.swift`，整块可点，打开对应页面。它还不是 Xcode 目标。有付费开发者账号之后，在 Xcode 里新建 Widget Extension，换上这份源码，Runner 和扩展都打开 App Group `group.com.maokangji.maokangji`。免费 Apple ID 签不了 App Group，桌面上不会出现这个小组件。互动按钮要 iOS 17，当前不做。

在 Mac 上出包：

```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ios --simulator
```

模拟器包在 `build/ios/iphonesimulator/Runner.app`。模拟器已经启动时：

```bash
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
```

未签名真机包（不能装进模拟器，也不能直接装到手机）：

```bash
flutter build ios --no-codesign
```

产物在 `build/ios/iphoneos/Runner.app`。装到真机还要签名。

这台 Linux 上实际跑过 `flutter build ios` 和 `flutter build ios --no-codesign`。前者提示没有名为 ios 的子命令，后者提示没有 `--no-codesign` 这个选项。Flutter 只在 macOS 上注册这条命令。所以这里没有 `.app`，也没有 `.ipa`。

还需要你提供的，没有这些就停在源码，不假装已经能装：

| 要什么 | 用来做什么 |
| --- | --- |
| 一台 Mac 和 Xcode | 编译。Linux 编不了 iOS |
| Apple ID | 免费账号可以用 Xcode 自动签名，把主 App 装到自己的手机上，大约 7 天要重签 |
| 付费 Apple Developer Program | 小组件和 App Group 需要。上架 App Store 也需要 |
| Team ID | 填进 Xcode 的 Signing Team。工程里现在是空的 |
| 真机 UDID | 不用 Xcode 自动签名、或要做 Ad Hoc 安装包时要登记这台机器 |
| 开发或发布证书，以及描述文件 | 要在 Xcode 外面签名、或给别人安装时才单独导出。自动签名可以先不导出 |

拿到 Team ID 之后，在 Xcode 里选中 Runner 的 Team。要做小组件时再把 `ios/Runner/Runner.entitlements` 和 `ios/TodayWidget/TodayWidget.entitlements` 挂到对应目标。在那之前不要挂。

## 功能说明

1. **今天**：到期粮、疫苗、驱虫、体重异常。点一下就办完。粮还留在粮仓。疫苗和驱虫会把下次日期往后算。体重打开步进页，点保存。
2. **健康**：体重、疫苗、驱虫、就医、体检、看病六个格子。每个子页一屏，底部一个主按钮。品牌、疫苗、驱虫药、就医原因都是点选。日期点「今天 / 昨天 / 前天」，更早的用滚轮。体重页可以接蓝牙秤。
3. **粮仓**：已登记的粮和还剩几天。点进去可以标已吃完或删除。顶部搜索粮仓和猫粮库，右边相机扫条码。已经入库的直接打开，没入库的进确认。确认页点品牌和粮名，核对三个日期和开封天数，点「记下」。扫不到时仍可以拍包装、自己添加或选品牌。拍贴纸、自定义猫粮、自制鲜食和图鉴也从这里进。
4. **猫咪**：横滑头像切换，看照片、名字和体重。添加猫咪仍是一张照片加一个名字，这是唯一要打字的地方。
5. **体检和看病**：体检按年龄点选项目再点完成。看病点病名，能看到红灯和喂养，点记下记在这只猫身上。

首次启动会放入两只示例猫和两袋示例粮，方便直接看界面。删掉之后不会再自动加回来。

## 测试

- `test/gs1_parser_test.dart`：括号形式、GS 分隔符、连写日期、日为 `00`、AI 15、普通 EAN 不含日期
- `test/ocr_date_parser_test.dart`：中文日期、EXP、全角数字、保质期月数推算
- `test/reminder_planner_test.dart`：30/7 天保质期、已过期的不排、疫苗驱虫、开封倒计时
- `test/widget_test.dart`：免责声明和日期卡片
- `test/cjk_font_test.dart`：中文笔画被画出来，而不是缺字方框
- `test/screenshots_test.dart`：渲染主要页面，输出到 `/opt/cursor/artifacts/screenshots/v280/`
- `test/quick_input_test.dart`：日期胶囊、上次的驱虫产品和医院、今天页撤销
- `test/notification_actions_test.dart`：通知「已完成」、长按快捷方式
- `test/barcode_memory_test.dart`：GS1 与 EAN-13 归一、记住品牌、重启后仍认得
- `test/scale_parser_test.dart`：小米体脂秤 2、小米体重秤 1、标准 0x2A9D 的字节解析（kg / 斤 / 磅、稳定位、空秤、长度校验），以及抱猫称相减。样例帧按协议手工构造，不是真秤抓包
- `test/scale_flow_test.dart`：抱猫称流程、记住自己的体重、蓝牙没开、断开重试、超时退回手动
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
- 通知上的「已完成」会把花爪带到前台再记下，不是后台静默完成。
- 蓝牙秤没在真秤上测过。小米秤要先踩一下才会广播；单位是斤或磅时会自动换算成 kg。读数不对请用「手动输入」。
- 本仓库在 Linux 上验证了 `flutter analyze`、`flutter test` 和 Android 构建。iOS 工程和权限已经补上，但 Linux 编不出安装包，模拟器和真机都还没跑过。
- iPhone 桌面小组件只有源码，还没出现在桌面上。蓝牙秤不能由 App 打开系统开关，也不能在后台读。
- 云同步骨架已接上，默认没有令牌，界面仍只读写手机。短信、微信开放平台、OSS 和厂商推送都是接口，不是已经开通的账号。
