<script setup lang="ts">
import { ref } from 'vue';
import CommandList from '../components/CommandList.vue';

const searchQuery = ref('');
</script>

<template>
  <div class="home-view">
    <div class="search-container">
      <h2>搜索Linux命令</h2>
      <input type="text" v-model="searchQuery" placeholder="输入命令名称搜索（例如：ls, cd, grep）..." />
      <!-- 移除不必要的@input="$event"绑定 -->
    </div>
    <CommandList :search-query="searchQuery" />
  </div>
</template>

<style scoped>
.home-view {
  max-width: 1000px;
  margin: 0 auto;
}

.search-container {
  margin-bottom: 2rem;
}

.search-container h2 {
  margin-bottom: 1rem;
  color: var(--secondary-color);
}
</style>
