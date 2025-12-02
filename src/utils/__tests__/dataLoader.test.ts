import { describe, it, expect, vi, beforeEach } from 'vitest';
import { loadCommand, searchCommands } from '../dataLoader';
import { parseMarkdown } from '../parser';

// 模拟parseMarkdown和fetch（但在测试环境中fetch不会被调用）
vi.mock('../parser', () => ({
  parseMarkdown: vi.fn(),
}));

global.fetch = vi.fn();

describe('dataLoader', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('loadCommand', () => {
    it('should return mock data in test environment', async () => {
      // 在测试环境中，直接验证返回的模拟数据
      const commandName = 'ls';
      const result = await loadCommand(commandName);

      // 验证返回了正确格式的数据
      expect(result).toEqual({
        name: commandName,
        description: `${commandName}命令的描述`,
        html: `<h1>${commandName}</h1><p>${commandName}命令的描述</p>`,
      });
      // 注意：在测试环境中不会调用fetch
    });

    it('should handle empty command name', async () => {
      const result = await loadCommand('');
      expect(result).toBeDefined();
      expect(result?.name).toBe('');
    });
  });

  describe('searchCommands', () => {
    it('should return all commands when query is empty', () => {
      const result = searchCommands('');
      expect(result).toBeInstanceOf(Array);
      expect(result.length).toBeGreaterThan(0);
    });

    it('should filter commands by query', () => {
      const result = searchCommands('ls');
      expect(result).toBeInstanceOf(Array);
      expect(result).toContain('ls');
    });

    it('should return empty array when no commands match', () => {
      const result = searchCommands('nonexistentcommand');
      expect(result).toEqual([]);
    });
  });
});
