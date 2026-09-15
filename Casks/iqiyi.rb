cask "iqiyi" do
  version "17.8.5"
  sha256 "8938a9f744caccca6fdcd600f45b28a3be7927e8043e33086770d43f8968b181"

  # 官方是“固定 URL 原地覆写”的 DMG（iQIYIMedia_271.dmg，271 为品牌谐音），且 macOS 26/27 上
  # Homebrew 暂存只读 DMG 会因清理 .DS_Store 报 Read-only file system 而装不上。故由
  # scripts/bump-iqiyi.sh 挂载官方 DMG、取 .app 重打成 zip 托管到 ACS（CI macOS runner 每小时巡检）。
  url "https://doc.rootfly.xyz/refill/iqiyi/iQIYI_#{version}.zip"
  name "爱奇艺"
  name "iQIYI"
  desc "Video streaming player"
  homepage "https://app.iqiyi.com/mac/player/index.html"

  # 下载页静态文案可能滞后于“固定 URL 原地覆写”的 DMG（曾出现页面标 17.8.0、DMG 实为 17.8.5）；
  # 权威版本以 scripts/bump-iqiyi.sh 挂载 DMG 读到的 CFBundleShortVersionString 为准（CI 每小时巡检）。
  # 正则锚定 macOS 区块，避免误匹配页面上 Windows/手机等无关版本号（旧正则曾误报 92.8）。
  livecheck do
    url "https://app.iqiyi.com/mac/player/index.html"
    regex(/meta-macos.*?computer-download-meta-ver">\s*v?(\d+(?:\.\d+)+)/im)
    strategy :page_match
  end

  app "爱奇艺.app"

  # 2026-09-01 实测：爱奇艺为沙盒应用，残留全在 Containers/Application Scripts，
  # 旧的 Application Support/Caches 猜测路径不存在（仅保留 plist 一条以备偏好域）。
  zap trash: [
    "~/Library/Application Scripts/com.iqiyi.player",
    "~/Library/Application Scripts/com.iqiyi.player.QYUserNotification",
    "~/Library/Containers/com.iqiyi.player",
    "~/Library/Containers/com.iqiyi.player.QYUserNotification",
    "~/Library/Preferences/com.iqiyi.player.plist",
    "~/Library/Saved Application State/com.iqiyi.player.savedState",
  ]
end
