/**
 * 命令网格列表组件，使用命令名作为稳定 key。
 */
@Component
export struct CommandGrid {
  @Prop commands: string[] = [];
  onCommandClick: (command: string) => void = (command: string): void => {};

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
          ForEach(this.commands, (command: string) => {
            ListItem() {
              Row() {
                Text(command)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#182431')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Blank()
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
