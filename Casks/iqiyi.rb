cask "iqiyi" do
  version "17.8.0"
  sha256 "a312b5da007508d1f3d78565429490d558fab93f07cc1f28463898dfba8d1981"

  # URL 文件名固定为 (iQIYIMedia_271.dmg),与版本号无关(271 为品牌谐音),
  # 升级由 scripts/bump-iqiyi.sh 抓下载页与包体校验后改写。
  url "https://static-d.iqiyi.com/ext/common/iQIYIMedia_271.dmg"
  name "爱奇艺"
  name "iQIYI"
  desc "Video streaming player"
  homepage "https://app.iqiyi.com/mac/player/index.html"

  livecheck do
    url "https://app.iqiyi.com/mac/player/index.html"
    regex(/v?(\d+(?:\.\d+)+)/i)
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
