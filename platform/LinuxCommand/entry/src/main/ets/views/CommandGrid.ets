/**
 * 命令懒加载数据源，统一管理 LazyForEach 的监听器与刷新通知。
 */
class CommandListDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private dataArray: string[] = [];

  totalCount(): number {
    return this.dataArray.length;
  }

  getData(index: number): string {
    return this.dataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    let index: number = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  updateData(commands: string[]): void {
    this.dataArray = commands.slice();
    this.notifyDataReload();
  }

  private notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener): void => {
      listener.onDataReloaded();
    });
  }
}

/**
 * 命令网格列表组件，使用 LazyForEach 按需创建列表项。
 */
@Component
export struct CommandGrid {
  @Prop @Watch('onCommandsUpdated') commands: string[] = [];
  @Prop favorites: string[] = [];
  onCommandClick: (command: string) => void = (command: string): void => {};
  onFavoriteClick: (command: string) => void = (command: string): void => {};
  private dataSource: CommandListDataSource = new CommandListDataSource();

  aboutToAppear(): void {
    this.dataSource.updateData(this.commands);
  }

  private onCommandsUpdated(): void {
    this.dataSource.updateData(this.commands);
  }

  build() {
    Column() {
      if (this.commands.length === 0) {
        Text('没有找到匹配的命令')
          .fontSize(16)
          .fontColor('#6B7280')
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 48 })
      } else {
        List({ space: 8 }) {
          LazyForEach(this.dataSource, (command: string) => {
            ListItem() {
              Row() {
                Text(command)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#182431')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Blank()
                Text(this.favorites.indexOf(command) >= 0 ? '★' : '☆')
                  .fontSize(16)
                  .fontColor(this.favorites.indexOf(command) >= 0 ? '#F59E0B' : '#C4C9D4')
                  .margin({ right: 6 })
                  .onClick(() => {
                    this.onFavoriteClick(command);
                  })
                Text('›')
                  .fontSize(20)
                  .fontColor('#9CA3AF')
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 14 })
              .borderRadius(12)
              .backgroundColor('#FFFFFF')
              .onClick(() => {
                this.onCommandClick(command);
              })
            }
          }, (command: string): string => command)
        }
        .width('100%')
        .layoutWeight(1)
        .lanes(2)
        .cachedCount(24)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
