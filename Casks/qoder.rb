cask "qoder" do
  version "0.3.4"

  # 全新 Qoder（agentic platform，2026-08 发布，与 "Qoder IDE" 1.2x 线是不同产品）；
  # 桶内只有带版本号路径，版本来自官方更新接口（desktop 通道），
  # 版本/sha256/app 名由 scripts/bump-qoder.sh 改写。
  on_arm do
    sha256 "f6d56f3892465a6e55ab82bcee85a42e22120f8ef446e92a3962222e7df92315"
    url "https://download.qoder.com.cn/qoder-app/releases/#{version}/Qoder-mac-arm64.zip"
  end
  on_intel do
    sha256 "1f0eead559c5d35e88004b3a96512fbda6ba2f4fd70ff5c295e37ce09731f334"
    url "https://download.qoder.com.cn/qoder-app/releases/#{version}/Qoder-mac-x64.zip"
  end

  name "Qoder"
  desc "Agentic platform from Alibaba (the all-new Qoder)"
  homepage "https://qoder.com/"

  livecheck do
    url "https://center.qoder.sh/algo/api/update/desktop/darwin-arm64/stable/latest?version=0.0.0"
    regex(/"name":"(\d+(?:\.\d+)+)"/i)
  end

  # 内置自更新（electron-updater）
  auto_updates true

  app "Qoder.app"

  # zap 路径 2026-09-01 在 0.1.x 真机实测：数据目录为 Application Support/com.qoder.app.stable；
  # Caches/com.qoder.app 与 SavedState 实测未生成（zap 容忍缺失路径，保留以备后患）。
  # 注意：会话/记忆/登录态在 ~/.qoder、~/.qodersec、~/.qoder-cli、~/.qmind/.qoder，
  # 属用户数据且与 CLI 共用，惯例不 zap，需要时手动删除。
  zap trash: [
    "~/Library/Application Support/com.qoder.app.stable",
    "~/Library/Caches/com.qoder.app",
    "~/Library/Preferences/com.qoder.app.plist",
    "~/Library/Saved Application State/com.qoder.app.savedState",
  ]
end
