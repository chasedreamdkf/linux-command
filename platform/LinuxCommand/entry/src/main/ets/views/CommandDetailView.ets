import { MarkdownBlock } from '../model/CommandModel';
import { MarkdownRenderer } from './MarkdownRenderer';

/**
 * 命令详情内容组件，展示摘要和 Markdown 正文。
 */
@Component
export struct CommandDetailView {
  @Prop commandName: string = '';
  @Prop description: string = '';
  @Prop blocks: MarkdownBlock[] = [];

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text(this.commandName)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')

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
