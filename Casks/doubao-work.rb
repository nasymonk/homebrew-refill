cask "doubao-work" do
  version "2.27.6"
  sha256 "efb36a53856134b529a18095be17cfb04c6e900fca4b80f4d5eca1528dc3d110"

  # URL 由字节跳动分发接口下发,升级由 scripts/bump-doubao-work.sh 自动检测并改写
  url "https://lf9-apk.ugapk.cn/package/pc/doubao_work_desktop/2027006/doubao_work_desktop_webdaoliu_modal_pcwork_macos_v2027006_eb8e_1787999262.dmg"
  name "豆包工作"
  name "Doubao Work"
  name "DoubaoWork"
  desc "AI office and workflow assistant from ByteDance"
  homepage "https://www.doubao.com/work"

  auto_updates true
  depends_on macos: :monterey

  app "DoubaoWork.app"

  zap trash: [
    "~/Library/Application Scripts/com.work.pc.doubao.FinderSyncExtension",
    "~/Library/Application Support/DoubaoWork",
    "~/Library/Application Support/com.work.pc.doubao",
    "~/Library/Caches/DoubaoWork",
    "~/Library/Caches/com.work.pc.doubao",
    "~/Library/Containers/com.work.pc.doubao.FinderSyncExtension",
    "~/Library/HTTPStorages/com.work.pc.doubao",
    "~/Library/Preferences/com.work.pc.doubao.helper.plist",
    "~/Library/Preferences/com.work.pc.doubao.plist",
    "~/Library/Saved Application State/com.work.pc.doubao.savedState",
  ]
end
