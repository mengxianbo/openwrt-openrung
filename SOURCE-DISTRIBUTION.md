# 历史 Build #24 对应源码归档（仅供追溯）

> **历史记录，不是当前版本的安装或下载入口。** 本文只描述历史稳定构建 Build #24 的对应源码归档。当前 APK/IPK 请从 [统一 Release：openwrt-packages](https://github.com/mengxianbo/openwrt-openrung/releases/tag/openwrt-packages) 下载；当前 IPK 对应源码流程请看 [FUTURE-SOURCE-DISTRIBUTION.md](./FUTURE-SOURCE-DISTRIBUTION.md)。

## 历史构建的精确版本

- 历史 GitHub Actions run：[`44885434847`](https://github.com/mengxianbo/openwrt-openrung/actions/runs/44885434847)
- 打包仓库 commit：`ea2385243c93440fcede94923a7f83477d27af70`
- OpenRung 上游 commit：`5cba4f0b9da642dcc9cc1904f861eb1d59c23a04`

以上 commit 仅用于还原 Build #24，不应被当作当前 main 分支或当前 Release 的版本号。

## 历史归档内容

手动触发的工作流 `OpenRung #24 Corresponding Source` 为该历史构建生成独立的 GitHub Actions artifact，内容包括：

1. Build #24 精确打包 commit 对应的仓库源码树。
2. 精确上游 commit 对应的 OpenRung 源码树，以及由 `go mod vendor` 生成的 Go 依赖源码。
3. 上游 `LICENSE` 和填入两个发行方信息占位符的 `THIRD_PARTY_NOTICES.md` 分发副本。
4. `DISTRIBUTION-NOTICE-ADDENDUM.md`、许可证范围说明、依赖审计范围说明。
5. 源码清单和 SHA256 校验文件。

该历史工作流会检查固定 commit、归档可读性、vendor 模块清单及 SHA256。artifact 单独保存在对应 Actions run 中，保留 90 天；它不是当前 `openwrt-packages` Release 的附件。

## 历史保留边界

该工作流独立于 IPK 构建，不会重建、替换、删除或重新发布 Build #24 的 IPK，也不会修改历史 Actions run、原始 IPK SHA256 或现有 Release 附件。

打包源码和上游源码分别归档。许可证范围见 [LICENSES.md](./LICENSES.md)。源码文件存在性检查本身不构成法律意见，也不代表已满足每一项第三方许可义务。

## 上游声明占位符处理

上游源码归档是 commit `5cba4f0b9da642dcc9cc1904f861eb1d59c23a04` 的原样快照，其中原始 `THIRD_PARTY_NOTICES.md` 不作修改。只有单独分发的声明副本会将联系地址填写为本仓库 Issues 页面，并将公开源码地址填写为上游仓库地址。补充说明记录在 addendum 中；若仍有未处理占位符，历史源码工作流会失败。

## 历史依赖许可证审计

目标平台 Go 依赖审计范围见 [DEPENDENCY-LICENSE-AUDIT.md](./DEPENDENCY-LICENSE-AUDIT.md)。其中手动审计默认使用 Build #24 的精确上游 commit；后续构建的审计结果应以对应构建的精确上游 commit 和独立 Actions artifact 为准。审计报告不会修改或重建软件包。

> 再次提醒：Build #24 是历史归档。当前软件包、校验文件和下载说明以 `openwrt-packages` Release 及当前构建对应的 Actions artifacts 为准。
