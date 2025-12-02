import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import HomeView from '../HomeView.vue';
import { createRouter, createWebHistory } from 'vue-router';

// 创建一个简单的路由配置用于测试
const router = createRouter({
  history: createWebHistory(),
  routes: [{ path: '/', component: HomeView }],
});

describe('HomeView.vue', () => {
  it('should render search input and title', () => {
    const wrapper = mount(HomeView, {
      global: {
        plugins: [router],
      },
    });

    // 检查标题元素 - 修改为h2标签
    const titleElement = wrapper.find('h2');
    expect(titleElement.exists()).toBe(true);
    expect(titleElement.text()).toContain('搜索Linux命令');

    // 检查搜索输入框
    const searchInput = wrapper.find('input[type="text"]');
    expect(searchInput.exists()).toBe(true);
  });

  it('should bind search query to input', async () => {
    const wrapper = mount(HomeView, {
      global: {
        plugins: [router],
      },
    });

    const searchInput = wrapper.find('input[type="text"]');
    await searchInput.setValue('ls');

    // 验证搜索框的值被正确设置
    expect(searchInput.element.value).toBe('ls');
  });

  it('should pass searchQuery to CommandList', async () => {
    const wrapper = mount(HomeView, {
      global: {
        plugins: [router],
      },
    });

    const searchInput = wrapper.find('input[type="text"]');
    await searchInput.setValue('cd');

    // 检查CommandList组件的props
    const commandList = wrapper.findComponent({ name: 'CommandList' });
    expect(commandList.props('searchQuery')).toBe('cd');
  });
});
