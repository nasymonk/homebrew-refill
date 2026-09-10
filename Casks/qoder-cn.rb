cask "qoder-cn" do
  version "0.2.3"

  # Qoder CN 全新形态（与 "Qoder CN IDE" 1.2x 线是不同产品）。
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 改写。
  on_arm do
    sha256 "e96c62521a3e4a2745123879c92da5c396868e1e3196d808f9d96d125ae4eee4"

    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/#{version}/Qoder-CN-mac-arm64.zip"
  end
  on_intel do
    sha256 "05687197dbc06e60ee7cfb1679d9bb14e52ed2b79f7a98cd601552d30b7835ad"

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
