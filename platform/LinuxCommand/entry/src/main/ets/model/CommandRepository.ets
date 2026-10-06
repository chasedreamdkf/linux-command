import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';

import { COMMAND_FILE_DIR, COMMAND_INDEX_PATH } from '../common/Constants';
import { MarkdownParser } from '../utils/MarkdownParser';
import { CommandIndexData, CommandInfo } from './CommandModel';

/**
 * 命令数据仓库，统一负责 rawfile 资源读取、Markdown 解析和内存缓存。
 */
export class CommandRepository {
  private context: common.UIAbilityContext;
  private parser: MarkdownParser = new MarkdownParser();
  private commandList: string[] = [];
  private commandCache: Map<string, CommandInfo> = new Map<string, CommandInfo>();
  private allTexts: Map<string, string> = new Map<string, string>();
  private textDecoder: util.TextDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async loadCommandList(): Promise<string[]> {
    if (this.commandList.length > 0) {
      return this.commandList.slice();
    }

    let indexText: string | null = await this.readRawText(COMMAND_INDEX_PATH);
    if (indexText === null) {
      this.commandList = [];
      return [];
    }

    try {
      let indexData: CommandIndexData = JSON.parse(indexText) as CommandIndexData;
      this.commandList = indexData.commands.slice().sort();
    } catch (error) {
      this.commandList = [];
    }
    return this.commandList.slice();
  }

  /**
   * 加载全部命令文档的原始 Markdown（用于全文搜索索引），结果缓存。
   */
  async loadAllCommandTexts(): Promise<Map<string, string>> {
    if (this.allTexts.size > 0) {
      return this.allTexts;
    }
    let names: string[] = await this.loadCommandList();
    let texts: Map<string, string> = new Map<string, string>();
    for (let i = 0; i < names.length; i++) {
      let name: string = names[i];
      let content: string | null = await this.readRawText(`${COMMAND_FILE_DIR}/${name}.md`);
      if (content !== null) {
        texts.set(name, content);
      }
    }
    this.allTexts = texts;
    return this.allTexts;
  }

  async loadCommand(commandName: string): Promise<CommandInfo | null> {
    if (commandName.trim().length === 0) {
      return null;
    }
    if (this.commandCache.has(commandName)) {
      return this.commandCache.get(commandName)!;
    }

    try {
      let markdown: string | null = await this.readRawText(`${COMMAND_FILE_DIR}/${commandName}.md`);
      if (markdown === null) {
        return null;
      }
      let command: CommandInfo = this.parser.parse(markdown);
      if (command.name.length === 0) {
        command.name = commandName;
      }
      this.commandCache.set(commandName, command);
      return command;
    } catch (error) {
      return null;
    }
  }

  private async readRawText(rawFilePath: string): Promise<string | null> {
    try {
      let rawContent: Uint8Array = await this.context.resourceManager.getRawFileContent(rawFilePath);
      return this.textDecoder.decodeToString(rawContent);
    } catch (error) {
      return null;
    }
  }
}
