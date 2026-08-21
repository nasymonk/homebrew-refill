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
> 通过 GitHub Actions **每小时全自动巡检上游并构建更新**，零人工滞后、告别断更。

</div>

---

## 快速上手

```bash
# 1. 接入并信任 Tap
brew tap nasymonk/refill
brew trust nasymonk/refill   # Homebrew 4.x+ 首次添加第三方 Tap 建议执行

# 2. 安装收录软件
brew install --cask <软件名>
```

<details>
<summary><b>常用运维命令（升级、覆盖、深度卸载）</b></summary>

```bash
# 升级指定软件至最新版
brew upgrade --cask <软件名>

# 升级 Refill 中的全部软件
brew update && brew upgrade

# 强制接管已有应用（若 /Applications 中已存在手动安装的同名 App）
brew install --cask --force <软件名>

# 深度卸载（彻底清除应用及其关联的 Library/Caches/Preferences 等配置残留）
brew uninstall --cask --zap <软件名>
```

</details>

---

## 收录清单

| 软件 (Cask) | 说明 | 架构支持 | 自动更新源 | 官方主页 | 一键安装命令 |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **`iqiyi`** | 爱奇艺 macOS 官方高清客户端 | 通用 (Universal) | 官网下载页 + 镜像挂载校验 | [爱奇艺官网](https://app.iqiyi.com/mac/player/index.html) | `brew install --cask iqiyi` |
| **`buhocleaner`** | BuhoCleaner 专业 Mac 清理优化工具 | 通用 (Universal) | Sparkle Appcast (XML Feed) | [Dr.Buho 官网](https://www.drbuho.com/buhocleaner) | `brew install --cask buhocleaner` |
| **`aio-coding-hub`** | 本地 AI 编程网关，统一代理 coding CLI | M系列 / Intel | GitHub Releases API 自动拉取 | [GitHub 仓库](https://github.com/dyndynjyxa/aio-coding-hub) | `brew install --cask aio-coding-hub` |

> *清单持续扩充中，若你常用的 Mac 软件在官方源找不到，欢迎提交申请。*

---

## 申请收录与贡献

欢迎推荐你常用的 Mac 软件，或直接提交 Pull Request 参与维护。

- **申请收录** — 若遇到官方源未收录的正规软件，欢迎 [提交软件收录请求 ›](https://github.com/nasymonk/homebrew-refill/issues/new?template=software_request.yml)
- **提交贡献** —
  1. 在 `Casks/<软件名>.rb` 添加标准 Cask 定义；
  2. 在 `scripts/bump-<软件名>.sh` 编写上游检测脚本并在 `autobump.yml` 注册；
  3. 本地验证 `brew install --cask ./Casks/<软件名>.rb` 后直接提交 PR，CI 会自动接管后续的每小时巡检构建。

---

## 许可证

本项目基于 [MIT 许可证](LICENSE) 分发。所收录软件的版权与商标均归各自软件所有者所有。
