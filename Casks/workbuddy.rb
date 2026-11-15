cask "workbuddy" do
  version "5.11.3.43806934"

  # 腾讯 WorkBuddy（workbuddy.cn，Electron）；更新通道为官方 /v2/update 接口
  # （download.codebuddy.cn 桶，路径含 saas/架构/完整版本号），
  # url 尾部 -<8位构建标记> 随构建变化，版本/sha256/url 由 scripts/bump-workbuddy.sh 依接口返回值改写。
  on_arm do
    sha256 "26a9e617c30bff038efb651ee5fc8eec7c188c37ec0f32231726793302a91156"

    url "https://download.codebuddy.cn/workbuddy/saas/darwin-arm64/WorkBuddy-darwin-arm64-5.11.3.43806934-ecace0f7.zip"
  end
  on_intel do
    sha256 "0e3764bb07c868a31ea367903bdbfc432a19578ab80b0e5563e01507d74355c7"

    url "https://download.codebuddy.cn/workbuddy/saas/darwin-x64/WorkBuddy-darwin-x64-5.11.3.43806934-ecace0f7.zip"
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
