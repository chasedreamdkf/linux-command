# linux-command-vue 开发文档

## 1. 项目概述

`linux-command-vue` 是基于 [jaywcjlove/linux-command](https://github.com/jaywcjlove/linux-command) Web 版本和 [haloislet/linux-command](https://github.com/haloislet/linux-command) 桌面版本，用 `Vue 3 + TypeScript + Vite` 重构的 Linux 命令搜索与文档查看工具。

- 前端框架：`Vue 3`
- 语言：`TypeScript`
- 构建工具：`Vite 5`
- 路由：`vue-router 4`
- 状态管理：`pinia`（目前未大量使用，可扩展）
- Markdown 解析：`marked`
- 代码高亮：`highlight.js`
- 测试：`vitest` + `@vue/test-utils` + `happy-dom`
- 代码规范：`ESLint` + `eslint-plugin-vue` + `Prettier`
- 提交规范：`husky` + `lint-staged` + `commitlint` + `commitizen`

命令文档存放在 `public/commands/*.md` 中，通过浏览器直接访问静态资源并解析为 HTML。

---

## 2. 开发环境准备

### 2.1 Node / pnpm 版本

- Nodejs：建议 **Node >= 18**(Vite 5 官方要求), 建议提前安装`fnm`、`nvm`等`nodejs`版本管理器
- 包管理器：项目推荐使用 `pnpm`

安装 pnpm（如果本机没有）：

```bash
npm install -g pnpm
```

### 2.2 克隆项目

```bash
git clone https://github.com/chasedreamdkf/linux-command-vue.git
cd linux-command-vue
```

---

## 3. 安装与运行

### 3.1 安装依赖

```bash
pnpm install
```

### 3.2 本地开发启动

```bash
pnpm dev
```

启动后，控制台会输出本地访问地址（默认类似）：

- `http://localhost:5173/`

浏览器打开即可。

### 3.3 构建生产包

```bash
pnpm build
```

构建输出在 `dist/` 目录。

### 3.4 本地预览构建产物

```bash
pnpm preview
```

---

## 4. 常用 npm 脚本说明

所有脚本定义在 `package.json` 的 `scripts` 中：

| 命令                | 作用说明                                    |
|---------------------|---------------------------------------------|
| `pnpm dev`          | 启动开发服务器（Vite）                      |
| `pnpm build`        | TypeScript 类型检查 + 构建生产包            |
| `pnpm build-only`   | 仅使用 Vite 构建生产包（不跑 vue-tsc）     |
| `pnpm preview`      | 本地预览构建后的生产包                      |
| `pnpm test`         | 使用 Vitest 运行单元测试                    |
| `pnpm type-check`   | 使用 `vue-tsc --build` 做类型检查           |
| `pnpm lint`         | 运行 ESLint 自动修复并缓存结果              |
| `pnpm format`       | 使用 Prettier 格式化 `src/` 下的代码        |
| `pnpm prepare`      | 安装 husky（由 Git hooks 自动调用）        |

开发过程中建议的基本流程：

1. 编码后先执行 `pnpm lint` 和 `pnpm format`
2. 编写或修改功能后执行 `pnpm test`
3. 提交前确保 `pnpm build` 能正常通过

---

## 5. 项目结构说明

根目录结构（关键部分）：

- `src/`：前端业务代码
  - `main.ts`：应用入口，创建 `Vue` 实例与路由
  - `App.vue`：顶层布局（头部/主体/底部）
  - `router.ts`：路由配置（也被 `main.ts` 内嵌了一份简易路由）
  - `assets/`
    - `main.css`：全局样式（包括命令列表布局等）
  - `components/`
    - `CommandList.vue`：命令列表组件（搜索结果显示）
    - `CommandDetail.vue`：命令详情组件（展示某个命令的 Markdown 内容）
    - `__tests__/`：组件测试
  - `views/`
    - `HomeView.vue`：主页视图，包含搜索输入 + 命令列表
    - `CommandView.vue`：命令详情页，包含返回按钮 + `CommandDetail`
    - `__tests__/`：视图测试
  - `utils/`
    - `dataLoader.ts`：命令列表、命令详情的加载与搜索逻辑
    - `parser.ts`：命令 Markdown 的解析（提取标题/描述并转 HTML）
    - `__tests__/`：工具函数测试
- `public/`
  - `commands/*.md`：每个命令对应一个 Markdown 文件
- `vite.config.ts`：Vite 配置（含 vitest 配置与打包排除测试文件）
- `eslint.config.ts`：ESLint 配置
- `tsconfig*.json`：TypeScript 配置
- `commitlint.config.cts`、`.cz-config.cts`：提交规范配置
- `docs/`：示例截图等文档资源

---

## 6. 前端架构与核心逻辑

### 6.1 路由与页面

路由定义（`src/main.ts` 与 `src/router.ts` 一致）：

- `/` → `HomeView`
- `/command/:name` → `CommandView`

`App.vue` 作为根组件，包含：

- `header`：项目标题
- `main`：`<router-view />` 渲染当前路由组件
- `footer`：项目说明

### 6.2 命令列表与搜索（`CommandList.vue` + `dataLoader.ts`）

- 搜索输入在 `HomeView.vue` 中维护：

  ```ts
  const searchQuery = ref('');
  ```

- `CommandList` 通过 `props.searchQuery` 接收搜索关键字，并调用：

  ```ts
  const commands = searchCommands(props.searchQuery);
  ```

- `dataLoader.ts` 中核心函数：

  - `getCommandList()`：返回当前缓存的命令列表（若未加载则使用 `ALL_COMMANDS`）
  - `preloadCommandList()`：预加载命令列表（当前实现为使用本地硬编码 `ALL_COMMANDS`）
  - `searchCommands(query: string)`：根据关键字过滤命令名称

命令列表来源：

- `ALL_COMMANDS`：在 `dataLoader.ts` 中硬编码的全量命令名数组，并按字母排序
- 当前实现没有动态从后端/目录扫描，只依赖代码中的常量数组（稳定可靠）

### 6.3 命令详情加载与解析（`CommandDetail.vue` + `dataLoader.ts` + `parser.ts`）

命令详情渲染流程：

1. 在 `CommandView.vue` 中，根据路由参数获取命令名：

   ```ts
   const commandName = ref(route.params.name as string);
   ```

2. 将 `commandName` 传给 `CommandDetail`：

   ```html
   <CommandDetail :command-name="commandName" />
   ```

3. `CommandDetail` 中调用 `loadCommand`：

   ```ts
   const data = await loadCommand(props.commandName);
   ```

4. `dataLoader.ts` 的 `loadCommand` ：

   - 构造 URL：`/commands/${commandName}.md`
   - 使用 `fetch` 加载对应 Markdown 文件内容
   - 调用 `parseMarkdown(content)` 转换为结构化数据 `CommandInfo`

5. `parser.ts` 的 `parseMarkdown`：

   - 从 Markdown 内容中提取：
     - `name`：第一个 `# 标题`
     - `description`：第一段文字
   - 使用 `marked` 将 Markdown 转换为 `html` 字符串
   - 返回结构：

     ```ts
     interface CommandInfo {
       name: string;
       description: string;
       html: string;
     }
     ```

6. `CommandDetail` 使用 `v-html="command.html"` 渲染解析后的 HTML。

---

## 7. 如何新增 / 修改命令文档

新增一个命令（例如 `foo`）的步骤：

1. **在命令列表中注册命令**

   打开 `src/utils/dataLoader.ts`，在 `ALL_COMMANDS` 数组中添加命令名：

   ```ts
   const ALL_COMMANDS = [
     // ...
     'foo',
   ].sort();
   ```

2. **添加 Markdown 文档**

   在 `public/commands/` 目录下创建文件：

   - `public/commands/foo.md`

   内容建议结构（与 `parser.ts` 的解析方式匹配）：

   ```markdown
   # foo

   这是 foo 命令的简要描述（将会作为列表中的描述摘要）。

   ## 语法

   ```bash
   foo [options] <args>
   ```

   ## 示例

   ```bash
   foo -h
   foo --bar=baz
   ```
   ```

3. **本地启动或刷新页面**

   - 开发模式下 `pnpm dev` 运行时，直接刷新页面即可生效。
   - 在首页搜索框输入 `foo`，列表中出现 `foo` 命令，点击可进入 `/command/foo` 查看详情。

4. **修改已有命令**

   - 修改 `public/commands/<name>.md` 内容即可。
   - 如需隐藏某命令，在 `ALL_COMMANDS` 中移除名称。

---

## 8. 代码规范与提交规范

### 8.1 代码风格

- 使用 `TypeScript`，尽量为函数与公共 API 写明类型。
- 组件优先使用 `<script setup lang="ts">`（`HomeView.vue`、`CommandView.vue`、`CommandDetail.vue` 皆如此）。
- 样式优先使用 `scoped`，通用样式放在 `src/assets/main.css`。
- 统一通过 `Prettier` 格式化：

  ```bash
  pnpm format
  ```

- 静态检查：

  ```bash
  pnpm lint
  pnpm type-check
  ```

### 8.2 Git 提交规范

项目集成了：

- `husky`：Git Hooks
- `lint-staged`：在提交前对改动的 `src/**/*.{js,vue}` 运行 `eslint --fix`
- `commitlint`：约束提交消息格式
- `commitizen` + `cz-customizable`：交互式生成符合规范的 commit message

典型流程（建议）：

1. 代码开发与自测
2. 运行 `pnpm lint`、`pnpm test`、`pnpm build`
3. 使用 commitizen（视你的本地配置，可以是 `npx cz` 或配置 `pnpm cz`）
4. `git push`

---

## 9. 测试说明

测试配置位于 `vite.config.ts`：

- 测试框架：`vitest`
- 运行命令：`pnpm test`
- 测试环境：`happy-dom`（模拟浏览器 DOM）
- 测试文件匹配：`**/__tests__/**/*.test.ts`
- 覆盖率输出：`text`、`json`、`html`

编写测试时：

- 组件测试放在对应目录下的 `__tests__` 中
- 使用 `@vue/test-utils` 挂载组件并断言渲染结果
- 对 `utils/` 中的函数（如 `parseMarkdown`、`searchCommands`）编写纯函数测试

---

## 10. 打包与部署

### 10.1 构建

```bash
pnpm build
```

生成的静态文件位于 `dist/` 目录。

### 10.2 静态部署

可以将 `dist/` 直接部署到任意静态站点服务：

- Nginx / Apache
- GitHub Pages
- Vercel / Netlify 等

注意事项：

- 命令文档依赖 `public/commands/*.md`，构建后也会一并输出到 `dist/commands/`，保证路径 `/commands/<name>.md` 可访问即可。
- 如果修改了 `base` 路由前缀，需要同时调整 Vite 配置中的 `base` 和服务端的静态资源路径。
