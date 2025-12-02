<script setup lang="ts">
import { ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import CommandDetail from '../components/CommandDetail.vue';

const route = useRoute();
const router = useRouter();
const commandName = ref(route.params.name as string);

// 监听路由参数变化
watch(
  () => route.params.name,
  (newName) => {
    commandName.value = newName as string;
  },
);

const goBack = () => {
  router.back();
};
</script>

<template>
  <div class="command-view">
    <button @click="goBack" class="back-button">← 返回列表</button>
    <CommandDetail :command-name="commandName" />
  </div>
</template>

<style scoped>
.command-view {
  max-width: 900px;
  margin: 0 auto;
}

.back-button {
  margin-bottom: 1rem;
  padding: 0.5rem 1rem;
  background-color: var(--secondary-color);
}

.back-button:hover {
  background-color: #1a252f;
}
</style>
