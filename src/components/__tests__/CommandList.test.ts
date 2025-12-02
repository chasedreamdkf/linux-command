import { describe, it, expect, vi, beforeEach } from 'vitest';
import { mount } from '@vue/test-utils';
import CommandList from '../CommandList.vue';
import { searchCommands } from '../../utils/dataLoader';
import { createRouter, createWebHistory } from 'vue-router';

// Mock dataLoader
vi.mock('../../utils/dataLoader', () => ({
  searchCommands: vi.fn(),
}));

describe('CommandList.vue', () => {
  let mockRouter: any;

  beforeEach(() => {
    vi.clearAllMocks();

    // 创建mock router
    mockRouter = createRouter({
      history: createWebHistory(),
      routes: [],
    });
    // 模拟push方法
    mockRouter.push = vi.fn();
  });

  it('should render command list when commands exist', async () => {
    // Mock searchCommands to return sample data
    vi.mocked(searchCommands).mockReturnValue(['ls', 'cd', 'pwd']);

    const wrapper = mount(CommandList, {
      props: {
        searchQuery: '',
      },
      global: {
        plugins: [mockRouter], // 使用插件方式提供router
      },
    });

    // 等待组件挂载和更新完成
    await wrapper.vm.$nextTick();

    // 检查命令项数量
    const commandItems = wrapper.findAll('.command-item');
    expect(commandItems.length).toBe(3);
    expect(commandItems[0].text()).toBe('ls');
  });

  it('should display no results message when no commands match', async () => {
    vi.mocked(searchCommands).mockReturnValue([]);

    const wrapper = mount(CommandList, {
      props: {
        searchQuery: 'nonexistent',
      },
      global: {
        plugins: [mockRouter],
      },
    });

    await wrapper.vm.$nextTick();

    const noResults = wrapper.find('.no-results');
    expect(noResults.exists()).toBe(true);
    expect(noResults.text()).toBe('没有找到匹配的命令');
  });

  it('should update commands when searchQuery changes', async () => {
    // 初始mock返回
    vi.mocked(searchCommands).mockReturnValue(['ls']);

    const wrapper = mount(CommandList, {
      props: {
        searchQuery: 'ls',
      },
      global: {
        plugins: [mockRouter],
      },
    });

    await wrapper.vm.$nextTick();

    // 更改mock返回值
    vi.mocked(searchCommands).mockReturnValue(['cd']);

    // 更新searchQuery prop
    await wrapper.setProps({ searchQuery: 'cd' });
    await wrapper.vm.$nextTick();

    // 检查命令项是否更新
    const commandItems = wrapper.findAll('.command-item');
    expect(commandItems.length).toBe(1);
    expect(commandItems[0].text()).toBe('cd');
  });

  it('should navigate to command detail when clicked', async () => {
    vi.mocked(searchCommands).mockReturnValue(['ls']);

    const wrapper = mount(CommandList, {
      props: {
        searchQuery: '',
      },
      global: {
        plugins: [mockRouter],
      },
    });

    await wrapper.vm.$nextTick();

    // 触发点击事件
    const commandItem = wrapper.find('.command-item');
    if (commandItem.exists()) {
      await commandItem.trigger('click');
      expect(mockRouter.push).toHaveBeenCalledWith('/command/ls');
    } else {
      console.error('Command item not found');
    }
  });
});
