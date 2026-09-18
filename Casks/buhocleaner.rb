cask "buhocleaner" do
  version "1.17.0"
  sha256 "2d81835d2e0c8dead2a53d9f1ab44777ff4ac4a8c2e57aec410de6149bee4b1e"

  # dmg 文件名含构建号 (buhocleaner_b<build>.dmg),与版本号无关。
  # 版本/链接/sha 由 scripts/bump-buhocleaner.sh 解析 Sparkle appcast 改写。
  url "https://pub-assets1.drbuho.com/buhocleaner/releases/buhocleaner.dmg"
  name "BuhoCleaner"
  desc "Mac cleaner and optimizer"
  homepage "https://www.drbuho.com/buhocleaner"

  livecheck do
    url "https://www.drbuho.com/buho-public-files/buhocleaner/appcast.xml"
    strategy :sparkle
  end

  app "BuhoCleaner.app"

  # 2026-09-01 实测补充 StatusBarMenu 偏好；App Support/SavedState 未生成但按惯例保留
  zap trash: [
    "~/Library/Application Support/com.drbuho.BuhoCleaner",
    "~/Library/Caches/com.drbuho.BuhoCleaner",
    "~/Library/HTTPStorages/com.drbuho.BuhoCleaner",
    "~/Library/Preferences/com.drbuho.BuhoCleaner.plist",
    "~/Library/Preferences/com.drbuho.BuhoCleaner.StatusBarMenu.plist",
    "~/Library/Saved Application State/com.drbuho.BuhoCleaner.savedState",
  ]
end
