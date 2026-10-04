export enum MarkdownBlockType {
  Heading,
  Paragraph,
  List,
  Code,
  Quote,
  Table
}

export enum MarkdownInlineKind {
  Text,
  Code,
  Bold,
  Link
}

/**
 * 行内片段：富文本渲染的最小单元（纯文本、行内代码、加粗、链接）。
 */
export class MarkdownInlineFragment {
  id: string;
  kind: MarkdownInlineKind;
  text: string;
  href: string;

  constructor(id: string, kind: MarkdownInlineKind, text: string, href: string) {
    this.id = id;
    this.kind = kind;
    this.text = text;
    this.href = href;
  }
}

export class MarkdownListItem {
  id: string;
  content: string;
  order: number;
  fragments: MarkdownInlineFragment[];

  constructor(id: string, content: string, order: number) {
    this.id = id;
    this.content = content;
    this.order = order;
    this.fragments = [];
  }
}

/**
 * 表格单元格，保存解析好的行内片段。
 */
export class MarkdownTableCell {
  id: string;
  fragments: MarkdownInlineFragment[];

  constructor(id: string, fragments: MarkdownInlineFragment[]) {
    this.id = id;
    this.fragments = fragments;
  }
}

export class MarkdownBlock {
  id: string;
  type: MarkdownBlockType;
  content: string;
  level: number;
  language: string;
  ordered: boolean;
  items: MarkdownListItem[];
  fragments: MarkdownInlineFragment[];
  tableRows: MarkdownTableCell[][];
  columnCount: number;
  hasHeader: boolean;

  constructor(id: string, type: MarkdownBlockType, content: string) {
    this.id = id;
    this.type = type;
    this.content = content;
    this.level = 0;
    this.language = '';
    this.ordered = false;
    this.items = [];
    this.fragments = [];
    this.tableRows = [];
    this.columnCount = 0;
    this.hasHeader = false;
  }
}

export class CommandInfo {
  name: string;
  description: string;
  markdown: string;
  blocks: MarkdownBlock[];

  constructor(name: string, description: string, markdown: string, blocks: MarkdownBlock[]) {
    this.name = name;
    this.description = description;
    this.markdown = markdown;
    this.blocks = blocks;
  }
}

export interface CommandIndexData {
  commands: string[];
}
