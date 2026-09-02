import { CommandInfo, MarkdownBlock, MarkdownBlockType, MarkdownListItem } from '../model/CommandModel';

/**
 * 将命令 Markdown 拆成 ArkUI 可渲染的基础块。
 * 仅保留文档阅读所需的标题、段落、列表、引用和代码块结构。
 */
export class MarkdownParser {
  private blockSeed: number = 0;

  parse(markdown: string): CommandInfo {
    this.blockSeed = 0;
    let normalized: string = markdown.replace(/\r\n/g, '\n');
    let name: string = this.extractName(normalized);
    let description: string = this.extractDescription(normalized);
    let blocks: MarkdownBlock[] = this.parseBlocks(normalized);
    return new CommandInfo(name, description, normalized, blocks);
  }

  private extractName(markdown: string): string {
    let lines: string[] = markdown.split('\n');
    for (let i = 0; i < lines.length; i++) {
      let line: string = lines[i].trim();
      if (line.startsWith('# ')) {
        return line.substring(2).trim();
      }
    }
    return '';
  }

  private extractDescription(markdown: string): string {
    let lines: string[] = markdown.split('\n');
    let hasTitle: boolean = false;
    for (let i = 0; i < lines.length; i++) {
      let line: string = lines[i].trim();
      if (!hasTitle && line.startsWith('# ')) {
        hasTitle = true;
        continue;
      }
      if (hasTitle && line.length > 0 && !line.startsWith('#')) {
        return this.cleanInlineMarkdown(line);
      }
    }
    return '';
  }

  private parseBlocks(markdown: string): MarkdownBlock[] {
    let blocks: MarkdownBlock[] = [];
    let lines: string[] = markdown.split('\n');
    let paragraphLines: string[] = [];
    let listLines: string[] = [];
    let isOrderedList: boolean = false;
    let isCodeBlock: boolean = false;
    let codeLanguage: string = '';
    let codeLines: string[] = [];

    let flushParagraph = (): void => {
      if (paragraphLines.length === 0) {
        return;
      }
      let block: MarkdownBlock = this.createBlock(MarkdownBlockType.Paragraph, paragraphLines.join(' '));
      blocks.push(block);
      paragraphLines = [];
    };

    let flushList = (): void => {
      if (listLines.length === 0) {
        return;
      }
      let block: MarkdownBlock = this.createBlock(MarkdownBlockType.List, '');
      block.ordered = isOrderedList;
      for (let i = 0; i < listLines.length; i++) {
        block.items.push(new MarkdownListItem(`${block.id}-item-${i}`, listLines[i], i + 1));
      }
      blocks.push(block);
      listLines = [];
      isOrderedList = false;
    };

    let flushCode = (): void => {
      let block: MarkdownBlock = this.createBlock(MarkdownBlockType.Code, codeLines.join('\n'));
      block.language = codeLanguage;
      blocks.push(block);
      codeLines = [];
      codeLanguage = '';
    };

    for (let i = 0; i < lines.length; i++) {
      let originalLine: string = lines[i];
      let trimmed: string = originalLine.trim();

      if (trimmed.startsWith('```')) {
        flushParagraph();
        flushList();
        if (isCodeBlock) {
          flushCode();
          isCodeBlock = false;
        } else {
          isCodeBlock = true;
          codeLanguage = trimmed.substring(3).trim();
        }
        continue;
      }

      if (isCodeBlock) {
        codeLines.push(originalLine);
        continue;
      }

      if (trimmed.length === 0) {
        flushParagraph();
        flushList();
        continue;
      }

      if (trimmed.startsWith('#')) {
        flushParagraph();
        flushList();
        let block: MarkdownBlock = this.createBlock(MarkdownBlockType.Heading, this.removeHeadingPrefix(trimmed));
        block.level = this.getHeadingLevel(trimmed);
        blocks.push(block);
        continue;
      }

      if (this.isUnorderedListLine(trimmed) || this.isOrderedListLine(trimmed)) {
        flushParagraph();
        let lineOrdered: boolean = this.isOrderedListLine(trimmed);
        if (listLines.length > 0 && lineOrdered !== isOrderedList) {
          flushList();
        }
        isOrderedList = lineOrdered;
        listLines.push(this.removeListPrefix(trimmed));
        continue;
      }

      if (trimmed.startsWith('>')) {
        flushParagraph();
        flushList();
        blocks.push(this.createBlock(MarkdownBlockType.Quote, trimmed.substring(1).trim()));
        continue;
      }

      paragraphLines.push(trimmed);
    }

    if (isCodeBlock) {
      flushCode();
    }
    flushParagraph();
    flushList();
    return blocks;
  }

  private createBlock(type: MarkdownBlockType, content: string): MarkdownBlock {
    this.blockSeed += 1;
    let blockContent: string = type === MarkdownBlockType.Code ? content : this.cleanInlineMarkdown(content);
    return new MarkdownBlock(`block-${this.blockSeed}`, type, blockContent);
  }

  private getHeadingLevel(line: string): number {
    let level: number = 0;
    while (level < line.length && line.charAt(level) === '#') {
      level += 1;
    }
    return Math.min(level, 6);
  }

  private removeHeadingPrefix(line: string): string {
    let level: number = this.getHeadingLevel(line);
    return line.substring(level).trim();
  }

  private isUnorderedListLine(line: string): boolean {
    return line.startsWith('- ') || line.startsWith('* ') || line.startsWith('+ ');
  }

  private isOrderedListLine(line: string): boolean {
    let dotIndex: number = line.indexOf('.');
    if (dotIndex <= 0 || dotIndex + 1 >= line.length || line.charAt(dotIndex + 1) !== ' ') {
      return false;
    }
    for (let i = 0; i < dotIndex; i++) {
      let char: string = line.charAt(i);
      if (char < '0' || char > '9') {
        return false;
      }
    }
    return true;
  }

  private removeListPrefix(line: string): string {
    if (this.isUnorderedListLine(line)) {
      return this.cleanInlineMarkdown(line.substring(2).trim());
    }
    let dotIndex: number = line.indexOf('.');
    return this.cleanInlineMarkdown(line.substring(dotIndex + 2).trim());
  }

  private cleanInlineMarkdown(content: string): string {
    return content
      .replace(/`/g, '')
      .replace(/\*\*/g, '')
      .replace(/__/g, '')
      .trim();
  }
}
