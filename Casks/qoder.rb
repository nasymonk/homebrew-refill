cask "qoder" do
  version "1.19.1"

  # 上游只提供无版本号的 latest 直链，URL 永远不变；
  # 版本/sha256 由 scripts/bump-qoder.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=A10689C5DCD1B8ED1C22CAF1709E2EEF x64=66930451FADB98AC69C5F77E0C7B3711
  on_arm do
    sha256 "c46248ee84a6bdcab1926cad742a45f189717feace437cbf59e2465607258dd0"
    url "https://download.qoder.com/release/latest/Qoder-darwin-arm64.dmg"
  end
  on_intel do
    sha256 "d34997e58dcdd293ccf5f9ac63fc6fd884e254d6fe04a36c266daef850857c9f"
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
