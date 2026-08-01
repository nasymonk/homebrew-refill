cask "qoder-cn" do
  version "1.9.1"

  # 上游只提供无版本号的 lastest 直链，URL 永远不变；
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=30D264892F873B1904170AF9AD646CFA x64=55809542FD11D5C8919B8028B1677FE2
  on_arm do
    sha256 "5ea2c83d3f8ff76cfe8bf4c41753f1a8a39b5bed8504254f51730a92ac841057"
    url "https://ide.qoder.com.cn/qoder/release/lastest/QoderCN-darwin-arm64.dmg"
  end
  on_intel do
    sha256 "5fc03196730b03ca837b800e10162dbe8fa06b5c998e47ed05474c2ecb9b260e"
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
