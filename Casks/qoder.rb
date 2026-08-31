cask "qoder" do
  version "1.27.1"

  # 上游自 1.25.0 起改名 "Qoder IDE" 并更换发布通道：旧 latest dmg 直链已永久停更，
  # 新版本以带版本号 zip 发布于 qoder-ide OSS 桶；
  # 版本/sha256/app 名由 scripts/bump-qoder.sh 依官方更新接口（center.qoder.sh）改写。
  on_arm do
    sha256 "9f11be817f3fe1e38378b3642811dd880ce9804ba3962c248a7d90ad94021047"
    url "https://qoder-ide.oss-accelerate.aliyuncs.com/release/#{version}/Qoder-darwin-arm64.zip"
  end
  on_intel do
    sha256 "6f74163a72adff3498c9689cfd6307a71ea057aeac20ee22ec2fe19a0df9e45a"
    url "https://qoder-ide.oss-accelerate.aliyuncs.com/release/#{version}/Qoder-darwin-x64.zip"
  end

  name "Qoder IDE"
  desc "Agentic coding IDE from Alibaba"
  homepage "https://qoder.com/"

  livecheck do
    url "https://center.qoder.sh/algo/api/update/darwin-arm64/stable/latest?version=0.0.0"
    regex(/"name":"(\d+(?:\.\d+)+)"/i)
  end

  # Qoder 为 VS Code fork，内置自更新；安装后若实际未发现自更新机制则移除本行
  auto_updates true

  app "Qoder IDE.app"

  # bundle ID 按实际安装后目录为准，以下为推测值（Task 6 安装后验证修正）
  zap trash: [
    "~/Library/Application Support/Qoder",
    "~/Library/Caches/Qoder",
    "~/Library/Preferences/com.qoder.ide.plist",
    "~/Library/Saved Application State/com.qoder.ide.savedState",
  ]
end
