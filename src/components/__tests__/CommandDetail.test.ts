import { describe, it, expect, vi, beforeEach } from 'vitest';
import { mount } from '@vue/test-utils';
import CommandDetail from '../CommandDetail.vue';
import { loadCommand } from '../../utils/dataLoader';

// Mock dataLoader
vi.mock('../../utils/dataLoader', () => ({
  loadCommand: vi.fn(),
}));

describe('CommandDetail.vue', () => {
  let wrapper: any;

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should display loading state initially', () => {
    wrapper = mount(CommandDetail, {
      props: {
        commandName: 'ls',
      },
    });

    expect(wrapper.find('.loading').exists()).toBe(true);
  });

  it('should display command content when loaded successfully', async () => {
    const mockCommandInfo = {
      name: 'ls',
      description: 'ls命令用于列出目录内容。',
      html: '<h1>ls</h1><p>ls命令用于列出目录内容。</p>',
    };

    // 使用mockResolvedValue来模拟Promise解析
    vi.mocked(loadCommand).mockResolvedValue(mockCommandInfo);

    wrapper = mount(CommandDetail, {
      props: {
        commandName: 'ls',
      },
    });

    // 等待异步加载完成
    await new Promise((resolve) => setTimeout(resolve, 0));
    await wrapper.vm.$nextTick();

    expect(wrapper.find('.loading').exists()).toBe(false);
    expect(wrapper.find('.command-content').exists()).toBe(true);
    // 调整断言以适应实际渲染的DOM结构
    expect(wrapper.find('.command-content').text()).toContain(mockCommandInfo.name);
    expect(wrapper.find('.command-content').text()).toContain(mockCommandInfo.description);
  });

  it('should display error when loading fails', async () => {
    // 模拟loadCommand返回null，表示错误
    vi.mocked(loadCommand).mockResolvedValue(null);

    wrapper = mount(CommandDetail, {
      props: {
        commandName: 'nonexistent',
      },
    });

    await new Promise((resolve) => setTimeout(resolve, 0));
    await wrapper.vm.$nextTick();

    expect(wrapper.find('.loading').exists()).toBe(false);
    expect(wrapper.find('.error').exists()).toBe(true);
  });

  it('should update when commandName changes', async () => {
    const mockCommandInfo1 = {
      name: 'ls',
      description: 'ls命令用于列出目录内容。',
      html: '<h1>ls</h1><p>ls命令用于列出目录内容。</p>',
    };

    const mockCommandInfo2 = {
      name: 'cd',
      description: '切换目录命令。',
      html: '<h1>cd</h1><p>切换目录命令。</p>',
    };

    // 先mock初始值
    vi.mocked(loadCommand).mockResolvedValue(mockCommandInfo1);

    wrapper = mount(CommandDetail, {
      props: {
        commandName: 'ls',
      },
    });

    await new Promise((resolve) => setTimeout(resolve, 0));
    await wrapper.vm.$nextTick();

    // 更改mock返回值
    vi.mocked(loadCommand).mockResolvedValue(mockCommandInfo2);

    // 更新commandName
    await wrapper.setProps({ commandName: 'cd' });
    await new Promise((resolve) => setTimeout(resolve, 0));
    await wrapper.vm.$nextTick();

    // 验证loadCommand被调用了2次（一次初始加载，一次名称变更时）
    expect(loadCommand).toHaveBeenCalledTimes(2);
    expect(loadCommand).toHaveBeenLastCalledWith('cd');
  });
});
