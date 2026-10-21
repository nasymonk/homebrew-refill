cask "arczip" do
  version "1.1.2"
  sha256 "2c21939e17be040527554cf4bd7e59f5b1b7e8d5877d0e2c0e661d5cc212d4e9"

  # 官方 Sparkle appcast 的 enclosure 即此 zip（根级 ArcZip.app，ditto 友好），
  # 版本/链接/sha 由 scripts/bump-arczip.sh 解析 appcast 改写。
  # appcast 同时给出 sparkle:shortVersionString 与 sparkle:version(构建号 232)，
  # cask 只跟短版本号，构建号仅供 bump 脚本挑选 item。
  url "https://download.arczip.app/releases/1.1.2/232/ArcZip-1.1.2-232.zip"
  name "ArcZip"
  desc "Archive extraction tool supporting zip, rar, 7z and more"
  homepage "https://arczip.app/"

  livecheck do
    url "https://download.arczip.app/appcast.xml"
    strategy :sparkle do |items|
      items.map(&:short_version)
    end
  end

  depends_on macos: :sonoma

  app "ArcZip.app"

  zap trash: [
    "~/Library/Application Support/com.maczhang.ArcZip",
    "~/Library/Caches/com.maczhang.ArcZip",
    "~/Library/HTTPStorages/com.maczhang.ArcZip",
    "~/Library/Preferences/com.maczhang.ArcZip.plist",
    "~/Library/Saved Application State/com.maczhang.ArcZip.savedState",
  ]
end
