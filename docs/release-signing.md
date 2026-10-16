# 发布签名

上架华为、小米、OPPO、vivo、应用宝的安装包必须用你自己的上传密钥签名。丢失这个密钥后，不能给同一个应用发更新。

仓库不保存密钥。`android/key.properties`、`*.jks`、`*.keystore` 已在 `.gitignore` 里。没有这份配置时，release 包仍用 debug 签名，只能自己安装，不能提交商店。

## 在 Windows 上生成

安装 Android Studio 后，用它自带的 `keytool`。下面的路径按自己的用户名改。

```bat
mkdir %USERPROFILE%\keystores
"%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\keytool.exe" -genkeypair -v -keystore %USERPROFILE%\keystores\roudianben-upload.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias roudianben
```

如果这台电脑没有 `cmdline-tools`，可以用 Android Studio 里的：

```bat
"%PROGRAMFILES%\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v -keystore %USERPROFILE%\keystores\roudianben-upload.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias roudianben
```

命令会问两项密码（库密码、密钥密码）以及姓名。姓名可以填「花爪」。密码请记在密码管理器里，不要写进聊天记录或仓库。

有效期 10000 天，大约 27 年。商店要求上传密钥长期不变。

## 告诉 Gradle

把 `android/key.properties.example` 复制为 `android/key.properties`，改成实际密码和路径。路径里的反斜杠要写成 `\\`。

```properties
storePassword=你的库密码
keyPassword=你的密钥密码
keyAlias=roudianben
storeFile=C:\\Users\\你的用户名\\keystores\\roudianben-upload.jks
```

然后在项目根目录打正式包：

```bat
flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons
```

有 `key.properties` 时用上传密钥签名；没有时仍回退到 debug 签名。

确认签名不是 debug：

```bat
"%LOCALAPPDATA%\Android\Sdk\build-tools\36.0.0\apksigner.bat" verify --print-certs build\app\outputs\flutter-apk\app-release.apk
```

证书主体应包含你在 `keytool` 里填的姓名，而不是 `CN=Android Debug`。

## 备份

请同时留下这三样，并分开存放（例如一块离线 U 盘和密码管理器）：

1. `roudianben-upload.jks` 文件本身
2. 库密码 `storePassword`
3. 密钥密码 `keyPassword` 和别名 `roudianben`

只备份 jks、不备份密码，等于没有备份。不要把 jks 放进本仓库，不要发到聊天软件的普通文件传输。换电脑时复制 jks，并在新电脑上重建 `android/key.properties`。

各商店后台如果还要求「应用签名密钥」由商店保管（华为应用市场、小米的签名方案），上传的是用这个 upload key 签过的 APK 或 AAB。更新时必须用同一把 upload key。
