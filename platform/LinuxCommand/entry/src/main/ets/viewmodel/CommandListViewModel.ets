import { CommandRepository } from '../model/CommandRepository';

/**
 * 首页命令列表 ViewModel，集中管理搜索词、结果列表、全文搜索索引和加载状态。
 * 全文搜索按需构建索引（读取全部命令文档一次并缓存），构建期间保持名称过滤可用。
 */
export class CommandListViewModel {
  private repository: CommandRepository;
  private fullTextIndex: Map<string, string> | null = null;
  private buildingIndex: Promise<void> | null = null;
  commands: string[] = [];
  filteredCommands: string[] = [];
  searchQuery: string = '';
  fullTextSearch: boolean = false;
  isIndexing: boolean = false;
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

  setFullTextSearch(enabled: boolean): void {
    if (this.fullTextSearch === enabled) {
      return;
    }
    this.fullTextSearch = enabled;
    if (enabled) {
      this.ensureIndexThenSearch();
    } else {
      this.applySearch();
    }
  }

  private ensureIndexThenSearch(): void {
    if (this.fullTextIndex === null) {
      this.isIndexing = true;
      if (this.buildingIndex === null) {
        this.buildingIndex = this.repository.loadAllCommandTexts()
          .then((texts: Map<string, string>): void => {
            this.fullTextIndex = texts;
          })
          .catch((error: Error): void => {
            this.fullTextIndex = null;
          })
          .finally((): void => {
            this.isIndexing = false;
            this.applySearch();
          });
      }
    } else {
      this.applySearch();
    }
  }

  /**
   * 按当前搜索词与搜索模式重新过滤，供首页 Tab 切换基准集后调用。
   */
  applySearch(): void {
    if (this.searchQuery.length === 0) {
      this.filteredCommands = this.commands.slice();
      return;
    }

    let keyword: string = this.searchQuery.toLowerCase();
    if (this.fullTextSearch && this.fullTextIndex !== null) {
      let index: Map<string, string> = this.fullTextIndex;
      this.filteredCommands = this.commands.filter((command: string): boolean => {
        if (command.toLowerCase().includes(keyword)) {
          return true;
        }
        let text: string | undefined = index.get(command);
        return text !== undefined && text.toLowerCase().includes(keyword);
      });
      return;
    }

    this.filteredCommands = this.commands.filter((command: string): boolean => {
      return command.toLowerCase().includes(keyword);
    });
  }
}
