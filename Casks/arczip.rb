cask "arczip" do
  version "1.1.3"
  sha256 "0eb504882f37d7f12982c7c34f842f5a4585371aad007915ef3758ce1a365d7c"

  # 官方 Sparkle appcast 的 enclosure 即此 zip（根级 ArcZip.app，ditto 友好），
  # 版本/链接/sha 由 scripts/bump-arczip.sh 解析 appcast 改写。
  # appcast 同时给出 sparkle:shortVersionString 与 sparkle:version(构建号 232)，
  # cask 只跟短版本号，构建号仅供 bump 脚本挑选 item。
  url "https://download.arczip.app/releases/1.1.3/243/ArcZip-1.1.3-243.zip"
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

  # 实测(2026-10-21,1.1.2/232):App 带 ArcZipFinderSync / ArcZipQuickLook 两个 .appex,
  # 各自生成独立 Container 与 Application Scripts;主 App 另有带 team-id 前缀的
  # Application Scripts 与 Group Containers(J5W6R92F8U 为开发者团队 ID)。
  zap trash: [
    "~/Library/Application Scripts/com.maczhang.ArcZip.FinderSync",
    "~/Library/Application Scripts/com.maczhang.ArcZip.QuickLook",
    "~/Library/Application Scripts/J5W6R92F8U.com.maczhang.ArcZip",
    "~/Library/Application Support/com.maczhang.ArcZip",
    "~/Library/Caches/com.maczhang.ArcZip",
    "~/Library/Containers/com.maczhang.ArcZip.FinderSync",
    "~/Library/Containers/com.maczhang.ArcZip.QuickLook",
    "~/Library/Group Containers/J5W6R92F8U.com.maczhang.ArcZip",
    "~/Library/HTTPStorages/com.maczhang.ArcZip",
    "~/Library/Preferences/com.maczhang.ArcZip.plist",
    "~/Library/Saved Application State/com.maczhang.ArcZip.savedState",
  ]
end
