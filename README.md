# ☕ Refill

<p align="center">
  <b>为 Homebrew 续杯 · 社区驱动的 macOS Cask 补充源</b><br>
  <i>Refill your Homebrew — A community-driven tap for missing macOS apps.</i>
</p>

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
  <b>官方木桶（Cask）没装下的好软件，让 Refill 给你续满。</b><br>
  收录官方 <code>homebrew-cask</code> 未收录、且上游作者未自建 Tap 的优质 macOS 软件与独立工具。<br>
  由 GitHub Actions <b>每小时全自动检测上游版本并同步更新</b>，零人工滞后、告别断更。
</p>

---

## 🌟 为什么选择 Refill？

- ☕ **官方之外，随时续杯**：专注收录官方 Homebrew 门槛未覆盖的主流中文软件、独立开发者精品工具与常用客户端。
- ⚡ **每小时自动巡检**：云端 CI 实时追踪官网/Release/Appcast 动态，上游发版即自动挂载校验构建，无需手动催更。
- 🛡️ **安全直连上游**：所有安装包直接拉取自官方 OSS / CDN / GitHub，不经过任何第三方二次打包，严格校验 SHA256。
- 🧹 **纯净规范无残留**：严格遵守 Homebrew Cask 语法规范，完整配置 `zap` 规则，卸载时不留冗余配置垃圾。

---

## 🚀 快速开始

### 1. 添加 Tap

```bash
brew tap nasymonk/tap
brew trust nasymonk/tap   # Homebrew 4.x+ 首次添加第三方 Tap 建议执行
```

### 2. 安装软件

```bash
brew install --cask <软件名>
```

<details>
<summary><b>📖 常用操作指南（升级、覆盖、深度卸载）</b></summary>

```bash
# 升级指定软件至最新版
brew upgrade --cask <软件名>

# 升级当前 Tap 中的所有软件
brew update && brew upgrade

# 强制接管已有应用（若 /Applications 中已存在同名手动安装的 App）
brew install --cask --force <软件名>

# 普通卸载
brew uninstall --cask <软件名>

# 深度卸载（彻底清除应用及其 Library/Caches/Preferences 等配置残留）
brew uninstall --cask --zap <软件名>
```

</details>

---

## 📦 现有收录软件 (Catalog)

| 软件名称 (Cask) | 功能说明 | 架构支持 | 自动更新机制 | 上游官网 | 一键安装命令 |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **`iqiyi`** | 爱奇艺 macOS 官方高清视频播放客户端 | Universal | 官网下载页解析 + 镜像挂载校验 | [app.iqiyi.com](https://app.iqiyi.com/mac/player/index.html) | `brew install --cask iqiyi` |
| **`buhocleaner`** | BuhoCleaner 优质 Mac 系统清理与优化工具 | Universal | Sparkle Appcast (XML Feed) | [drbuho.com](https://www.drbuho.com/buhocleaner) | `brew install --cask buhocleaner` |
| **`aio-coding-hub`** | 本地 AI 网关，统一代理多个 coding CLI | Apple Silicon / Intel | GitHub Releases API 自动拉取 | [GitHub](https://github.com/dyndynjyxa/aio-coding-hub) | `brew install --cask aio-coding-hub` |

> 💡 *软件持续收录扩充中，欢迎提交你常用的 macOS 工具！*

---

## 🙋‍♂️ 软件收录原则与申请

### 收录原则
1. **官方未收录**：官方 `homebrew/cask` 未收录，或官方源因规则限制难以维护/更新滞后。
2. **上游未自建 Tap**：软件作者或厂商自身没有提供和维护官方 Tap。
3. **来源合法正规**：仅收录官方公开发布的原生 macOS 软件（`.dmg` / `.zip` / `.pkg`），严禁破解、修改版或侵权软件。
4. **自动化可维护**：能够通过 GitHub Releases、Appcast、官网直链或网页特征编写 CI 自动检测脚本。

### 申请收录
如果您有想通过 Homebrew 管理但官方源没有的 macOS 软件：  
👉 **[点击提交软件收录请求](https://github.com/nasymonk/homebrew-tap/issues/new?template=software_request.yml)**

---

## 🤝 参与贡献 (Contributing)

非常欢迎社区贡献新的 Cask 或完善自动更新逻辑！

### 添加新软件三步法：

1. **编写 Cask 文件**：在 `Casks/<name>.rb` 中编写标准的 Cask 定义（可参考现有案例）。
2. **配置自动更新脚本**：在 `scripts/bump-<name>.sh` 编写上游版本检测脚本，并在 `.github/workflows/autobump.yml` 中添加定时任务。
3. **本地测试与提交 PR**：
   ```bash
   # 测试安装
   brew install --cask ./Casks/<name>.rb
   
   # 测试自动检测脚本
   bash scripts/bump-<name>.sh Casks/<name>.rb
   ```
   测试通过后提交 Pull Request 即可，CI 将接管后续的版本巡检与自动构建！

---

## ⚙️ 自动更新机制

Refill 通过 GitHub Actions（`.github/workflows/autobump.yml`）每小时定时运行：
```
 上游官网 / GitHub Releases / Sparkle Appcast 
                     │ (每小时检测)
                     ▼
       捕获版本号变更 / ETag 更新 / 解析页面
                     │
                     ▼
      临时下载安装包提取版本并校验 SHA256
                     │
                     ▼
       自动更新 Casks/*.rb 并提交推送到 main 分支
```
终端用户无需关注更新细节，日常只需 `brew upgrade` 即可时刻享用最新版本。

---

## 📄 开源许可证

本项目基于 [MIT 许可证](LICENSE) 分发。所收录软件的版权与商标均归各自软件所有者所有。
