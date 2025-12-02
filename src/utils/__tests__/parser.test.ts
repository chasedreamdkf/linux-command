import { describe, it, expect, vi, beforeEach } from 'vitest';
import { parseMarkdown } from '../parser';

// 正确模拟marked库 - 使用具名导出而不是默认导出
vi.mock('marked', () => {
  const mockParse = vi.fn();
  return {
    marked: {
      use: vi.fn(),
      parse: mockParse,
    },
    // 为了支持不同版本的调用方式
    __esModule: true,
  };
});

describe('parser', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should parse markdown content correctly', async () => {
    // 模拟parse函数返回HTML
    const mockHtml = '<h1>ls</h1><p>ls命令用于列出目录内容。</p>';
    const { marked } = await import('marked');
    vi.mocked(marked.parse).mockResolvedValue(mockHtml);

    const markdownContent = `# ls

ls命令用于列出目录内容。

## 语法
ls [选项] [目录]`;

    const result = await parseMarkdown(markdownContent);

    expect(result).toEqual({
      name: 'ls',
      description: 'ls命令用于列出目录内容。',
      html: mockHtml,
    });
  });

  it('should handle markdown without description', async () => {
    const mockHtml = '<h1>help</h1>';
    const { marked } = await import('marked');
    vi.mocked(marked.parse).mockResolvedValue(mockHtml);

    const markdownContent = `# help`;

    const result = await parseMarkdown(markdownContent);

    expect(result).toEqual({
      name: 'help',
      description: '',
      html: mockHtml,
    });
  });
});
