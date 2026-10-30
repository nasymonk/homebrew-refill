cask "qoder-cn" do
  version "0.5.1"

  # Qoder CN 全新形态（与 "Qoder CN IDE" 1.2x 线是不同产品）。
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 改写。
  # static.qoder.com.cn 为发布源（其 latest-mac.yml 自指向本域名），
  # qoder-app.oss-cn-beijing 仅为镜像桶，故不作下载与 livecheck 依据。
  on_arm do
    sha256 "ff09a8565a1fda3c8b41628ce8a5f545a20ce5c4b15d35b6ca09d9a7a6d192e0"

    url "https://static.qoder.com.cn/qoder-app/releases/#{version}/Qoder-CN-mac-arm64.zip"
  end
  on_intel do
    sha256 "5c672358c9166ee990f7e8d3fa1a1c9611875587e0aac7ce7d1e80319b333c0e"

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
