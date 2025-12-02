import { describe, it, expect, vi, beforeEach } from 'vitest';
import { mount } from '@vue/test-utils';
import CommandView from '../CommandView.vue';
import { createRouter, createWebHistory } from 'vue-router';
import { loadCommand } from '../../utils/dataLoader';

// Mock loadCommand函数以避免实际的fetch调用
vi.mock('../../utils/dataLoader', () => ({
  loadCommand: vi.fn().mockResolvedValue({
    name: 'ls',
    description: 'ls命令用于列出目录内容。',
    html: '<h1>ls</h1><p>ls命令用于列出目录内容。</p>',
  }),
}));

// 创建一个简单的路由配置
const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'Home', component: { template: '<div>Home</div>' } },
    {
      path: '/command/:name',
      name: 'CommandDetail',
      component: { template: '<div>Command Detail</div>' },
    },
  ],
});

describe('CommandView.vue', () => {
  let wrapper: any;

  beforeEach(async () => {
    // 在每个测试前设置路由参数
    await router.push('/command/ls');
    await router.isReady();
  });

  it('should render back button and CommandDetail', async () => {
    wrapper = mount(CommandView, {
      global: {
        plugins: [router],
      },
    });

    expect(wrapper.find('button').exists()).toBe(true);
    expect(wrapper.find('button').text()).toContain('返回');
  });

  it('should pass command name to CommandDetail', async () => {
    // 模拟CommandDetail组件
    const mockCommandDetail = {
      name: 'CommandDetail',
      template: '<div class="command-detail">{{ commandName }}</div>',
      props: ['commandName'],
    };

    wrapper = mount(CommandView, {
      global: {
        plugins: [router],
        stubs: {
          CommandDetail: mockCommandDetail,
        },
      },
    });

    await wrapper.vm.$nextTick();
    // 直接检查传递给stub组件的prop
    expect(wrapper.html()).toContain('ls');
  });

  it('should call router.back() when back button is clicked', async () => {
    // Mock router.back方法
    const backSpy = vi.spyOn(router, 'back').mockImplementation(() => {});

    wrapper = mount(CommandView, {
      global: {
        plugins: [router],
      },
    });

    // 点击返回按钮
    await wrapper.find('button').trigger('click');

    // 验证router.back被调用
    expect(backSpy).toHaveBeenCalled();

    // 恢复原始方法
    backSpy.mockRestore();
  });
});
