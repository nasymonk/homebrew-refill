cask "qoder" do
  version "0.1.3"

  # 全新 Qoder（agentic platform，2026-08 发布，与 "Qoder IDE" 1.2x 线是不同产品）；
  # 桶内只有带版本号路径，版本来自官方更新接口（desktop 通道），
  # 版本/sha256/app 名由 scripts/bump-qoder.sh 改写。
  on_arm do
    sha256 "3f40d3f4da83d57a7a21ce1a6b86a554ef4bf3fb5389ffa5e2a23173b3f6199b"
    url "https://download.qoder.com.cn/qoder-app/releases/#{version}/Qoder-mac-arm64.zip"
  end
  on_intel do
    sha256 "c031d784e00677000eef8091420aaadd08d45b837b954f4779bf9aefa6469bf7"
    url "https://download.qoder.com.cn/qoder-app/releases/#{version}/Qoder-mac-x64.zip"
  end

  name "Qoder"
  desc "Agentic platform from Alibaba (the all-new Qoder)"
  homepage "https://qoder.com/"

  livecheck do
    url "https://center.qoder.sh/algo/api/update/desktop/darwin-arm64/stable/latest?version=0.0.0"
    regex(/"name":"(\d+(?:\.\d+)+)"/i)
  end

  # 内置自更新（electron-updater）
  auto_updates true

  app "Qoder.app"

  # bundle ID 为 com.qoder.app；zap 路径为推测值，安装后验证修正
  zap trash: [
    "~/Library/Application Support/Qoder",
    "~/Library/Caches/com.qoder.app",
    "~/Library/Preferences/com.qoder.app.plist",
    "~/Library/Saved Application State/com.qoder.app.savedState",
  ]
end
