# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`linux-command-vue` 是一个 Linux 命令搜索与文档查看工具，基于 Vue 3 + TypeScript + Vite 重构自 [jaywcjlove/linux-command](https://github.com/jaywcjlove/linux-command)。命令文档以 Markdown 格式存储在 `public/commands/` 下，通过浏览器直接 `fetch` 静态资源并解析为 HTML 展示。

## Commands

```bash
pnpm dev          # 启动开发服务器（默认 http://localhost:5173）
pnpm build        # vue-tsc 类型检查 + vite 构建
pnpm build-only   # 仅 vite 构建，跳过类型检查
pnpm preview      # 本地预览构建产物
pnpm test         # 运行 vitest 单元测试
pnpm type-check   # 仅运行 vue-tsc 类型检查
pnpm lint         # ESLint 自动修复
pnpm format       # Prettier 格式化 src/
```

运行单个测试文件：

```bash
pnpm vitest run src/utils/__tests__/parser.test.ts
```

## Architecture

### 数据流

```
HomeView (searchQuery ref)
  └── CommandList (props.searchQuery)
        └── searchCommands(query) [dataLoader.ts]
              └── ALL_COMMANDS (硬编码数组，按字母排序)

CommandView (route.params.name)
  └── CommandDetail (props.commandName)
        └── loadCommand(name) [dataLoader.ts]
              └── fetch /commands/{name}.md
                    └── parseMarkdown(content) [parser.ts]
                          └── CommandInfo { name, description, html }
```

### 关键约定

**添加新命令需要两步同时完成：**
1. 在 `src/utils/dataLoader.ts` 的 `ALL_COMMANDS` 数组中添加命令名（数组末尾，`.sort()` 会自动排序）
2. 在 `public/commands/<name>.md` 创建 Markdown 文件

Markdown 文件格式须与 `parser.ts` 的解析逻辑匹配：第一行 `# 命令名`（提取为 `name`），第二段第一行文字（提取为 `description`）。

**路由定义重复**：`src/main.ts` 中内联定义了实际使用的路由，`src/router.ts` 是一个冗余的副本，未被 `main.ts` 引入——如需修改路由，改 `main.ts`。

### 测试

- 测试文件位于各模块的 `__tests__/` 子目录，命名规则 `*.test.ts`
- 使用 `happy-dom` 模拟浏览器 DOM，`@vue/test-utils` 挂载组件
- `dataLoader.ts` 中部分环境检测代码已被注释掉（`NODE_ENV === 'test'`），当前测试依赖对 `fetch` 和 `marked` 的 mock

## Commit Convention

项目强制使用规范化提交。推荐使用交互式工具：

```bash
npx cz
```

允许的 type：`feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore` / `revert` / `build`

pre-commit hook 会自动对 `src/**/*.{js,vue}` 运行 `eslint --fix`。
