cask "doubao-work" do
  arch arm: "Arm64", intel: "X64"

  version "2.27.6"
  sha256 arm:   "c67b736f8b3bfa8907686076d03645f221ff960527bdd3c14793b9322349c159",
         intel: "59bd5c2a4e0df624443ec0aeb37b2919d932df2ebd42262eff3ab20a6b2b00ab"

  url "https://lf-flow-web-cdn.doubao.com/obj/flow-doubao/doubao_pc/#{version}/DoubaoWork_#{arch}_#{version}.dmg"
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
    "~/Library/Application Support/com.work.pc.doubao",
    "~/Library/Application Support/DoubaoWork",
    "~/Library/Caches/com.work.pc.doubao",
    "~/Library/Caches/DoubaoWork",
    "~/Library/Containers/com.work.pc.doubao.FinderSyncExtension",
    "~/Library/HTTPStorages/com.work.pc.doubao",
    "~/Library/Preferences/com.work.pc.doubao.helper.plist",
    "~/Library/Preferences/com.work.pc.doubao.plist",
    "~/Library/Saved Application State/com.work.pc.doubao.savedState",
  ]
end
