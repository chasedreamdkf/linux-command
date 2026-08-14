# AGENTS.md

Vue 3 + TypeScript + Vite 重构的 Linux 命令搜索/文档站。命令文档为 `public/commands/*.md` 静态文件。回复使用中文。

## 环境与命令

- Node 版本固定为 `22.21.1`（`package.json` engines），包管理用 **pnpm**。
- `pnpm dev` 启动 Vite 开发服务器。
- `pnpm build` = `vue-tsc` 类型检查 + `vite build`（提交前必须通过）。
- 验证流程：`pnpm lint`（ESLint 自动修复+缓存）→ `pnpm type-check` → `pnpm test` → `pnpm build`。
- `pnpm test`：Vitest + happy-dom，测试文件匹配 `**/__tests__/**/*.test.ts`（组件与 views 下同名目录）。

## 架构要点

- 命令**列表**由 `src/utils/dataLoader.ts` 中**硬编码**的 `ALL_COMMANDS` 数组提供（约 600 项，字母排序）。不要改成运行时扫描 `public/commands/`，浏览器拿不到目录内容。
- 命令**详情**通过 `fetch('/commands/<name>.md')` 加载，再经 `src/utils/parser.ts` 的 `parseMarkdown` 用 `marked` 转 HTML，`CommandDetail.vue` 用 `v-html` 渲染。
- **新增命令需两处改动**：在 `ALL_COMMANDS` 数组加名字，并新建 `public/commands/<name>.md`（首行 `# 名称`，第二段作描述摘要）。缺任一处命令就不完整。
- 路由：`/` → `HomeView`，`/command/:name` → `CommandView`。配置在 `src/main.ts` 与 `src/router.ts`（两处需保持一致）。

## server/（Python FastAPI，独立且未接入前端）

- `server/` 是“前后端分离”方向的 WIP：`main.py` 提供 `/commandslist` 与 `/command/{cmd}`。前端目前**并未调用**它，仍走硬编码列表 + 静态 md。
- ESLint 已忽略 `server/**`，改动它不受前端 lint 约束。
- 启动：`bash server/start.sh`（uvicorn，端口 8080）；依赖见 `server/main.py`（fastapi、markdown、fastapi-cdn-host）。

## 提交规范

- Conventional Commits 通过 husky + lint-staged + commitlint 强制；lint-staged 只对 `src/**/*.{js,vue}` 跑 `eslint --fix`。
- 用 commitizen 交互式提交（`npx cz`）：type 限 `feat|fix|docs|style|refactor|perf|test|chore|revert|build`。

## 坑

- README-DEV.md 第 6.2 节描述“列表来自后端/目录扫描”已过时，现行为硬编码数组。
- 组件统一 `<script setup lang="ts">`；样式优先 `scoped`。
