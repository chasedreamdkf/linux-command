import { MarkdownBlock } from '../model/CommandModel';
import { MarkdownRenderer } from './MarkdownRenderer';

/**
 * 命令详情内容组件，展示摘要、收藏按钮和 Markdown 正文。
 */
@Component
export struct CommandDetailView {
  @Prop commandName: string = '';
  @Prop description: string = '';
  @Prop blocks: MarkdownBlock[] = [];
  @Prop isFavorite: boolean = false;
  onFavoriteToggle: (command: string) => void = (command: string): void => {};

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Text(this.commandName)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.isFavorite ? '★ 已收藏' : '☆ 收藏')
            .fontSize(15)
            .fontColor(this.isFavorite ? '#B45309' : '#6B7280')
            .padding({ left: 12, top: 8, right: 12, bottom: 8 })
            .backgroundColor(this.isFavorite ? '#FEF3C7' : '#F3F4F6')
            .borderRadius(14)
            .onClick(() => {
              if (this.commandName.length > 0) {
                this.onFavoriteToggle(this.commandName);
              }
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        if (this.description.length > 0) {
          Text(this.description)
            .fontSize(16)
            .fontColor('#4B5563')
            .lineHeight(24)
            .width('100%')
            .padding({ left: 12, top: 10, right: 12, bottom: 10 })
            .backgroundColor('#F9FAFB')
            .borderRadius(10)
        }

        MarkdownRenderer({ blocks: this.blocks })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
  }
}
