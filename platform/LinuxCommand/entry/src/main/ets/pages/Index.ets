import { common } from '@kit.AbilityKit';

import { APP_SUBTITLE, APP_TITLE, COMMAND_DETAIL_ROUTE } from '../common/Constants';
import { CommandInfo, MarkdownBlock } from '../model/CommandModel';
import { CommandRepository } from '../model/CommandRepository';
import { CommandDetailViewModel } from '../viewmodel/CommandDetailViewModel';
import { CommandListViewModel } from '../viewmodel/CommandListViewModel';
import { PrefsStore } from '../utils/PrefsStore';
import { showToast } from '../utils/Toast';
import { CommandDetailView } from '../views/CommandDetailView';
import { CommandGrid } from '../views/CommandGrid';
import { SearchBar } from '../views/SearchBar';

type HomeTab = 'all' | 'favorites' | 'recent';

@Entry
@Component
struct Index {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @StorageProp('favoriteVersion') @Watch('onFavoriteVersionChanged') favoriteVersion: number = 0;
  @State searchQuery: string = '';
  @State commands: string[] = [];
  @State allCommands: string[] = [];
  @State homeTab: HomeTab = 'all';
  @State favorites: string[] = [];
  @State recent: string[] = [];
  @State fullTextSearch: boolean = false;
  @State isIndexing: boolean = false;
  @State selectedCommand: string = '';
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @StorageProp('currentWidthBreakpoint') @Watch('onWidthBreakpointChanged') currentWidthBreakpoint: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  private listViewModel: CommandListViewModel | null = null;
  private prefsStore: PrefsStore = new PrefsStore();

  aboutToAppear(): void {
    this.loadCommands();
  }

  /**
   * 详情页收藏变更后 bump favoriteVersion，这里重新读取持久化状态同步星标与收藏 Tab。
   */
  private onFavoriteVersionChanged(): void {
    this.loadPrefs();
  }

  private ensureListViewModel(): CommandListViewModel | null {
    if (this.listViewModel !== null) {
      return this.listViewModel;
    }

    let hostContext: Object | undefined = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      this.errorMessage = '无法获取应用上下文';
      return null;
    }

    let context: common.UIAbilityContext = hostContext as common.UIAbilityContext;
    let repository: CommandRepository = new CommandRepository(context);
    this.listViewModel = new CommandListViewModel(repository);
    this.prefsStore.init(context);
    return this.listViewModel;
  }

  private async loadCommands(): Promise<void> {
    let viewModel: CommandListViewModel | null = this.ensureListViewModel();
    if (viewModel === null) {
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    await viewModel.initialize();
    this.allCommands = viewModel.commands.slice();
    await this.loadPrefs();
    this.isLoading = viewModel.isLoading;
    this.errorMessage = viewModel.errorMessage;
    this.applyListFilter();
    this.ensureDefaultDetailInSplit();
  }

  private async loadPrefs(): Promise<void> {
    this.favorites = await this.prefsStore.getFavorites();
    this.recent = await this.prefsStore.getRecent();
    this.applyListFilter();
  }

  private async handleFavoriteToggle(commandName: string): Promise<void> {
    let isFavorite: boolean = await this.prefsStore.toggleFavorite(commandName);
    this.favorites = await this.prefsStore.getFavorites();
    if (this.homeTab === 'favorites') {
      this.applyListFilter();
    }
    let message: string = isFavorite ? '已收藏' : '已取消收藏';
    showToast(this.getUIContext(), message);
  }

  private async openCommandDetail(commandName: string): Promise<void> {
    await this.prefsStore.addRecent(commandName);
    this.recent = await this.prefsStore.getRecent();
    if (this.homeTab === 'recent') {
      this.applyListFilter();
    }
    let shouldReplaceDetail: boolean = this.isSplitMode() && this.selectedCommand.length > 0 && this.navPathStack.size() > 0;
    this.selectedCommand = commandName;
    if (shouldReplaceDetail) {
      this.navPathStack.replacePathByName(COMMAND_DETAIL_ROUTE, commandName);
      return;
    }
    this.navPathStack.pushPathByName(COMMAND_DETAIL_ROUTE, commandName);
  }

  private handleSearchChange(value: string): void {
    this.searchQuery = value;
    let viewModel: CommandListViewModel | null = this.ensureListViewModel();
    if (viewModel === null) {
      return;
    }
    viewModel.updateSearch(value);
    this.errorMessage = viewModel.errorMessage;
    this.isIndexing = viewModel.isIndexing;
    this.applyListFilter();
  }

  private handleFullTextSearchChange(enabled: boolean): void {
    let viewModel: CommandListViewModel | null = this.ensureListViewModel();
    if (viewModel === null) {
      return;
    }
    this.fullTextSearch = enabled;
    viewModel.setFullTextSearch(enabled);
    this.applyListFilter();
  }

  /**
   * 首页 Tab 决定搜索基准集，搜索在基准集上由 ViewModel 过滤。
   */
  private applyListFilter(): void {
    let viewModel: CommandListViewModel | null = this.listViewModel;
    if (viewModel === null) {
      return;
    }
    if (this.homeTab === 'favorites') {
      viewModel.commands = this.favorites.slice().sort();
    } else if (this.homeTab === 'recent') {
      viewModel.commands = this.recent.slice();
    } else {
      viewModel.commands = this.allCommands.slice();
    }
    viewModel.searchQuery = this.searchQuery;
    viewModel.applySearch();
    this.commands = viewModel.filteredCommands;
    this.isIndexing = viewModel.isIndexing;
  }

  private onWidthBreakpointChanged(): void {
    this.ensureDefaultDetailInSplit();
  }

  private ensureDefaultDetailInSplit(): void {
    if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM ||
      this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_XS ||
      this.selectedCommand.length > 0 || this.commands.length === 0) {
      return;
    }

    this.openCommandDetail(this.commands[0]);
  }

  private getNavigationMode(): NavigationMode {
    if (!this.isSplitMode()) {
      return NavigationMode.Stack;
    }
    return NavigationMode.Split;
  }

  private isSplitMode(): boolean {
    return this.currentWidthBreakpoint !== WidthBreakpoint.WIDTH_SM &&
      this.currentWidthBreakpoint !== WidthBreakpoint.WIDTH_XS;
  }

  @Builder
  private TabItem(label: string, tab: HomeTab, count: number) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontWeight(this.homeTab === tab ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.homeTab === tab ? '#1D4ED8' : '#6B7280')
      if (count > 0) {
        Text(`${count}`)
          .fontSize(12)
          .fontColor(this.homeTab === tab ? '#1D4ED8' : '#9CA3AF')
          .margin({ left: 4 })
      }
    }
    .padding({ top: 10, bottom: 8 })
    .onClick(() => {
      this.homeTab = tab;
      this.searchQuery = '';
      let viewModel: CommandListViewModel | null = this.listViewModel;
      if (viewModel !== null) {
        viewModel.updateSearch('');
      }
      this.applyListFilter();
    })
  }

  @Builder
  private PageMap(name: string) {
    if (name === COMMAND_DETAIL_ROUTE) {
      CommandDetailDestination()
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 14 }) {
        Text(APP_SUBTITLE)
          .fontSize(14)
          .fontColor('#6B7280')
          .width('100%')

        Row({ space: 24 }) {
          this.TabItem('全部', 'all', this.allCommands.length)
          this.TabItem('收藏', 'favorites', this.favorites.length)
          this.TabItem('最近', 'recent', this.recent.length)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        SearchBar({
          query: this.searchQuery,
          onQueryChange: (value: string): void => {
            this.handleSearchChange(value);
          }
        })

        Row({ space: 8 }) {
          Toggle({ type: ToggleType.Checkbox, isOn: this.fullTextSearch })
            .selectedColor('#1D4ED8')
            .onChange((isOn: boolean): void => {
              this.handleFullTextSearchChange(isOn);
            })
          Text(this.isIndexing ? '全文索引构建中…' : '全文搜索（搜索文档内容）')
            .fontSize(13)
            .fontColor(this.isIndexing ? '#B45309' : '#6B7280')
        }
        .width('100%')

        if (this.isLoading) {
          Column({ space: 12 }) {
            LoadingProgress()
              .width(40)
              .height(40)
            Text('正在加载命令索引...')
              .fontSize(15)
              .fontColor('#6B7280')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(16)
            .fontColor('#C2410C')
            .width('100%')
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
        } else {
          Text(`${this.commands.length} 个命令`)
            .fontSize(13)
            .fontColor('#6B7280')
            .width('100%')
          CommandGrid({
            commands: this.commands,
            favorites: this.favorites,
            onCommandClick: (commandName: string): void => {
              this.openCommandDetail(commandName);
            },
            onFavoriteClick: (commandName: string): void => {
              this.handleFavoriteToggle(commandName);
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, top: 12, right: 16, bottom: 12 })
      .backgroundColor('#F3F4F6')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .title(APP_TITLE)
    .mode(this.getNavigationMode())
    .navBarWidth('50%')
    .navDestination(this.PageMap)
  }
}

@Component
struct CommandDetailDestination {
  @StorageLink('favoriteVersion') favoriteVersion: number = 0;
  @State commandName: string = '';
  @State description: string = '';
  @State blocks: MarkdownBlock[] = [];
  @State isFavorite: boolean = false;
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  private detailViewModel: CommandDetailViewModel | null = null;
  private prefsStore: PrefsStore = new PrefsStore();

  private ensureDetailViewModel(): CommandDetailViewModel | null {
    if (this.detailViewModel !== null) {
      return this.detailViewModel;
    }

    let hostContext: Object | undefined = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      this.errorMessage = '无法获取应用上下文';
      return null;
    }

    let context: common.UIAbilityContext = hostContext as common.UIAbilityContext;
    let repository: CommandRepository = new CommandRepository(context);
    this.detailViewModel = new CommandDetailViewModel(repository);
    this.prefsStore.init(context);
    return this.detailViewModel;
  }

  private async loadCommandDetail(): Promise<void> {
    let viewModel: CommandDetailViewModel | null = this.ensureDetailViewModel();
    if (viewModel === null || this.commandName.length === 0) {
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    let command: CommandInfo | null = await viewModel.loadCommand(this.commandName);
    this.isFavorite = await this.prefsStore.isFavorite(this.commandName);
    this.isLoading = viewModel.isLoading;
    this.errorMessage = viewModel.errorMessage;
    if (command !== null) {
      this.description = command.description;
      this.blocks = command.blocks;
    }
  }

  private async handleFavoriteToggle(): Promise<void> {
    if (this.commandName.length === 0) {
      return;
    }
    let isFavorite: boolean = await this.prefsStore.toggleFavorite(this.commandName);
    this.isFavorite = isFavorite;
    showToast(this.getUIContext(), isFavorite ? '已收藏' : '已取消收藏');
    this.favoriteVersion += 1;
  }

  build() {
    NavDestination() {
      if (this.isLoading) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('正在加载命令详情...')
            .fontSize(15)
            .fontColor('#6B7280')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage.length > 0) {
        Column() {
          Text(this.errorMessage)
            .fontSize(16)
            .fontColor('#C2410C')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        CommandDetailView({
          commandName: this.commandName,
          description: this.description,
          blocks: this.blocks,
          isFavorite: this.isFavorite,
          onFavoriteToggle: (command: string): void => {
            this.handleFavoriteToggle();
          }
        })
      }
    }
    .title(this.commandName.length > 0 ? this.commandName : '命令详情')
    .backgroundColor('#FFFFFF')
    .onReady((context: NavDestinationContext) => {
      if (typeof context.pathInfo.param === 'string') {
        this.commandName = context.pathInfo.param as string;
      }
      this.loadCommandDetail();
    })
  }
}
