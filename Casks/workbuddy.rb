cask "workbuddy" do
  version "5.5.4.38151288"

  # 腾讯 WorkBuddy（workbuddy.cn，Electron）；更新通道为官方 /v2/update 接口
  # （download.codebuddy.cn 桶，路径含 saas/架构/完整版本号），
  # url 尾部 -<8位构建标记> 随构建变化，版本/sha256/url 由 scripts/bump-workbuddy.sh 依接口返回值改写。
  on_arm do
    sha256 "6fdd19b85f3b48ed8c908cc4ed88e14e9b769c9eb0f7efa68506211d5d07d0b4"

    url "https://download.codebuddy.cn/workbuddy/saas/darwin-arm64/WorkBuddy-darwin-arm64-5.5.4.38151288-1ca4889a.zip"
  end
  on_intel do
    sha256 "018f12695a93be2c273c7abb3623c7a93df0d571c3ece2e0aea26034218fe768"

    url "https://download.codebuddy.cn/workbuddy/saas/darwin-x64/WorkBuddy-darwin-x64-5.5.4.38151288-1ca4889a.zip"
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
