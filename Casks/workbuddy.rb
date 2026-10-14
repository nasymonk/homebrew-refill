cask "workbuddy" do
  version "5.8.2.41111488"

  # 腾讯 WorkBuddy（workbuddy.cn，Electron）；更新通道为官方 /v2/update 接口
  # （download.codebuddy.cn 桶，路径含 saas/架构/完整版本号），
  # url 尾部 -<8位构建标记> 随构建变化，版本/sha256/url 由 scripts/bump-workbuddy.sh 依接口返回值改写。
  on_arm do
    sha256 "af6c9f92cf5edbf1cefd4c97d9dbaf5564a7fa43e861761e29018c1422807ef9"

    url "https://download.codebuddy.cn/workbuddy/saas/darwin-arm64/WorkBuddy-darwin-arm64-5.8.2.41111488-b8f6c953.zip"
  end
  on_intel do
    sha256 "f64eaf8093fe60309bafb4637a0d0b33063ccc26607edbbc8dfc39a43083653f"

    url "https://download.codebuddy.cn/workbuddy/saas/darwin-x64/WorkBuddy-darwin-x64-5.8.2.41111488-b8f6c953.zip"
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
