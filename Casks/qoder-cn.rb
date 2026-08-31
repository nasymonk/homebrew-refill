cask "qoder-cn" do
  version "0.1.3"

  # Qoder CN 全新形态（安装器应用，与 "Qoder CN IDE" 1.2x 线是不同产品）；
  # 上游只提供无版本号 latest 直链，版本/sha256/app 名由
  # scripts/bump-qoder-cn.sh 依 OSS ETag 变更检测后改写。
  # upstream-etag arm=3734D76864650EF6A7A96300ADCA71CA x64=7520A4B641C1127EA8D6B3AF360F9E5D
  on_arm do
    sha256 "234b9785a4bf599a65fbf11ac1ae215ed9c1355b422b27c7fed37d243ae480c8"
    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-Installer-mac-arm64.zip"
  end
  on_intel do
    sha256 "f80bbfab0889e48e1a2923629250f147479bec38441e2c2e09089a5d42b1c5ca"
    url "https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-Installer-mac-x64.zip"
  end

  name "Qoder CN"
  desc "Agentic platform from Alibaba (China edition, installer)"
  homepage "https://qoder.com.cn/"

  livecheck do
    skip "上游仅提供无版本号 latest 直链，无公开版本源"
  end

  # 安装器内置自更新
  auto_updates true

  app "Qoder CN Installer.app"

  # bundle ID 为 com.qodercn.installer；zap 路径为推测值，安装后验证修正
  zap trash: [
    "~/Library/Application Support/Qoder CN Installer",
    "~/Library/Caches/com.qodercn.installer",
    "~/Library/Preferences/com.qodercn.installer.plist",
    "~/Library/Saved Application State/com.qodercn.installer.savedState",
  ]
end
