import { CommandRepository } from '../model/CommandRepository';

/**
 * 首页命令列表 ViewModel，集中管理搜索词、结果列表和加载状态。
 */
export class CommandListViewModel {
  private repository: CommandRepository;
  commands: string[] = [];
  filteredCommands: string[] = [];
  searchQuery: string = '';
  isLoading: boolean = false;
  errorMessage: string = '';

  constructor(repository: CommandRepository) {
    this.repository = repository;
  }

  async initialize(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      this.commands = await this.repository.loadCommandList();
      this.applySearch();
    } catch (error) {
      this.filteredCommands = [];
      this.errorMessage = '命令列表加载失败';
    } finally {
      this.isLoading = false;
    }
  }

  updateSearch(query: string): void {
    this.searchQuery = query.trim();
    this.applySearch();
  }

  private applySearch(): void {
    if (this.searchQuery.length === 0) {
      this.filteredCommands = this.commands.slice();
      return;
    }

    let keyword: string = this.searchQuery.toLowerCase();
    this.filteredCommands = this.commands.filter((command: string): boolean => {
      return command.toLowerCase().includes(keyword);
    });
  }
}
