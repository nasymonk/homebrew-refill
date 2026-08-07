cask "qoder" do
  version "1.23.0"

  # 上游只提供无版本号的 latest 直链，URL 永远不变；
  # 版本/sha256 由 scripts/bump-qoder.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=691AE5196487F4F0F1D52156333A564E x64=280E952E5DBA661EA9D37F49890BE8CC
  on_arm do
    sha256 "3c76af24295e2c3e60297c5dbba0fab7d7263f176d3bd1e6ecd4736a3d56bb69"
    url "https://download.qoder.com/release/latest/Qoder-darwin-arm64.dmg"
  end
  on_intel do
    sha256 "b1b7642173aac3bbe44585fbe180d243f928251d004e55ee3f377e5022951a91"
    url "https://download.qoder.com/release/latest/Qoder-darwin-x64.dmg"
  end

  name "Qoder"
  desc "Agentic coding IDE from Alibaba"
  homepage "https://qoder.com/"

  livecheck do
    skip "上游仅提供无版本号 latest 直链，无公开版本源"
  end

  # Qoder 为 VS Code fork，内置自更新；安装后若实际未发现自更新机制则移除本行
  auto_updates true

  app "Qoder.app"

  # bundle ID 按实际安装后目录为准，以下为推测值（Task 6 安装后验证修正）
  zap trash: [
    "~/Library/Application Support/Qoder",
    "~/Library/Caches/Qoder",
    "~/Library/Preferences/com.qoder.ide.plist",
    "~/Library/Saved Application State/com.qoder.ide.savedState",
  ]
end
