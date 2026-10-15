# Git 工作流

肉垫本的主仓是 GitHub 私有仓库 [huakan88/zhuaji](https://github.com/huakan88/zhuaji)。提交、附注标签和安装包说明都以这个仓库为准。

```bash
git clone https://github.com/huakan88/zhuaji.git
```

克隆之后 `origin` 指向 GitHub。分支和附注标签都推到这个 remote。

`main` 是可发布线，`develop` 是日常集成线。

## 分支

| 分支 | 用途 |
| --- | --- |
| `main` | 可发布。只接受合并，不直接提交功能 |
| `develop` | 日常集成。功能和修复先合并到这里 |
| `feature/<短名>` | 新功能，从 `develop` 拉出 |
| `fix/<短名>` | 缺陷修复，从 `develop` 拉出。线上紧急修复从 `main` 拉出，修完后同时合并回 `main` 和 `develop` |
| `release/x.y.z` | 发版准备，从 `develop` 拉出。只改版本号、变更说明和发版前必须修的问题 |

```bash
git checkout develop
git pull origin develop
git checkout -b feature/pantry-notes
```

功能做完后合并进 `develop`。确认要发布时，从 `develop` 拉 `release/x.y.z`，再把这条发布分支合并进 `main`。合并之后把 `main` 合回 `develop`，避免两边分叉。

## 提交说明

使用 [Conventional Commits](https://www.conventionalcommits.org/)。类型只用这六个：

- `feat`：新功能
- `fix`：缺陷修复
- `docs`：只改文档
- `chore`：工具、忽略规则、依赖等杂项
- `refactor`：不改行为的结构调整
- `test`：只改测试

```text
feat: 记下开封后的剩余天数

fix(pantry): 已吃完的粮不再出现在今天

docs: 补充本机启动 API 的步骤

chore: 忽略本地密钥和安装包

refactor(sync): 把冲突比较收成一个函数

test: 覆盖更旧的墓碑不能盖掉新记录
```

第一行用中文或英文都可以，类型必须是上面六个之一。需要范围时写成 `fix(health): …`。

仓库里有 `tool/git-hooks/commit-msg`，不依赖 Node。在克隆后执行一次：

```bash
git config core.hooksPath tool/git-hooks
```

之后不符合上面格式的提交说明会被拦住。合并提交和以 `Revert` 开头的说明会放行。

## 版本和标签

版本号写在根目录 `pubspec.yaml` 的 `version`，格式是 `x.y.z+build`。`x.y.z` 是对外版本，`+` 后面是 Android `versionCode`。

发版顺序：

1. 从 `develop` 拉出 `release/x.y.z`。
2. 先改 `pubspec.yaml` 的版本号，再做发版前的检查。
3. 把 `release/x.y.z` 合并进 `main`。
4. 在 `main` 上打附注标签，标签名与 `pubspec` 的三段版本一致，不带 `+build`。

```bash
git checkout main
git pull origin main
git tag -a v2.3.0 -m "肉垫本 2.3.0"
git push origin v2.3.0
```

已经打过的标签不要移动。下一次发版用新的 `vX.Y.Z`。

## 持续集成

基础检查在 `.github/workflows/ci.yml`：`flutter analyze` 和 `flutter test`，另外跑 `server/` 与 `packages/zhuaji_sync` 的 `dart test`。推送到 GitHub 的 `main`、`develop`、`release/**`，或打开拉取请求时会跑这份工作流。CircleCI 读的是 `.circleci/config.yml`，需要的话再加，不在这一份里。
