cask "doubao" do
  # 2026-08-31: macOS 27 上 hdiutil 无法挂载官方未签名 DMG，改用自托管 zip（universal）
  version "2.19.9"
  sha256 "4b045c19700f3046be942c251be880ce15c143ac0f6c3650f81e51ad2a717d7e"

  url "https://doc.rootfly.xyz/doubao-work/Doubao_universal_#{version}.zip"

  name "豆包"
  name "Doubao"
  desc "AI chat assistant"
  homepage "https://www.doubao.com/chat/"

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
