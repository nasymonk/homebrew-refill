# Refill

个人 Homebrew tap。收录官方 `homebrew-cask` 未收录、落后于上游或无法直接安装的 macOS 软件。

全部 cask 由 GitHub Actions 的 macOS runner 定时巡检上游并自动 bump(cron 每小时触发,macOS runner 实测每天约 4~6 次)。

## 使用

```bash
brew tap nasymonk/refill
brew trust nasymonk/refill          # Homebrew 4.x+ 首次添加第三方 tap 建议执行

brew install --cask <cask>
```

```bash
brew upgrade --cask <cask>          # 升级单个
brew update && brew upgrade         # 升级全部
brew install --cask --force <cask>  # 强制接管 /Applications 中已有的同名 App
brew uninstall --cask --zap <cask>  # 深度卸载,清除 Library 残留
```

## 收录清单

| Cask | 软件 | 架构 | 上游版本源 | 主页 |
| :--- | :--- | :---: | :--- | :--- |
| `arczip` | ArcZip | Universal | Sparkle appcast | [链接](https://arczip.app/) |
| `buhocleaner` | BuhoCleaner | Universal | Sparkle appcast | [链接](https://www.drbuho.com/buhocleaner) |
| `deepseek-harness` | DeepSeek Harness | arm64 | 官方 electron-builder YAML | [链接](https://www.deepseek.com/harness/) |
| `iqiyi` | 爱奇艺 | Universal | 官方固定 URL 原地覆写、按地域分发;CI 经 ACS 取包重打成 zip 镜像 | [链接](https://app.iqiyi.com/mac/player/index.html) |
| `qoder` | Qoder(国际版) | arm64 / Intel | 官方更新接口 + OSS 校验 | [链接](https://qoder.com/) |
| `qoder-cn` | Qoder(国内版) | arm64 / Intel | `static.qoder.com.cn` 的 `latest-mac.yml` | [链接](https://qoder.com.cn/) |
| `qoder-ide` | Qoder IDE | arm64 / Intel | 官方更新接口 + OSS 校验 | [链接](https://qoder.com/) |
| `workbuddy` | WorkBuddy | arm64 / Intel | CodeBuddy `/v2/update` 接口 | [链接](https://www.workbuddy.cn/) |

## 更新机制

- **直链型**(`arczip`、`buhocleaner`、`deepseek-harness`、`qoder`、`qoder-cn`、`qoder-ide`、`workbuddy`):上游本身就是 zip 或可正常挂载的 DMG。CI 比对版本后改写 `version` / `sha256`,安装时直接从官方地址下载。
- **重打包镜像型**(`iqiyi`):官方 DMG 在 macOS 26/27 上无法被 Homebrew 直接安装(未签名镜像、只读卷清理 `.DS_Store`),且同一固定 URL 会按地域分发不同构建。因此 CI 先经国内 ACS 取回 DMG 再传回 runner,挂载读取 App Bundle 得到国内用户实际能拿到的版本,校验签名/公证后用 `ditto` 重打成 zip,SSH 上传到 ACS(`https://doc.rootfly.xyz/refill/<cask>/`),cask 指向该镜像——安装时 Homebrew 解 zip 走 `ditto`,不碰 `hdiutil`。

巡检失败可见:每个 cask 由 `scripts/run-bump.sh` 包装执行,单个失败不阻塞其余,但会记入 Job summary 的「cask / 结果 / 详情」表;任一 cask 失败则本次 autobump 变红(`scripts/finish-bump.sh`)。

重打包型需要 CI 能 SSH 到 ACS:私钥在仓库 Secret `ACS_SSH_KEY`(不入库),公钥在 ACS 的 `authorized_keys`。未配置该 Secret 的 fork 会跳过该 cask。ACS 上每个 cask 只保留最近 2 个历史 zip 以便回滚。

## App Store 专属软件(非 Cask)

以下软件只通过 Mac App Store 分发,没有 DMG/ZIP 直链,cask 的 `url` 无处可指;MAS 包带 DRM,也不能像 `iqiyi` 那样重打镜像。

唯一通路是 `mas`,但它在 Homebrew 7 下也走不通:cask 安装步骤被关进沙箱(HOME 换临时目录、禁读真实 home、默认断网、切断 XPC 与 LaunchServices),实测 `mas list` / `mas get` 永久挂起,`/usr/bin/open` 报 `Code=-10810 Couldn't communicate with a helper application`,而 `HOMEBREW_NO_SANDBOX_CASK` 已废弃。因此这类软件只登记、不提供 cask,装请用终端自行跑 `mas`:

```bash
brew install mas          # 首次,安装 App Store 命令行工具
mas get <App Store ID>    # 下载并装到 /Applications(幂等,已装仅提示 Already got)
```

| 软件 | 说明 | App Store ID | 安装命令 |
| :--- | :--- | :--- | :--- |
| AndroMeld | 在 Mac 上使用 Android App、传文件、接电话、同步剪贴板(bundle ID `com.catchingnow.andfiles`,需 macOS 15+) | `6762439757` | `mas get 6762439757` |

核对最新版本(无需登录):

```bash
curl -fsSL 'https://itunes.apple.com/lookup?id=6762439757&country=cn' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["results"][0]["version"])'
```

## 新增 cask

1. 在 `Casks/<name>.rb` 添加标准 cask 定义。
2. 在 `scripts/bump-<name>.sh` 编写上游检测脚本,并注册进 `.github/workflows/autobump.yml`,用 `bash scripts/run-bump.sh <name> bash scripts/bump-<name>.sh Casks/<name>.rb` 调用(以保留巡检汇总)。
   - 上游若是新版 macOS 上无法直接安装的 DMG,参考 `scripts/bump-iqiyi.sh`(ACS 取包 → 挂载 → `ditto` 重打成 zip → SSH 上传镜像)。
   - Sparkle appcast 既支持 enclosure 属性式 `sparkle:version="..."`,也支持子元素式 `<sparkle:version>...</sparkle:version>`,解析脚本需兼容两者(见 `scripts/bump-arczip.sh`)。
3. 本地验证 `brew install --cask ./Casks/<name>.rb` 与 `brew uninstall --cask --zap <name>`(确认 zap 路径完整)后提交 PR。

## 许可证

本项目基于 [MIT 许可证](LICENSE) 分发。所收录软件的版权与商标归各自所有者所有。
