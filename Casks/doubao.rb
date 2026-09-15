cask "doubao" do
  # macOS 26/27 上 hdiutil 无法挂载官方未签名 DMG，改用自托管 zip（universal）；
  # 更新由 scripts/bump-doubao.sh 重打包并上传 ACS 后改写（CI macOS runner 定时巡检）。
  version "2.29.10"
  sha256 "792fd3da95a36cfc5a063a6f0a7302e4f4f093a834a79703cb774f8ceb63cf77"

  url "https://doc.rootfly.xyz/refill/doubao/Doubao_universal_#{version}.zip"
  name "豆包"
  name "Doubao"
  desc "AI chat assistant"
  homepage "https://www.doubao.com/chat/"

  livecheck do
    url "https://www.doubao.com/service/settings/v3/?device_platform=web&brand=doubao&aid=582465"
    strategy :json do |json|
      json.dig("data", "settings", "saman_update_address", "version")
    end
  end

  auto_updates true
  depends_on macos: :big_sur

  app "Doubao.app"

  # 2026-09-01 实测补充 *.browser（内置浏览器）残留
  zap trash: [
    "~/Library/Application Scripts/com.bot.pc.doubao.FinderSyncExtension",
    "~/Library/Application Support/Doubao",
    "~/Library/Caches/com.bot.pc.doubao",
    "~/Library/Caches/com.bot.pc.doubao.browser",
    "~/Library/Caches/Doubao",
    "~/Library/Containers/com.bot.pc.doubao.FinderSyncExtension",
    "~/Library/HTTPStorages/com.bot.pc.doubao",
    "~/Library/HTTPStorages/com.bot.pc.doubao.browser",
    "~/Library/Preferences/com.bot.pc.doubao.browser.plist",
    "~/Library/Preferences/com.bot.pc.doubao.helper.plist",
    "~/Library/Preferences/com.bot.pc.doubao.plist",
  ]
end
