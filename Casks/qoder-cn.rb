cask "qoder-cn" do
  version "0.5.12"

  # Qoder CN 全新形态（与 "Qoder CN IDE" 1.2x 线是不同产品）。
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 改写。
  # static.qoder.com.cn 为发布源（其 latest-mac.yml 自指向本域名），
  # qoder-app.oss-cn-beijing 仅为镜像桶，故不作下载与 livecheck 依据。
  on_arm do
    sha256 "73f4d95d1342acc440b4b305ad7ff2667e4ff97c77e5f7c9e06e4794262e2d8f"

    url "https://static.qoder.com.cn/qoder-app/releases/#{version}/Qoder-CN-mac-arm64.zip"
  end
  on_intel do
    sha256 "4a1676d8abc19908982663e1cda84dbeed09dac7545d216bd68d52587df1bcb8"

    url "https://static.qoder.com.cn/qoder-app/releases/#{version}/Qoder-CN-mac-x64.zip"
  end

  name "Qoder CN"
  desc "Agentic platform from Alibaba (China edition)"
  homepage "https://qoder.com.cn/"

  livecheck do
    url "https://static.qoder.com.cn/qoder-app/releases/latest-mac.yml"
    strategy :yaml do |yaml|
      yaml["version"]
    end
  end

  # 内置自更新
  auto_updates true
  # 安装包 Info.plist 声明 LSMinimumSystemVersion 为 Monterey，故显式写下限（brew audit 要求）
  depends_on macos: :monterey

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
