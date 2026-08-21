# 🍏 Community Homebrew Tap for macOS

<p align="center">
  <a href="https://github.com/nasymonk/homebrew-tap/actions/workflows/autobump.yml">
    <img src="https://github.com/nasymonk/homebrew-tap/actions/workflows/autobump.yml/badge.svg" alt="autobump status" />
  </a>
  <a href="https://github.com/nasymonk/homebrew-tap/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT" />
  </a>
  <a href="https://github.com/nasymonk/homebrew-tap/issues">
    <img src="https://img.shields.io/github/issues/nasymonk/homebrew-tap" alt="Open Issues" />
  </a>
  <a href="https://github.com/nasymonk/homebrew-tap/pulls">
    <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome" />
  </a>
</p>

<p align="center">
  <b>专注填补官方生态空白的 macOS 社区驱动 Homebrew Cask 源</b><br>
  收录官方 <code>homebrew-cask</code> 未收录、且上游作者未自建 tap 的优质软件与工具。<br>
  由 GitHub Actions <b>每小时全自动检测上游版本并同步更新</b>，告别断更与手动维护。
</p>

---

## 🌟 核心特色

- 🧩 **填补官方空白**：专注收录官方 Homebrew 门槛未覆盖、中文特色应用、独立开发者精品工具。
- ⚡ **每小时自动巡检**：云端 CI 实时追踪官网/Release/Appcast 动态，上游发版即自动构建校验提交，零人工滞后。
- 🛡️ **安全直连上游**：所有安装包直连官方 OSS / CDN / GitHub，不经过任何第三方二次打包，严格计算并比对 SHA256 校验码。
- 🧹 **规范与干净**：遵循 Homebrew Cask 官方命名与语法规范，完整配置 `zap` 规则，卸载无残留。

---

## 🚀 快速开始

### 1. 添加 Tap

```bash
brew tap nasymonk/tap
brew trust nasymonk/tap   # Homebrew 4.x+ 首次使用第三方 tap 时建议执行
```

### 2. 安装软件

```bash
brew install --cask <cask-name>
```

<details>
<summary><b>📖 常用操作指南（升级、强制覆盖、深度卸载）</b></summary>

```bash
# 升级指定软件至最新版
brew upgrade --cask <cask-name>

# 升级当前 Tap 中的所有软件
brew update && brew upgrade

# 强制接管已有应用（若 /Applications 中已存在同名手动安装的 App）
brew install --cask --force <cask-name>

# 普通卸载
brew uninstall --cask <cask-name>

# 深度卸载（清除应用及其所有 Library/Caches/Preferences 等配置文件）
brew uninstall --cask --zap <cask-name>
```

</details>

---

## 📦 现有收录软件

| 软件名称 (Cask) | 功能说明 | 架构支持 | 自动更新机制 | 上游官网 | 一键安装命令 |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **`iqiyi`** | 爱奇艺 macOS 官方高清视频客户端 | Universal | 官网下载页解析 + 镜像包挂载校验 | [app.iqiyi.com](https://app.iqiyi.com/mac/player/index.html) | `brew install --cask iqiyi` |
| **`buhocleaner`** | BuhoCleaner 优质 Mac 系统清理与优化工具 | Universal | Sparkle Appcast (XML Feed) | [drbuho.com](https://www.drbuho.com/buhocleaner) | `brew install --cask buhocleaner` |
| **`aio-coding-hub`** | 本地 AI 网关，统一代理多个 coding CLI | Apple Silicon / Intel | GitHub Releases API 自动拉取 | [GitHub](https://github.com/dyndynjyxa/aio-coding-hub) | `brew install --cask aio-coding-hub` |

> 💡 *软件持续收录中，欢迎提交你常用的 macOS 工具！*

---

## 🙋‍♂️ 软件收录原则与申请

### 收录原则
1. **官方未收录**：官方 `homebrew/cask` 未收录，或官方源因规则限制难以维护/更新滞后。
2. **上游未自建 Tap**：软件作者或厂商自身没有提供维护官方 Tap。
3. **来源合法正规**：仅收录官方公开发布的原生 macOS 软件（`.dmg` / `.zip` / `.pkg`），不收录破解、修改版或侵权软件。
4. **自动化可维护**：能够通过 GitHub Releases、Appcast、官网直链或网页特征编写 CI 自动更新脚本。

### 申请收录
如果您有想通过 Homebrew 管理但官方源没有的 macOS 软件：
👉 **[点击此处提交软件收录请求 (Software Request)](https://github.com/nasymonk/homebrew-tap/issues/new?template=software_request.yml)**

---

## 🤝 参与贡献 (Contributing)

非常欢迎社区贡献新的 Cask 或完善自动更新逻辑！

### 添加新软件三步法：

1. **编写 Cask 文件**：在 `Casks/<name>.rb` 中编写标准的 Cask 定义（参考现有案例）。
2. **配置自动更新脚本**：在 `scripts/bump-<name>.sh` 编写上游版本检测脚本，并在 `.github/workflows/autobump.yml` 添加定时任务。
3. **本地测试与提交 PR**：
   ```bash
   # 测试安装
   brew install --cask ./Casks/<name>.rb
   
   # 测试自动检测脚本
   bash scripts/bump-<name>.sh Casks/<name>.rb
   ```
   测试通过后提交 Pull Request 即可，CI 会自动接管后续的版本巡检与构建！

---

## ⚙️ 自动化巡检机制说明

本仓库通过 GitHub Actions（`.github/workflows/autobump.yml`）每小时定时运行：
```
 上游官网 / GitHub / Appcast 
            │ (每小时检测)
            ▼
 捕获版本号变更 / ETag 更新 / 解析页面
            │
            ▼
 临时下载 DMG / ZIP 提取实际版本并计算 SHA256
            │
            ▼
 自动更新 Casks/*.rb 并提交推送到 main 分支
```
终端用户无需关注更新细节，日常只需 `brew upgrade` 即可时刻享用最新版本。

---

## 📄 开源许可证

本项目基于 [MIT 许可证](LICENSE) 分发。所收录软件的版权与商标均归各自软件所有者所有。
