cask "buhocleaner" do
  version "1.17.0"
  # 故意偏离 `brew audit` 的 "unversioned URL 应用 sha256 :no_check"：
  # 厂商原地覆写同一个 .dmg，no_check 等于放弃安装时的完整性校验。
  # 这里改为由 scripts/bump-buhocleaner.sh 每次发布重算并钉住 sha，
  # 代价是厂商覆写到我们 bump 之间存在窗口期，此时安装会校验失败而非装入未校验内容。
  sha256 "2d81835d2e0c8dead2a53d9f1ab44777ff4ac4a8c2e57aec410de6149bee4b1e"

  # appcast 的 enclosure 是不带版本号的固定地址 (buhocleaner.dmg)，厂商原地覆写。
  # 版本/链接/sha 由 scripts/bump-buhocleaner.sh 解析 Sparkle appcast 改写。
  url "https://pub-assets1.drbuho.com/buhocleaner/releases/buhocleaner.dmg"
  name "BuhoCleaner"
  desc "Mac cleaner and optimizer"
  homepage "https://www.drbuho.com/buhocleaner"

  livecheck do
    url "https://www.drbuho.com/buho-public-files/buhocleaner/appcast.xml"
    # 默认 :sparkle 会返回 "1.17.0,268"（短版本,构建号）与 version stanza 不符；
    # cask 只跟短版本号，构建号仅供 bump 脚本挑选 item。
    strategy :sparkle do |items|
      items.map(&:short_version)
    end
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
