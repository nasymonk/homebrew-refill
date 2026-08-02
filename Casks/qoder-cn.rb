cask "qoder-cn" do
  version "1.10.0"

  # 上游只提供无版本号的 lastest 直链，URL 永远不变；
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=A112E979D594DD693F548DBA148020DD x64=3EF218DB94511BFCCAF4DA5BA1F927D4
  on_arm do
    sha256 "97fa27b5ea7b58832dd95e43e200e5800e8d12d7207aa14e884553415f40ba67"
    url "https://ide.qoder.com.cn/qoder/release/lastest/QoderCN-darwin-arm64.dmg"
  end
  on_intel do
    sha256 "f46feacaa0c64994de05e6707b54cbdffe5f53dc8d887a64143d1b63df4eac95"
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
