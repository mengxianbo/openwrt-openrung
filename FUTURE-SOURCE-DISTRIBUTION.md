# 当前及后续 IPK 对应源码分发说明

> **适用范围：** 本文描述合并 `.github/workflows/future-source-distribution.yml` 后成功完成的 IPK 构建。它不追溯生成历史 Build #24 以外的旧构建源码，也不重建或替换任何 IPK。

## 当前下载入口与文件分工

- 当前二进制统一发布页是 [OpenRung OpenWrt Packages (APK + IPK)](https://github.com/mengxianbo/openwrt-openrung/releases/tag/openwrt-packages)。
- Release 附件包括 APK、IPK、两个安装包 ZIP 合集和 SHA256 校验文件；**对应源码归档不作为该 Release 的附件发布**。
- IPK 构建工作流 `Build OpenRung OpenWrt IPK` 上传一个名为 `openrung-openwrt-ipk` 的 30 天 Actions artifact，其中包含该次构建的稳定名 IPK、校验文件、IPK ZIP，以及打包仓库和上游源码快照。
- 后置源码工作流 `OpenRung Future Corresponding Source` 针对成功的 IPK 构建生成独立的 90 天 Actions artifact。请从与目标 IPK 对应的构建 run 及其关联的源码工作流下载，不能拿其他 run 或最新分支的源码代替。

## 后置工作流生成内容

对于工作流启用后每次成功的 `Build OpenRung OpenWrt IPK` run，后置工作流会：

1. 下载该次 run 的 `openrung-openwrt-ipk` artifact。
2. 从客户端 IPK 的 `SOURCE-INFO.txt` 读取精确版本，并要求打包仓库 commit 与构建 run commit 一致。
3. 验证客户端 IPK 中的上游 `LICENSE`、`THIRD_PARTY_NOTICES.md`、发行方补充声明和源码元数据；检查声明中没有未处理占位符。
4. 验证该次构建生成的精确打包源码与上游源码归档。
5. 对精确上游源码执行 `go mod vendor`，并使用相同构建标签检查 Linux amd64 客户端依赖解析。
6. 在保留原始上游源码快照不变的前提下，额外生成包含 vendor 依赖的对应源码归档。
7. 上传独立的 90 天 Actions artifact，包含精确打包源码、精确上游源码、vendor-inclusive 源码、许可证文本、第三方声明、发行方补充声明、构建元数据、IPK 校验和及源码 SHA256 清单。

源码 artifact 名称包含精确上游 commit。其 `SOURCE-MANIFEST.txt` 记录两个精确 commit、目标平台、Go 工具链、构建标签和 vendor 模块数量。

## 如何找到匹配的源码

1. 打开目标 IPK 的 [Actions 构建记录](https://github.com/mengxianbo/openwrt-openrung/actions/workflows/build.yml)。
2. 进入对应的成功构建 run，确认其 commit 与 IPK 内 `SOURCE-INFO.txt` 一致。
3. 在该 run 的关联工作流运行记录中，打开 `OpenRung Future Corresponding Source`，下载名称包含对应上游 commit 的 artifact。
4. 校验 artifact 中的 `SOURCE-MANIFEST.txt` 和 SHA256 清单。

**不要**将当前 `main` 分支源码、其他构建 run 的 artifact，或历史 Build #24 的源码用于替代某个 IPK 的对应源码。

## Release 发布规则

二进制统一 Release 的 tag 固定为 `openwrt-packages`，名称为 `OpenRung OpenWrt Packages (APK + IPK)`。APK 和 IPK 工作流分别更新该 Release 的不同附件；清理步骤只保留该统一 Release 及允许列表中的文件。

当前源码工作流上传独立 Actions artifact，不会自动把源码归档附加到 `openwrt-packages` Release，也不会更新或覆盖该 Release。若未来决定把源码归档作为 Release 附件发布，必须将同一次构建生成的完整源码文件附加到与其二进制相同的 Release，并先同步更新 APK/IPK 两个工作流的附件保留清单，避免后续清理时误删。

## 历史构建隔离

- 历史 Build #24 run `44885434847` 与本文描述的后续构建流程分开保存；历史详情见 [SOURCE-DISTRIBUTION.md](./SOURCE-DISTRIBUTION.md)。
- 本工作流不执行 IPK 编译命令。
- 本工作流不写入、删除或替换 IPK、tag、Release 或历史 Actions artifact。
- 原始打包源码和上游源码快照保持原样；仅额外生成 vendor-inclusive 归档。

工作流通过只表示列出的源码、声明和校验文件存在且与记录的版本匹配，不构成法律意见，也不能替代对各依赖特殊许可条件的人工审查。
