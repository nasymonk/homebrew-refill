cask "qoder-cn" do
  version "0.1.4"

  # Qoder CN 全新形态（与 "Qoder CN IDE" 1.2x 线是不同产品）。
  # 上游 zip 是引导安装器外壳：真正的应用在其内部
  # Resources/payload/Qoder-CN-<version>-mac-<arch>.zip，
  # preflight 直接解出 Qoder CN.app，跳过安装器。
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=9C66E13C3B656C2C721979A7F6790998 x64=389DBAAE1DD5CF2F3674F998CADA47D1
  on_arm do
    sha256 "373118fa59bd2f31dd1ff0690a87a91bfcb5b81fa38ff4b578c8f7695eb21070"
    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-Installer-mac-arm64.zip"
  end
  on_intel do
    sha256 "6f3d4207e2122c323cf793753d731aa711685214bd5ed120e25745b160aa320c"
    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-Installer-mac-x64.zip"
  end

  name "Qoder CN"
  desc "Agentic platform from Alibaba (China edition)"
  homepage "https://qoder.com.cn/"

  livecheck do
    skip "上游仅提供无版本号 latest 直链，无公开版本源"
  end

  # 绕过引导安装器：解出其内置 payload（Qoder CN.app），并丢弃安装器外壳
  preflight do
    installer = staged_path.join("Qoder CN Installer.app")
    payload_dir = installer.join("Contents/Resources/payload")
    payload = payload_dir.children.find { |p| p.basename.to_s.end_with?(".zip") }
    system_command "/usr/bin/unzip", args: ["-q", "-o", payload.to_s, "-d", staged_path.to_s]
    FileUtils.rm_rf(installer)
  end

  app "Qoder CN Installer.app"

  # 内置自更新
  auto_updates true

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
