### 变更说明 (Description)

- [ ] 新增 Cask: `<cask-name>`
- [ ] 修复 / 更新已有 Cask: `<cask-name>`
- [ ] 优化 CI / 自动化更新脚本
- [ ] 文档更新

---

### 软件基本信息 (App Info)

- **软件名称**: 
- **官方网站**: 
- **下载地址**: 
- **版本号**: 

---

### 本地测试与验证 (Local Verification)

请勾选已完成的自测项：
- [ ] 已在本地运行 `brew install --cask ./Casks/<cask-name>.rb` 验证安装成功
- [ ] 已验证 App 能够正常启动与运行
- [ ] 已测试 `brew uninstall --cask ./Casks/<cask-name>.rb`（以及 `--zap`）清理正常
- [ ] 如新增自动更新脚本，已在本地执行 `bash scripts/bump-<cask-name>.sh` 验证无误
- [ ] 已在 `.github/workflows/autobump.yml` 与 `README.md` 中添加对应配置与说明
