cask "qoder" do
  version "1.18.2"

  # 上游只提供无版本号的 latest 直链，URL 永远不变；
  # 版本/sha256 由 scripts/bump-qoder.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=5E1730C7C8428D8C3DBDF66992EE5709 x64=78E33FD4A9D3A314852CF749A48D33F1
  on_arm do
    sha256 "bebf79a7ac38dbda50a3cf4322907c3c89d5d7f5908a0dc6a06b4111b30a3b85"
    url "https://download.qoder.com/release/latest/Qoder-darwin-arm64.dmg"
  end
  on_intel do
    sha256 "bd0b563352f5d31c7840f018dbbda80096bfce1f2406ac6ccb06dcb355a6e001"
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
