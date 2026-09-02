import { CommandInfo } from '../model/CommandModel';
import { CommandRepository } from '../model/CommandRepository';

/**
 * 命令详情 ViewModel，负责按命令名读取 Markdown 并转换为渲染数据。
 */
export class CommandDetailViewModel {
  private repository: CommandRepository;
  command: CommandInfo | null = null;
  isLoading: boolean = false;
  errorMessage: string = '';

  constructor(repository: CommandRepository) {
    this.repository = repository;
  }

  async loadCommand(commandName: string): Promise<CommandInfo | null> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      this.command = await this.repository.loadCommand(commandName);
      if (this.command === null) {
        this.errorMessage = '命令不存在';
      }
      return this.command;
    } catch (error) {
      this.command = null;
      this.errorMessage = '命令详情加载失败';
      return null;
    } finally {
      this.isLoading = false;
    }
  }
}
