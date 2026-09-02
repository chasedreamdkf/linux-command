export enum MarkdownBlockType {
  Heading,
  Paragraph,
  List,
  Code,
  Quote
}

export class MarkdownListItem {
  id: string;
  content: string;
  order: number;

  constructor(id: string, content: string, order: number) {
    this.id = id;
    this.content = content;
    this.order = order;
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

  constructor(id: string, type: MarkdownBlockType, content: string) {
    this.id = id;
    this.type = type;
    this.content = content;
    this.level = 0;
    this.language = '';
    this.ordered = false;
    this.items = [];
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
