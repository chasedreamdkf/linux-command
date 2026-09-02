import { common } from '@kit.AbilityKit';

import { APP_SUBTITLE, APP_TITLE, COMMAND_DETAIL_ROUTE } from '../common/Constants';
import { CommandInfo, MarkdownBlock } from '../model/CommandModel';
import { CommandRepository } from '../model/CommandRepository';
import { CommandDetailViewModel } from '../viewmodel/CommandDetailViewModel';
import { CommandListViewModel } from '../viewmodel/CommandListViewModel';
import { CommandDetailView } from '../views/CommandDetailView';
import { CommandGrid } from '../views/CommandGrid';
import { SearchBar } from '../views/SearchBar';

@Entry
@Component
struct Index {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  @State searchQuery: string = '';
  @State commands: string[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  private listViewModel: CommandListViewModel | null = null;

  aboutToAppear(): void {
    this.loadCommands();
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

    let repository: CommandRepository = new CommandRepository(hostContext as common.UIAbilityContext);
    this.listViewModel = new CommandListViewModel(repository);
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
    this.isLoading = viewModel.isLoading;
    this.errorMessage = viewModel.errorMessage;
    this.commands = viewModel.filteredCommands;
  }

  private handleSearchChange(value: string): void {
    this.searchQuery = value;
    let viewModel: CommandListViewModel | null = this.ensureListViewModel();
    if (viewModel === null) {
      return;
    }
    viewModel.updateSearch(value);
    this.errorMessage = viewModel.errorMessage;
    this.commands = viewModel.filteredCommands;
  }

  private openCommandDetail(commandName: string): void {
    this.navPathStack.pushPathByName(COMMAND_DETAIL_ROUTE, commandName);
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

        SearchBar({
          query: this.searchQuery,
          onQueryChange: (value: string): void => {
            this.handleSearchChange(value);
          }
        })

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
            onCommandClick: (commandName: string): void => {
              this.openCommandDetail(commandName);
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
    .mode(NavigationMode.Auto)
    .navDestination(this.PageMap)
  }
}

@Component
struct CommandDetailDestination {
  @State commandName: string = '';
  @State description: string = '';
  @State blocks: MarkdownBlock[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  private detailViewModel: CommandDetailViewModel | null = null;

  private ensureDetailViewModel(): CommandDetailViewModel | null {
    if (this.detailViewModel !== null) {
      return this.detailViewModel;
    }

    let hostContext: Object | undefined = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      this.errorMessage = '无法获取应用上下文';
      return null;
    }

    let repository: CommandRepository = new CommandRepository(hostContext as common.UIAbilityContext);
    this.detailViewModel = new CommandDetailViewModel(repository);
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
    this.isLoading = viewModel.isLoading;
    this.errorMessage = viewModel.errorMessage;
    if (command !== null) {
      this.description = command.description;
      this.blocks = command.blocks;
    }
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
          blocks: this.blocks
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
