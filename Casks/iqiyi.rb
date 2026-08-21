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

  zap trash: [
    "~/Library/Application Support/com.iqiyi.player",
    "~/Library/Caches/com.iqiyi.player",
    "~/Library/Preferences/com.iqiyi.player.plist",
    "~/Library/Saved Application State/com.iqiyi.player.savedState",
  ]
end
