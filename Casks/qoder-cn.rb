cask "qoder-cn" do
  version "1.24.1"

  # 上游只提供无版本号的 lastest 直链，URL 永远不变；
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=CA2171E1B5BDA1D09B7C267C56591842 x64=6494AEEABA096EE8FFEC470694930FF0
  on_arm do
    sha256 "5a9bb8678648c59e6deec221016d7838d5d5cf82d6745192ff025ed60859c96a"
    url "https://ide.qoder.com.cn/qoder/release/lastest/QoderCN-darwin-arm64.dmg"
  end
  on_intel do
    sha256 "d20be382a0b5d427bed4fa3f7c02334574ed3761ea85e9b8a8af9ad155216975"
    url "https://ide.qoder.com.cn/qoder/release/lastest/QoderCN-darwin-x64.dmg"
  end

  name "Qoder CN"
  desc "Agentic coding IDE from Alibaba (China edition)"
  homepage "https://qoder.com.cn/"

  livecheck do
    skip "上游仅提供无版本号 lastest 直链，无公开版本源"
  end

  # Qoder CN 为 VS Code fork，内置自更新
  auto_updates true

  app "Qoder CN.app"

  zap trash: [
    "~/Library/Application Support/Qoder CN",
    "~/Library/Caches/com.aliyun.lingma.ide",
    "~/Library/Caches/Qoder CN",
    "~/Library/Preferences/com.aliyun.lingma.ide.plist",
    "~/Library/Saved Application State/com.aliyun.lingma.ide.savedState",
  ]
end
