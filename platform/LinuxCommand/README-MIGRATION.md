# LinuxCommand HarmonyOS 原生迁移说明

## 当前进度

- 已将原 Web 项目的 `public/commands/*.md` 迁移到 `entry/src/main/resources/rawfile/commands/`。
- 已生成 `entry/src/main/resources/rawfile/commands-index.json`，索引与 Markdown 文件数量均为 615。
- 已用 ArkTS + ArkUI 重写首页搜索、命令列表、详情页导航和 Markdown 基础渲染。
- 已采用轻量 MVVM 分层：`model/`、`viewmodel/`、`views/`、`pages/`、`utils/`。
- 命令列表已升级为 `LazyForEach + IDataSource`，搜索结果变化时通过 `DataChangeListener.onDataReloaded()` 通知列表重载，降低大列表首屏创建和滚动内存压力。
- 已在 `module.json5` 声明 `phone`、`tablet`、`2in1`，并通过窗口宽度断点将 `Navigation` 在 sm/xs 使用 Stack、md/lg/xl 使用 Split；宽屏首次进入会默认打开首个命令详情，避免右侧内容区为空。
- 分栏模式下点击命令使用 `replacePathByName()` 替换右侧详情页，避免连续点击时不断压入详情页导致页面栈和内存增长。
- Markdown 渲染增强：新增表格块（等宽分栏行渲染，支持 2-4 列表格与转义管道 `\|`，语料中 26 个表格全部可解析）、行内富文本（`InlineRichText` 用 `Span` 渲染行内代码、加粗和链接），http(s) 链接点击后经 `UIAbilityContext.openLink()` 打开；段落、列表项、引用和表格单元格均走行内解析，行内代码内不再解析其它行内语法。
- 新增收藏（列表星标 + 详情页收藏按钮）、最近浏览（最近 20 条，首页"最近"Tab）与全文搜索（首页开关，按需构建全文索引后在文档内容中匹配），持久化基于 `@kit.ArkData` preferences（`utils/PrefsStore.ets`）。
- 首页新增 全部/收藏/最近 三个 Tab；代码块右上角新增"复制"按钮，经系统剪贴板（`@kit.BasicServicesKit` pasteboard）复制全文并 Toast 反馈。

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

- 表格列宽目前按列数固定比例（2/3/4 列各有预设），后续可改为按单元格内容自适应。
- 图片语法 `![](url)` 与相对路径链接暂未渲染（语料中存在少量此类内容）。
- 全文搜索为启动后首次开启时一次性加载全部 615 篇文档构建内存索引，后续可改为预构建或增量索引。
