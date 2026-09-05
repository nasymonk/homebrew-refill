cask "qoder-cn" do
  version "0.1.8"

  # Qoder CN 全新形态（与 "Qoder CN IDE" 1.2x 线是不同产品）。
  # 上游 zip 是引导安装器外壳：真正的应用在其内部
  # Resources/payload/Qoder-CN-<version>-mac-<arch>.zip，
  # preflight 直接解出 Qoder CN.app，跳过安装器。
  # 版本/sha256 由 scripts/bump-qoder-cn.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=D1CA04B6899C710422093E90810B4BB1 x64=6EE67789024E85D3F869AF892A54DC49
  on_arm do
    sha256 "e13c19065c17eb32f749bdb8e5e0b2a7132f3459503270bca3e5ca6b18e3d8e5"
    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-Installer-mac-arm64.zip"
  end
  on_intel do
    sha256 "9f4d83c632f080c4faffb4eabdb0282f2ae90eb0a6e3dfd1cdb01bab887b74fb"
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
