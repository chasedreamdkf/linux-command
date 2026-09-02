# LinuxCommand HarmonyOS 原生迁移说明

## 当前进度

- 已将原 Web 项目的 `public/commands/*.md` 迁移到 `entry/src/main/resources/rawfile/commands/`。
- 已生成 `entry/src/main/resources/rawfile/commands-index.json`，索引与 Markdown 文件数量均为 615。
- 已用 ArkTS + ArkUI 重写首页搜索、命令列表、详情页导航和 Markdown 基础渲染。
- 已采用轻量 MVVM 分层：`model/`、`viewmodel/`、`views/`、`pages/`、`utils/`。
- 命令列表已升级为 `LazyForEach + IDataSource`，搜索结果变化时通过 `DataChangeListener.onDataReloaded()` 通知列表重载，降低大列表首屏创建和滚动内存压力。
- 已在 `module.json5` 声明 `phone`、`tablet`、`2in1`，并通过窗口宽度断点将 `Navigation` 在 sm/xs 使用 Stack、md/lg/xl 使用 Split；宽屏首次进入会默认打开首个命令详情，避免右侧内容区为空。
- 分栏模式下点击命令使用 `replacePathByName()` 替换右侧详情页，避免连续点击时不断压入详情页导致页面栈和内存增长。

## 关键目录

- `entry/src/main/ets/pages/Index.ets`：应用入口、Navigation 页面栈、首页和详情页承载。
- `entry/src/main/ets/model/CommandRepository.ets`：rawfile 读取、命令索引加载和详情缓存。
- `entry/src/main/ets/utils/MarkdownParser.ets`：Markdown 基础块解析。
- `entry/src/main/ets/views/MarkdownRenderer.ets`：ArkUI 原生 Markdown 渲染。
- `entry/src/main/resources/rawfile/commands/`：离线命令文档。

## 验证命令

```bash
devecocli build --modules entry
hdc install -r entry/build/default/outputs/default/entry-default-signed.hap
hdc shell aa start -a EntryAbility -b com.chasedream.linuxcommand
```

## 后续增强

- 增强 Markdown 表格、行内代码和链接渲染。
- 增加收藏、最近浏览、全文搜索和代码块复制按钮。
