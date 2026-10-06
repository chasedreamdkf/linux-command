import { common } from '@kit.AbilityKit';
import { pasteboard } from '@kit.BasicServicesKit';

import { showToast } from '../utils/Toast';
import {
  MarkdownBlock,
  MarkdownBlockType,
  MarkdownInlineFragment,
  MarkdownInlineKind,
  MarkdownListItem,
  MarkdownTableCell
} from '../model/CommandModel';

/**
 * 行内富文本渲染：纯文本、行内代码、加粗和可点击链接。
 * 非 http(s) 链接按普通文本展示，避免无效的跨端跳转。
 */
@Component
export struct InlineRichText {
  @Prop fragments: MarkdownInlineFragment[] = [];
  @Prop bold: boolean = false;
  @Prop fontSize: number = 15;
  @Prop fontColor: string = '#374151';

  build() {
    Text() {
      ForEach(this.fragments, (fragment: MarkdownInlineFragment) => {
        if (fragment.kind === MarkdownInlineKind.Code) {
          Span(fragment.text)
            .fontSize(Math.max(11, this.fontSize - 2))
            .fontFamily('monospace')
            .fontColor('#BE185D')
        } else if (fragment.kind === MarkdownInlineKind.Bold) {
          Span(fragment.text)
            .fontWeight(FontWeight.Bold)
        } else if (fragment.kind === MarkdownInlineKind.Link && this.isWebLink(fragment.href)) {
          Span(fragment.text)
            .fontColor('#2563EB')
            .decoration({ type: TextDecorationType.Underline })
            .onClick(() => {
              this.openLinkFragment(fragment.href);
            })
        } else {
          Span(fragment.text)
        }
      }, (fragment: MarkdownInlineFragment): string => fragment.id)
    }
    .fontSize(this.fontSize)
    .fontColor(this.fontColor)
    .fontWeight(this.bold ? FontWeight.Bold : FontWeight.Normal)
    .lineHeight(Math.round(this.fontSize * 1.53))
    .width('100%')
  }

  private isWebLink(href: string): boolean {
    return href.startsWith('http://') || href.startsWith('https://');
  }

  private openLinkFragment(href: string): void {
    if (href.length === 0) {
      return;
    }
    let hostContext: Object | undefined = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      return;
    }
    (hostContext as common.UIAbilityContext).openLink(href).catch(() => {
      // 链接无法打开时静默忽略，文档阅读不受影响
    });
  }
}

/**
 * 原生 Markdown 渲染器，避免依赖 Web 端 v-html。
 * 段落、列表和引用走行内富文本；表格用对齐的等宽分栏行渲染。
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
      if (block.fragments.length > 0) {
        InlineRichText({ fragments: block.fragments, fontSize: 15 })
          .margin({ bottom: 10 })
      } else {
        Text(block.content)
          .fontSize(15)
          .fontColor('#374151')
          .lineHeight(23)
          .width('100%')
          .margin({ bottom: 10 })
      }
    } else if (block.type === MarkdownBlockType.List) {
      Column({ space: 6 }) {
        ForEach(block.items, (item: MarkdownListItem) => {
          Row({ space: 8 }) {
            Text(block.ordered ? `${item.order}.` : '•')
              .fontSize(15)
              .fontColor('#4B5563')
              .width(24)
            if (item.fragments.length > 0) {
              InlineRichText({ fragments: item.fragments, fontSize: 15 })
                .layoutWeight(1)
            } else {
              Text(item.content)
                .fontSize(15)
                .fontColor('#374151')
                .lineHeight(23)
                .layoutWeight(1)
            }
          }
          .alignItems(VerticalAlign.Top)
          .width('100%')
        }, (item: MarkdownListItem): string => item.id)
      }
      .width('100%')
      .margin({ bottom: 12 })
    } else if (block.type === MarkdownBlockType.Code) {
      Column() {
        Row() {
          if (block.language.length > 0) {
            Text(block.language)
              .fontSize(12)
              .fontColor('#6B7280')
          }
          Blank()
          Text('复制')
            .fontSize(12)
            .fontColor('#2563EB')
            .padding({ left: 12, top: 4, right: 12, bottom: 4 })
            .backgroundColor('#E0E7FF')
            .borderRadius(10)
            .onClick(() => {
              this.copyCode(block.content);
            })
        }
        .width('100%')
        .padding({ left: 12, top: 8, right: 12, bottom: 6 })

        Scroll() {
          Text(block.content)
            .fontSize(13)
            .fontColor('#111827')
            .fontFamily('Courier New')
            .padding(12)
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
      Column() {
        if (block.fragments.length > 0) {
          InlineRichText({ fragments: block.fragments, fontSize: 15, fontColor: '#4B5563' })
        } else {
          Text(block.content)
            .fontSize(15)
            .fontColor('#4B5563')
            .lineHeight(23)
            .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 12, top: 8, right: 12, bottom: 8 })
      .border({ width: { left: 3 }, color: '#60A5FA' })
      .backgroundColor('#EFF6FF')
      .margin({ bottom: 12 })
    } else if (block.type === MarkdownBlockType.Table) {
      this.TableBlock(block)
    }
  }

  @Builder
  private TableBlock(block: MarkdownBlock) {
    Column() {
      ForEach(block.tableRows, (row: MarkdownTableCell[], rowIndex: number) => {
        Row() {
          ForEach(row, (cell: MarkdownTableCell, cellIndex: number) => {
            Column() {
              InlineRichText({
                fragments: cell.fragments,
                bold: rowIndex === 0,
                fontSize: 13,
                fontColor: rowIndex === 0 ? '#1F2937' : '#374151'
              })
            }
            .width(this.getColumnWidth(block.columnCount, cellIndex))
            .padding({ left: 8, top: 8, right: 8, bottom: 8 })
          }, (cell: MarkdownTableCell): string => cell.id)
        }
        .width('100%')
        .backgroundColor(rowIndex === 0 ? '#F9FAFB' : '#FFFFFF')
        .border({ width: { bottom: 0.5 }, color: '#E5E7EB' })
      }, (row: MarkdownTableCell[], rowIndex: number): string => `${block.id}-row-${rowIndex}`)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E5E7EB' })
    .borderRadius(10)
    .clip(true)
    .margin({ top: 6, bottom: 12 })
  }

  /**
   * 一键复制代码块内容到系统剪贴板。
   */
  private copyCode(content: string): void {
    if (content.length === 0) {
      return;
    }
    let data: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content);
    let uiContext: UIContext = this.getUIContext();
    pasteboard.getSystemPasteboard().setData(data).then((): void => {
      showToast(uiContext, '已复制代码');
    }).catch((error: Error): void => {
      showToast(uiContext, '复制失败');
    });
  }

  /**
   * 表格等宽分栏：语料中表格为 2-4 列，首列通常是短选项/运算符。
   */
  private getColumnWidth(columnCount: number, index: number): string {
    if (columnCount <= 1) {
      return '100%';
    }
    if (columnCount === 2) {
      return index === 0 ? '32%' : '68%';
    }
    if (columnCount === 3) {
      return index === 0 ? '22%' : '39%';
    }
    if (columnCount === 4) {
      if (index === 0 || index === 3) {
        return '26%';
      }
      return '24%';
    }
    return `${Math.floor(100 / columnCount)}%`;
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
