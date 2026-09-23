cask "qoder-cn" do
  version "0.4.1"

  # Qoder CN 全新形态（与 "Qoder CN IDE" 1.2x 线是不同产品）。
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 改写。
  on_arm do
    sha256 "45508566660d5d2399aae9a628b4054cc38e53722a16b588fd440f436c9066ef"

    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/#{version}/Qoder-CN-mac-arm64.zip"
  end
  on_intel do
    sha256 "531bfefe6028df998eac35ca9c6a0979b7b7f8fd1f091c4fdc55d23cbfcad97a"

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
