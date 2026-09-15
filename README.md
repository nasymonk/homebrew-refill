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
> 收录官方 `homebrew-cask` 未收录、落后或无法直接安装的优质 macOS 软件。  
> 全部软件均通过 GitHub Actions 的 **macOS runner 每小时全自动巡检上游并构建更新**；
> 其中 `doubao`、`iqiyi` 这类官方 DMG 在 macOS 26/27 上无法被 Homebrew 直接安装的软件，
> 会由 CI 挂载 DMG、重打成 zip 并镜像到自有服务器（ACS），无需本机参与。

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

| 软件 (Cask) | 说明 | 架构支持 | 自动更新源 / 巡检方式 | 官方主页 | 一键安装命令 |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **`doubao`** | 豆包电脑版 · 字节跳动 AI 助手 | 通用 (Universal) | 官方分发接口检测；官方 DMG 未签名，CI 重打包为 zip 镜像到 ACS（每小时） | [豆包官网](https://www.doubao.com/chat/) | `brew install --cask nasymonk/refill/doubao` ¹ |
| **`iqiyi`** | 爱奇艺 macOS 官方高清客户端 | 通用 (Universal) | 官方固定 URL DMG 原地覆写；CI 挂载取版本并重打包 zip 镜像到 ACS（每小时） | [爱奇艺官网](https://app.iqiyi.com/mac/player/index.html) | `brew install --cask iqiyi` |
| **`qoder`** | Qoder 阿里 AI 编程平台 · 国际版 | M系列 / Intel | 更新接口 + OSS 校验（CI 每小时） | [Qoder 官网](https://qoder.com/) | `brew install --cask qoder` |
| **`qoder-cn`** | Qoder 阿里 AI 编程平台 · 国内版 | M系列 / Intel | 阿里云 OSS `latest-mac.yml`（CI 每小时） | [Qoder 国内官网](https://qoder.com.cn/) | `brew install --cask qoder-cn` |
| **`qoder-ide`** | Qoder IDE 阿里 AI 编程 IDE | M系列 / Intel | 更新接口 + OSS 校验（CI 每小时） | [Qoder 官网](https://qoder.com/) | `brew install --cask qoder-ide` |
| **`workbuddy`** | WorkBuddy 腾讯 AI 办公助手 | M系列 / Intel | CodeBuddy 更新接口（CI 每小时） | [WorkBuddy 官网](https://www.workbuddy.cn/) | `brew install --cask workbuddy` |
| **`buhocleaner`** | BuhoCleaner 专业 Mac 清理优化工具 | 通用 (Universal) | Sparkle Appcast (XML Feed)（CI 每小时） | [Dr.Buho 官网](https://www.drbuho.com/buhocleaner) | `brew install --cask buhocleaner` |

> ¹ 官方 `homebrew-cask` 也有一个同名但严重滞后的 `doubao`（其声明 `auto_updates true` 被官方自动更新机器人跳过）。为避免歧义，安装/升级本 Tap 的豆包请使用全限定名 `nasymonk/refill/doubao`。
>
> *清单持续扩充中，若你常用的 Mac 软件在官方源找不到，欢迎提交申请。*

---

## 更新机制

所有 cask 由 GitHub Actions 的 **macOS runner 每小时**巡检一次，分两类：

- **直链型**（`qoder`、`qoder-cn`、`qoder-ide`、`workbuddy`、`buhocleaner`）：上游本就是 zip 或可正常挂载的 DMG，CI 只比对版本、改写 `version/sha256` 后提交，安装时直接从官方地址下载。
- **重打包镜像型**（`doubao`、`iqiyi`）：官方安装包是 DMG，在 macOS 26/27 上 Homebrew 会因「未签名镜像」或「只读卷清理 .DS_Store」而安装失败。CI 会挂载官方 DMG、校验签名/公证后用 `ditto` 把 `.app` 重打成 zip，经 SSH 上传到自有 ACS（`https://doc.rootfly.xyz/refill/<cask>/`），cask 指向该 zip——Homebrew 解 zip 走 ditto，全程不碰 `hdiutil`。

> 重打包型需要 CI 能 SSH 到 ACS：私钥存放在仓库 Secret `ACS_SSH_KEY`（**不入库**），公钥放在 ACS 的 `authorized_keys`。未配置该 Secret 的 fork 会自动跳过这两个 cask，不影响其余软件。ACS 上每个 cask 仅保留最近 2 个历史 zip 以便回滚。

---

## 申请收录与贡献

欢迎推荐你常用的 Mac 软件，或直接提交 Pull Request 参与维护。

- **申请收录** — 若遇到官方源未收录的正规软件，欢迎 [提交软件收录请求 ›](https://github.com/nasymonk/homebrew-refill/issues/new?template=software_request.yml)
- **提交贡献** —
  1. 在 `Casks/<软件名>.rb` 添加标准 Cask 定义；
  2. 在 `scripts/bump-<软件名>.sh` 编写上游检测脚本并注册进 `.github/workflows/autobump.yml`，由 CI 的 macOS runner 每小时巡检；若官方是在新版 macOS 上无法直接安装的 DMG，参考 `scripts/bump-doubao.sh` / `scripts/bump-iqiyi.sh`：CI 挂载 DMG → `ditto` 重打成 zip → 经 SSH 上传到 ACS 镜像（SSH 私钥存于仓库 Secret `ACS_SSH_KEY`，不入库），cask 指向镜像 zip；
  3. 本地验证 `brew install --cask ./Casks/<软件名>.rb` 后直接提交 PR，CI 会自动接管后续的每小时巡检构建。

---

## 许可证

本项目基于 [MIT 许可证](LICENSE) 分发。所收录软件的版权与商标均归各自软件所有者所有。
