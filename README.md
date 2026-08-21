<div align="center">

# ☕ Refill

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=20&pause=1200&color=FBBF24&center=true&vCenter=true&width=600&lines=%E4%B8%BA+Homebrew+%E7%BB%AD%E6%9D%AF;Refill+your+Homebrew;%E7%A4%BE%E5%8C%BA%E9%A9%B1%E5%8A%A8%E7%9A%84+macOS+Cask+%E8%A1%A5%E5%85%85%E6%BA%90;%E5%AE%98%E6%96%B9%E6%9C%A8%E6%A1%B6%E6%B2%A1%E8%A3%85%E4%B8%8B%E7%9A%84%E5%A5%BD%E8%BD%AF%E4%BB%B6%EF%BC%8C%E8%AE%A9+Refill+%E7%BB%99%E4%BD%A0%E7%BB%AD%E6%BB%A1">
    <source media="(prefers-color-scheme: light)" srcset="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=20&pause=1200&color=B45309&center=true&vCenter=true&width=600&lines=%E4%B8%BA+Homebrew+%E7%BB%AD%E6%9D%AF;Refill+your+Homebrew;%E7%A4%BE%E5%8C%BA%E9%A9%B1%E5%8A%A8%E7%9A%84+macOS+Cask+%E8%A1%A5%E5%85%85%E6%BA%90;%E5%AE%98%E6%96%B9%E6%9C%A8%E6%A1%B6%E6%B2%A1%E8%A3%85%E4%B8%8B%E7%9A%84%E5%A5%BD%E8%BD%AF%E4%BB%B6%EF%BC%8C%E8%AE%A9+Refill+%E7%BB%99%E4%BD%A0%E7%BB%AD%E6%BB%A1">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=20&pause=1200&color=B45309&center=true&vCenter=true&width=600&lines=%E4%B8%BA+Homebrew+%E7%BB%AD%E6%9D%AF;Refill+your+Homebrew;%E7%A4%BE%E5%8C%BA%E9%A9%B1%E5%8A%A8%E7%9A%84+macOS+Cask+%E8%A1%A5%E5%85%85%E6%BA%90;%E5%AE%98%E6%96%B9%E6%9C%A8%E6%A1%B6%E6%B2%A1%E8%A3%85%E4%B8%8B%E7%9A%84%E5%A5%BD%E8%BD%AF%E4%BB%B6%EF%BC%8C%E8%AE%A9+Refill+%E7%BB%99%E4%BD%A0%E7%BB%AD%E6%BB%A1" alt="Refill Slogan Typing Animation" />
  </picture>
</p>

<p align="center">
  <a href="https://github.com/nasymonk/homebrew-refill">
    <img src="https://img.shields.io/badge/Homebrew-Tap-FBB040?style=for-the-badge&logo=homebrew&logoColor=white" alt="Homebrew Tap" />
  </a>
  <a href="https://github.com/nasymonk/homebrew-refill/actions/workflows/autobump.yml">
    <img src="https://img.shields.io/badge/CI-Hourly_Auto_Bump-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" alt="Hourly CI" />
  </a>
  <a href="https://github.com/nasymonk/homebrew-refill/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-44CC11?style=for-the-badge" alt="MIT License" />
  </a>
  <a href="https://github.com/nasymonk/homebrew-refill/pulls">
    <img src="https://img.shields.io/badge/PRs-Welcome-black?style=for-the-badge" alt="PRs Welcome" />
  </a>
</p>

> **“官方木桶（Cask）没装下的好软件，让 Refill 给你续杯。”**  
> 收录官方 `homebrew-cask` 未收录、且上游作者未自建 Tap 的优质 macOS 软件与独立工具。  
> 通过 GitHub Actions 每小时全自动巡检上游版本并同步更新，零人工滞后、告别断更。

</div>

---

## 核心特性

- ▸ **补充官方空白** — 专注收录主流中文软件、优质独立应用与常用开发客户端，填补官方生态空白。
- ▸ **每小时全自动巡检** — 云端 CI 实时追踪官网、GitHub Releases 及 Sparkle 动态，上游发版即自动挂载校验构建。
- ▸ **直连官方原源** — 所有安装包直连官方 OSS / CDN / GitHub，不经过第三方二次打包，严格计算并比对 SHA256 校验码。
- ▸ **纯净规范无残留** — 严格遵循 Homebrew Cask 语法规范，完整配置 `zap` 规则，深度卸载不留配置垃圾。

---

## 快速上手

### 1. 添加并信任 Tap

```bash
brew tap nasymonk/refill
brew trust nasymonk/refill   # Homebrew 4.x+ 首次添加第三方 Tap 建议执行
```

### 2. 安装软件

```bash
brew install --cask <软件名>
```

<details>
<summary><b>常用运维命令（升级、覆盖、深度卸载）</b></summary>

```bash
# 升级指定软件至最新版
brew upgrade --cask <软件名>

# 升级 Refill Tap 中的全部已安装软件
brew update && brew upgrade

# 强制接管已有应用（若 /Applications 中已存在手动安装的同名 App）
brew install --cask --force <软件名>

# 普通卸载
brew uninstall --cask <软件名>

# 深度卸载（彻底清除应用及其关联的 Library/Caches/Preferences 等配置残留）
brew uninstall --cask --zap <软件名>
```

</details>

---

## 收录软件清单

| 软件 (Cask) | 说明 | 架构支持 | 自动更新机制 | 官方主页 | 安装命令 |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **`iqiyi`** | 爱奇艺 macOS 官方高清视频客户端 | 通用 (Universal) | 官网下载页解析 + 镜像挂载校验 | [爱奇艺官网](https://app.iqiyi.com/mac/player/index.html) | `brew install --cask iqiyi` |
| **`buhocleaner`** | BuhoCleaner 专业 Mac 系统清理与优化工具 | 通用 (Universal) | Sparkle Appcast (XML Feed) | [Dr.Buho 官网](https://www.drbuho.com/buhocleaner) | `brew install --cask buhocleaner` |
| **`aio-coding-hub`** | 本地 AI 编程网关，统一代理多个 coding CLI | M系列 / Intel | GitHub Releases API 自动拉取 | [GitHub 仓库](https://github.com/dyndynjyxa/aio-coding-hub) | `brew install --cask aio-coding-hub` |

> *软件清单持续扩充中，若你常用的 Mac 软件在官方源找不到，欢迎提交申请。*

---

## 收录原则与申请

### 收录原则
1. **官方未收录**：官方 `homebrew/cask` 未收录，或官方源因规则限制难以收录/更新滞后。
2. **上游未自建 Tap**：软件作者或厂商自身没有提供和维护专属的 Homebrew Tap。
3. **来源合法正规**：仅收录官方公开发布的原生 macOS 软件（`.dmg` / `.zip` / `.pkg`），严禁破解、修改版或侵权软件。
4. **自动化可维护**：能够通过 GitHub Releases、Appcast、官网直链或网页特征编写 CI 自动化检测脚本。

### 申请收录
若有希望通过 Homebrew 管理但官方源尚未收录的 macOS 软件：  
[提交软件收录请求 ›](https://github.com/nasymonk/homebrew-refill/issues/new?template=software_request.yml)

---

## 参与贡献

非常欢迎社区贡献新的 Cask 或完善自动更新脚本。

### 添加新软件流程

1. **编写 Cask 文件**：在 `Casks/<软件名>.rb` 中编写标准的 Cask 定义（可参考现有软件）。
2. **编写自动更新脚本**：在 `scripts/bump-<软件名>.sh` 中编写上游版本检测与自动修改脚本，并在 `.github/workflows/autobump.yml` 添加步骤。
3. **本地验证与提交 PR**：
   ```bash
   # 测试安装与启动
   brew install --cask ./Casks/<软件名>.rb
   
   # 测试自动检测脚本
   bash scripts/bump-<软件名>.sh Casks/<软件名>.rb
   ```
   自测无误后提交 Pull Request 即可，CI 会自动接管后续的每小时巡检。

---

## 自动化更新架构

Refill 通过 GitHub Actions 每小时定时运行：

```text
┌────────────────────────────────────────────────────────┐
│ 上游官网 / GitHub Releases / Sparkle Appcast           │
└──────────────────────────┬─────────────────────────────┘
                           │ 每小时自动巡检
                           ▼
┌────────────────────────────────────────────────────────┐
│ 捕获版本号变更 / ETag 更新 / 解析页面                  │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 临时下载安装包提取版本并校验 SHA256                    │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│ 自动更新 Casks/*.rb 并提交推送到 main 分支             │
└────────────────────────────────────────────────────────┘
```

终端用户无需关注更新细节，日常只需 `brew upgrade` 即可时刻保持最新版本。

---

## 开源许可证

本项目基于 [MIT 许可证](LICENSE) 分发。所收录软件的版权与商标均归各自软件所有者所有。
