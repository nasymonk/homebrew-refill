cask "workbuddy" do
  version "5.7.7.40774747"

  # 腾讯 WorkBuddy（workbuddy.cn，Electron）；更新通道为官方 /v2/update 接口
  # （download.codebuddy.cn 桶，路径含 saas/架构/完整版本号），
  # url 尾部 -<8位构建标记> 随构建变化，版本/sha256/url 由 scripts/bump-workbuddy.sh 依接口返回值改写。
  on_arm do
    sha256 "93ab5ad9e2a855a09e0956a19c53cb53f29b69443d4fcbf25a21ef2db10db83a"

    url "https://download.codebuddy.cn/workbuddy/saas/darwin-arm64/WorkBuddy-darwin-arm64-5.7.7.40774747-2e8619da.zip"
  end
  on_intel do
    sha256 "ad14f17e6445108c8a85124145d76a34c6a8c2a4bbb63a68cc0646512861b180"

    url "https://download.codebuddy.cn/workbuddy/saas/darwin-x64/WorkBuddy-darwin-x64-5.7.7.40774747-2e8619da.zip"
  end

  name "WorkBuddy"
  desc "AI agent for everyday office work (Tencent)"
  homepage "https://www.workbuddy.cn/"

  livecheck do
    url "https://www.codebuddy.cn/v2/update?platform=workbuddy-darwin-arm64"
    strategy :json do |json|
      json["version"]
    end
  end

  # 走官方 /v2/update 接口自更新（非标准 electron-updater）
  auto_updates true

  app "WorkBuddy.app"

  # bundle ID 为 com.tencent.workbuddy.mac；zap 路径按 bundle ID 推测，安装实测后修正
  zap trash: [
    "~/Library/Application Support/com.tencent.workbuddy.mac",
    "~/Library/Caches/com.tencent.workbuddy.mac",
    "~/Library/Preferences/com.tencent.workbuddy.mac.plist",
    "~/Library/Saved Application State/com.tencent.workbuddy.mac.savedState",
  ]
end
