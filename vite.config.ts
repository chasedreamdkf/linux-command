import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'happy-dom',
    globals: true,
    setupFiles: [],
    mockReset: true,
    clearMocks: true,
    include: ['**/__tests__/**/*.test.ts'],
    exclude: ['node_modules', 'dist', '.git'],
    // 增加测试超时时间
    testTimeout: 5000,
    // 配置覆盖率报告
    coverage: {
      reporter: ['text', 'json', 'html']
    }
  },
  build: {
    rollupOptions: {
      external: ['**/__tests__/**', '**/*.test.ts', '**/*.spec.ts']
    }
  }
});
