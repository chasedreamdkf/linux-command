<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { loadCommand } from '../utils/dataLoader';
import type { CommandInfo } from '../utils/parser';

const props = defineProps<{
  commandName: string;
}>();

const command = ref<CommandInfo | null>(null);
const loading = ref(true);
const error = ref<string | null>(null);

const loadCommandData = async () => {
  loading.value = true;
  error.value = null;

  try {
    const data = await loadCommand(props.commandName);
    if (data) {
      command.value = data;
    } else {
      error.value = '命令不存在';
    }
  } catch (err) {
    error.value = '加载命令失败';
    console.error(err);
  } finally {
    loading.value = false;
  }
};

onMounted(loadCommandData);

// 添加 watch 监听 commandName 的变化
watch(
  () => props.commandName,
  () => {
    loadCommandData();
  },
);
</script>

<template>
  <div class="command-detail">
    <div v-if="loading" class="loading">加载中...</div>
    <div v-else-if="error" class="error">
      {{ error }}
    </div>
    <div v-else-if="command" class="command-content">
      <h2>{{ command.name }}</h2>
      <div class="description">{{ command.description }}</div>
      <div v-html="command.html"></div>
    </div>
  </div>
</template>

<style scoped>
.loading,
.error {
  text-align: center;
  padding: 2rem;
  color: #666;
}

.error {
  color: #e74c3c;
}

.command-content h2 {
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid var(--primary-color);
}

.command-content h3 {
  margin: 1.5rem 0 1rem;
  color: var(--secondary-color);
}

.command-content ul,
.command-content ol {
  margin-left: 2rem;
  margin-bottom: 1rem;
}

.command-content li {
  margin-bottom: 0.5rem;
}
</style>
