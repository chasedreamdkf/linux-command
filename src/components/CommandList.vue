<template>
  <div class="command-list">
    <!-- 直接在command-list上应用网格布局，移除多余的command-grid嵌套 -->
    <div v-for="command in commands" :key="command" class="command-item" @click="handleCommandClick(command)">
      {{ command }}
    </div>
    <div v-if="commands.length === 0" class="no-results">没有找到匹配的命令</div>
  </div>
</template>

<script lang="ts">
import { ref, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import { searchCommands, preloadCommandList } from '../utils/dataLoader';

export default {
  name: 'CommandList',
  props: {
    searchQuery: {
      type: String,
      default: '',
    },
  },
  setup(props) {
    const router = useRouter();
    // 正确指定类型为string[]
    const commands = ref<string[]>([]);

    const updateCommands = () => {
      commands.value = searchCommands(props.searchQuery);
    };

    // 明确指定参数类型
    const handleCommandClick = (command: string) => {
      router.push(`/command/${command}`);
    };

    onMounted(async () => {
      // 预加载命令列表
      await preloadCommandList().catch((error) => {
        console.warn('Preloading command list failed, using fallback:', error);
      });
      updateCommands();
    });

    watch(
      () => props.searchQuery,
      () => {
        updateCommands();
      },
    );

    return {
      commands,
      handleCommandClick,
    };
  },
};
</script>

<style scoped>
/* 移除command-list的重新定义，让main.css中的网格布局生效 */
/* 只保留padding等必要样式 */
.command-list {
  padding: 20px;
  width: 100%;
  box-sizing: border-box;
}

/* 增强command-item样式 */
.command-item {
  padding: 12px 16px;
  cursor: pointer;
  border: 1px solid #ddd;
  border-radius: 6px;
  transition: all 0.3s ease;
  text-align: center;
  background-color: #ffffff;
  box-sizing: border-box;
  word-wrap: break-word;
}

.command-item:hover {
  background-color: #f8f9fa;
  border-color: #007bff;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 123, 255, 0.1);
}

.no-results {
  text-align: center;
  color: #666;
  padding: 40px 20px;
  grid-column: 1 / -1;
}

/* 响应式设计 - 覆盖main.css中的默认网格布局 */
@media (max-width: 768px) {
  .command-list {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)) !important;
    gap: 8px !important;
  }
}

@media (max-width: 480px) {
  .command-list {
    grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)) !important;
  }
}
</style>
