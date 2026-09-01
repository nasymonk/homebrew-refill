cask "qoder-ide" do
  version "1.27.1"

  # 旧 Qoder Desktop/IDE（1.2x 版本线，与全新 Qoder 0.1.x 是不同产品）；
  # 上游自 1.25.0 起改名 "Qoder IDE" 并更换发布通道：旧 latest dmg 直链已永久停更，
  # 新版本以带版本号 zip 发布于 qoder-ide OSS 桶；
  # 版本/sha256/app 名由 scripts/bump-qoder-ide.sh 依官方更新接口（center.qoder.sh）改写。
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

  # zap 路径 2026-09-01 依卸载 1.x（bundle ID com.qoder.ide）时的实测残留：
  # 数据目录为 Application Support/Qoder；自更新走 Squirrel，留下 ShipIt 缓存与 ByHost plist
  # （LaunchAgents/com.qoder.ide.ShipIt.plist 在卸载时刻未捕获，可能随版本变化）。
  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.qoder.ide.sfl*",
    "~/Library/Application Support/Qoder",
    "~/Library/Caches/com.qoder.ide",
    "~/Library/Caches/com.qoder.ide.ShipIt",
    "~/Library/Caches/Qoder",
    "~/Library/HTTPStorages/com.qoder.ide",
    "~/Library/HTTPStorages/com.qoder.ide.binarycookies",
    "~/Library/HTTPStorages/Qoder",
    "~/Library/LaunchAgents/com.qoder.ide.ShipIt.plist",
    "~/Library/Preferences/ByHost/com.qoder.ide.ShipIt.*.plist",
    "~/Library/Preferences/com.qoder.ide.plist",
    "~/Library/Preferences/Qoder.plist",
    "~/Library/Saved Application State/com.qoder.ide.savedState",
  ]
end
