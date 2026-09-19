cask "qoder-cn" do
  version "0.3.4"

  # Qoder CN 全新形态（与 "Qoder CN IDE" 1.2x 线是不同产品）。
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 改写。
  on_arm do
    sha256 "c6a93ef668864a7d662b6b86a2fa4fef1c427280cb0317177b867ce194ae6679"

    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/#{version}/Qoder-CN-mac-arm64.zip"
  end
  on_intel do
    sha256 "94bea795f5fab45caca7017da9c61c3fe7e4bddcb5b7f5934c8162d627e5a767"

    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/#{version}/Qoder-CN-mac-x64.zip"
  end

  name "Qoder CN"
  desc "Agentic platform from Alibaba (China edition)"
  homepage "https://qoder.com.cn/"

  livecheck do
    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest-mac.yml"
    strategy :yaml do |yaml|
      yaml["version"]
    end
  end

  # 内置自更新
  auto_updates true
  depends_on :macos

  app "Qoder CN.app"

  # zap 路径 2026-09-01 依本机实跑并清理时的实测结果：
  # 数据目录为 Application Support/com.qodercn.app.stable；安装器壳会留下 com.qodercn.installer.plist；
  # app 本体还会创建 ~/.qoder-cn、~/.qmind/.qoder-cn、~/Documents/QoderCN（用户数据，惯例不 zap）。
  # Caches/SavedState 实测未生成，保留以兼容未来版本。
  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.qodercn.app.sfl*",
    "~/Library/Application Support/com.qodercn.app.stable",
    "~/Library/Caches/com.qodercn.app",
    "~/Library/Preferences/com.qodercn.app.plist",
    "~/Library/Preferences/com.qodercn.installer.plist",
    "~/Library/Saved Application State/com.qodercn.app.savedState",
  ]
end
