import {
  CommandInfo,
  MarkdownBlock,
  MarkdownBlockType,
  MarkdownInlineFragment,
  MarkdownInlineKind,
  MarkdownListItem,
  MarkdownTableCell
} from '../model/CommandModel';

/**
 * 将命令 Markdown 拆成 ArkUI 可渲染的块结构。
 * 支持标题、段落、列表、引用、代码块和表格；
 * 段落、列表项、引用和表格单元格支持行内代码、加粗和链接片段。
 */
export class MarkdownParser {
  private blockSeed: number = 0;
  private inlineSeed: number = 0;

  parse(markdown: string): CommandInfo {
    this.blockSeed = 0;
    this.inlineSeed = 0;
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
        return this.plainText(line);
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
        let item: MarkdownListItem = new MarkdownListItem(`${block.id}-item-${i}`, listLines[i], i + 1);
        item.fragments = this.parseInline(listLines[i]);
        block.items.push(item);
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

    let i: number = 0;
    while (i < lines.length) {
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
        i += 1;
        continue;
      }

      if (isCodeBlock) {
        codeLines.push(originalLine);
        i += 1;
        continue;
      }

      if (trimmed.length === 0) {
        flushParagraph();
        flushList();
        i += 1;
        continue;
      }

      if (this.isTableStart(lines, i)) {
        flushParagraph();
        flushList();
        let end: number = i + 2;
        while (end < lines.length) {
          let row: string = lines[end].trim();
          if (row.length === 0 || !this.isTableRowLine(row)) {
            break;
          }
          end += 1;
        }
        blocks.push(this.parseTable(lines, i, end));
        i = end;
        continue;
      }

      if (trimmed.startsWith('#')) {
        flushParagraph();
        flushList();
        let block: MarkdownBlock = this.createBlock(MarkdownBlockType.Heading, this.removeHeadingPrefix(trimmed));
        block.level = this.getHeadingLevel(trimmed);
        blocks.push(block);
        i += 1;
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
        i += 1;
        continue;
      }

      if (trimmed.startsWith('>')) {
        flushParagraph();
        flushList();
        blocks.push(this.createBlock(MarkdownBlockType.Quote, trimmed.substring(1).trim()));
        i += 1;
        continue;
      }

      paragraphLines.push(trimmed);
      i += 1;
    }

    if (isCodeBlock) {
      flushCode();
    }
    flushParagraph();
    flushList();
    return blocks;
  }

  /**
   * 从 lineIndex 开始是一个表格：当前行与下一行都是表格行，
   * 且下一行是 `|---|---|` 形式的分隔行。
   */
  private isTableStart(lines: string[], lineIndex: number): boolean {
    let current: string = lines[lineIndex].trim();
    if (!this.isTableRowLine(current)) {
      return false;
    }
    if (lineIndex + 1 >= lines.length) {
      return false;
    }
    let next: string = lines[lineIndex + 1].trim();
    return this.isTableSeparatorLine(next);
  }

  private isTableRowLine(line: string): boolean {
    if (!line.startsWith('|') || line.length < 3) {
      return false;
    }
    if (this.isTableSeparatorLine(line)) {
      return false;
    }
    for (let i = 1; i < line.length; i++) {
      let char: string = line.charAt(i);
      if (char === '|' && line.charAt(i - 1) !== '\\') {
        return true;
      }
    }
    return false;
  }

  private isTableSeparatorLine(line: string): boolean {
    if (!line.startsWith('|')) {
      return false;
    }
    let hasDash: boolean = false;
    for (let i = 0; i < line.length; i++) {
      let char: string = line.charAt(i);
      if (char === '\\') {
        i += 1;
        continue;
      }
      if (char === '|') {
        continue;
      }
      if (char === '-' || char === ':' || char === ' ') {
        if (char === '-') {
          hasDash = true;
        }
        continue;
      }
      return false;
    }
    return hasDash;
  }

  private parseTable(lines: string[], start: number, end: number): MarkdownBlock {
    let block: MarkdownBlock = this.createBlock(MarkdownBlockType.Table, '');
    block.hasHeader = true;
    block.columnCount = this.splitTableRow(lines[start].trim()).length;

    let rowIndex: number = 0;
    let i: number = start;
    while (i < end) {
      let row: string = lines[i].trim();
      if (this.isTableSeparatorLine(row)) {
        i += 1;
        continue;
      }
      let rawCells: string[] = this.splitTableRow(row);
      let cells: MarkdownTableCell[] = [];
      for (let c = 0; c < rawCells.length; c++) {
        let cellId: string = `${block.id}-cell-${rowIndex}-${c}`;
        cells.push(new MarkdownTableCell(cellId, this.parseInline(rawCells[c].trim())));
      }
      block.tableRows.push(cells);
      block.columnCount = Math.max(block.columnCount, cells.length);
      rowIndex += 1;
      i += 1;
    }
    return block;
  }

  /**
   * 按未转义的 `|` 拆分表格行，行首尾的 `|` 不产生空单元格。
   */
  private splitTableRow(line: string): string[] {
    let cells: string[] = [];
    let buffer: string = '';
    let started: boolean = false;
    for (let i = 0; i < line.length; i++) {
      let char: string = line.charAt(i);
      if (char === '\\' && i + 1 < line.length) {
        buffer += char;
        buffer += line.charAt(i + 1);
        started = true;
        i += 1;
        continue;
      }
      if (char === '|') {
        let cell: string = started ? buffer.trim() : '';
        if (started || buffer.length > 0) {
          cells.push(cell);
        }
        started = true;
        buffer = '';
        continue;
      }
      buffer += char;
      started = started || buffer.length > 0;
    }
    if (started && buffer.trim().length > 0) {
      cells.push(buffer.trim());
    }
    return cells;
  }

  private createBlock(type: MarkdownBlockType, content: string): MarkdownBlock {
    this.blockSeed += 1;
    let block: MarkdownBlock = new MarkdownBlock(`block-${this.blockSeed}`, type, content);
    if (type === MarkdownBlockType.Paragraph || type === MarkdownBlockType.Quote) {
      block.fragments = this.parseInline(content);
    }
    return block;
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
      return line.substring(2).trim();
    }
    let dotIndex: number = line.indexOf('.');
    return line.substring(dotIndex + 2).trim();
  }

  /**
   * 行内解析：先按 `` ` `` 切分行内代码（代码内不解析其它行内语法），
   * 其余文本再解析 `**加粗**` 和 `[文本](链接)`。
   */
  private parseInline(content: string): MarkdownInlineFragment[] {
    let fragments: MarkdownInlineFragment[] = [];
    let i: number = 0;
    while (i < content.length) {
      let char: string = content.charAt(i);
      if (char === '`') {
        let close: number = content.indexOf('`', i + 1);
        if (close > i) {
          fragments.push(this.createFragment(MarkdownInlineKind.Code, content.substring(i + 1, close)));
          i = close + 1;
          continue;
        }
      }
      if (char === '[' && this.isLinkAt(content, i)) {
        let closeBracket: number = content.indexOf(']', i + 1);
        let closeParen: number = content.indexOf(')', closeBracket + 2);
        let label: string = content.substring(i + 1, closeBracket);
        let href: string = content.substring(closeBracket + 2, closeParen);
        fragments.push(this.createFragment(MarkdownInlineKind.Link, label, href));
        i = closeParen + 1;
        continue;
      }
      if (char === '*' && i + 1 < content.length && content.charAt(i + 1) === '*') {
        let close: number = content.indexOf('**', i + 2);
        if (close > i + 1) {
          fragments.push(this.createFragment(MarkdownInlineKind.Bold, content.substring(i + 2, close)));
          i = close + 2;
          continue;
        }
      }
      if (char === '_' && i + 1 < content.length && content.charAt(i + 1) === '_') {
        let close: number = content.indexOf('__', i + 2);
        if (close > i + 1) {
          fragments.push(this.createFragment(MarkdownInlineKind.Bold, content.substring(i + 2, close)));
          i = close + 2;
          continue;
        }
      }
      let nextSpecial: number = content.length;
      let nextCode: number = content.indexOf('`', i);
      if (nextCode >= 0) {
        nextSpecial = Math.min(nextSpecial, nextCode);
      }
      let nextBracket: number = content.indexOf('[', i);
      if (nextBracket >= 0 && this.isLinkAt(content, nextBracket)) {
        nextSpecial = Math.min(nextSpecial, nextBracket);
      }
      if (nextSpecial > i) {
        fragments.push(this.createFragment(MarkdownInlineKind.Text, content.substring(i, nextSpecial)));
        i = nextSpecial;
      } else {
        i += 1;
      }
    }
    let merged: MarkdownInlineFragment[] = [];
    for (let f = 0; f < fragments.length; f++) {
      let fragment: MarkdownInlineFragment = fragments[f];
      if (fragment.text.length === 0) {
        continue;
      }
      let last: MarkdownInlineFragment | null = merged.length > 0 ? merged[merged.length - 1] : null;
      if (last !== null && last.kind === MarkdownInlineKind.Text && fragment.kind === MarkdownInlineKind.Text) {
        last.text += fragment.text;
      } else {
        merged.push(fragment);
      }
    }
    return merged;
  }

  /**
   * 位置 pos 处的 `[` 是否属于 `[label](href)` 的开头。
   */
  private isLinkAt(content: string, pos: number): boolean {
    if (content.charAt(pos) !== '[') {
      return false;
    }
    let closeBracket: number = content.indexOf(']', pos + 1);
    if (closeBracket <= pos || closeBracket + 1 >= content.length || content.charAt(closeBracket + 1) !== '(') {
      return false;
    }
    let closeParen: number = content.indexOf(')', closeBracket + 2);
    if (closeParen <= closeBracket + 1) {
      return false;
    }
    let label: string = content.substring(pos + 1, closeBracket);
    if (label.length === 0) {
      return false;
    }
    for (let i = 0; i < label.length; i++) {
      let char: string = label.charAt(i);
      if (char === '\\') {
        i += 1;
        continue;
      }
      if (char === '[' || char === ']') {
        return false;
      }
    }
    let href: string = content.substring(closeBracket + 2, closeParen);
    return href.length > 0;
  }

  private createFragment(kind: MarkdownInlineKind, text: string, href: string = ''): MarkdownInlineFragment {
    this.inlineSeed += 1;
    return new MarkdownInlineFragment(`inline-${this.inlineSeed}`, kind, text, href);
  }

  private plainText(content: string): string {
    let result: string = '';
    let fragments: MarkdownInlineFragment[] = this.parseInline(content);
    for (let i = 0; i < fragments.length; i++) {
      let fragment: MarkdownInlineFragment = fragments[i];
      result += fragment.text;
    }
    return result.trim();
  }
}
