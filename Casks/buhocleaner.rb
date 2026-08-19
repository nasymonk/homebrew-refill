cask "buhocleaner" do
  version "1.16.3"
  sha256 "1a864c9455bf5dab2a1d0d8494d704b77906ad328a81ee2f1a48835bb2c5ad49"

  # dmg 文件名含构建号 (buhocleaner_b<build>.dmg),与版本号无关。
  # 版本/链接/sha 由 scripts/bump-buhocleaner.sh 解析 Sparkle appcast 改写。
  url "https://drbuho.net/buhocleaner/buhocleaner_b259.dmg"
  name "BuhoCleaner"
  desc "Mac cleaner and optimizer"
  homepage "https://www.drbuho.com/buhocleaner"

  livecheck do
    url "https://www.drbuho.com/buho-public-files/buhocleaner/appcast.xml"
    strategy :sparkle
  end

  app "BuhoCleaner.app"

  zap trash: [
    "~/Library/Application Support/com.drbuho.BuhoCleaner",
    "~/Library/Caches/com.drbuho.BuhoCleaner",
    "~/Library/HTTPStorages/com.drbuho.BuhoCleaner",
    "~/Library/Preferences/com.drbuho.BuhoCleaner.plist",
    "~/Library/Saved Application State/com.drbuho.BuhoCleaner.savedState",
  ]
end
