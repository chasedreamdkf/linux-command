import { MarkdownBlock, MarkdownBlockType, MarkdownListItem } from '../model/CommandModel';

/**
 * 原生 Markdown 基础渲染器，避免依赖 Web 端 v-html。
 */
@Component
export struct MarkdownRenderer {
  @Prop blocks: MarkdownBlock[] = [];

  @Builder
  private RenderBlock(block: MarkdownBlock) {
    if (block.type === MarkdownBlockType.Heading) {
      Text(block.content)
        .fontSize(this.getHeadingFontSize(block.level))
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .width('100%')
        .margin({ top: this.getHeadingTopMargin(block.level), bottom: 8 })
    } else if (block.type === MarkdownBlockType.Paragraph) {
      Text(block.content)
        .fontSize(15)
        .fontColor('#374151')
        .lineHeight(23)
        .width('100%')
        .margin({ bottom: 10 })
    } else if (block.type === MarkdownBlockType.List) {
      Column({ space: 6 }) {
        ForEach(block.items, (item: MarkdownListItem) => {
          Row({ space: 8 }) {
            Text(block.ordered ? `${item.order}.` : '•')
              .fontSize(15)
              .fontColor('#4B5563')
              .width(24)
            Text(item.content)
              .fontSize(15)
              .fontColor('#374151')
              .lineHeight(23)
              .layoutWeight(1)
          }
          .alignItems(VerticalAlign.Top)
          .width('100%')
        }, (item: MarkdownListItem): string => item.id)
      }
      .width('100%')
      .margin({ bottom: 12 })
    } else if (block.type === MarkdownBlockType.Code) {
      Column() {
        if (block.language.length > 0) {
          Text(block.language)
            .fontSize(12)
            .fontColor('#6B7280')
            .margin({ left: 12, top: 8, bottom: 4 })
        }
        Scroll() {
          Text(block.content)
            .fontSize(13)
            .fontColor('#111827')
            .fontFamily('Courier New')
            .padding(12)
            .copyOption(CopyOptions.LocalDevice)
        }
        .width('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Auto)
      }
      .width('100%')
      .backgroundColor('#F3F4F6')
      .borderRadius(10)
      .margin({ top: 6, bottom: 12 })
    } else if (block.type === MarkdownBlockType.Quote) {
      Text(block.content)
        .fontSize(15)
        .fontColor('#4B5563')
        .lineHeight(23)
        .width('100%')
        .padding({ left: 12, top: 8, right: 12, bottom: 8 })
        .border({ width: { left: 3 }, color: '#60A5FA' })
        .backgroundColor('#EFF6FF')
        .margin({ bottom: 12 })
    }
  }

  private getHeadingFontSize(level: number): number {
    if (level <= 1) {
      return 24;
    }
    if (level === 2) {
      return 20;
    }
    if (level === 3) {
      return 18;
    }
    return 16;
  }

  private getHeadingTopMargin(level: number): number {
    if (level <= 1) {
      return 8;
    }
    return 18;
  }

  build() {
    Column() {
      ForEach(this.blocks, (block: MarkdownBlock) => {
        this.RenderBlock(block)
      }, (block: MarkdownBlock): string => block.id)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
