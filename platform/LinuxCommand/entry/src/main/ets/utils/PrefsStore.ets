import { preferences } from '@kit.ArkData';

/**
 * 轻量偏好存储：持久化收藏命令和最近浏览记录（新记录在前，最多 20 条）。
 */
export class PrefsStore {
  private static readonly PREFERENCES_NAME: string = 'linux_command_prefs';
  private static readonly KEY_FAVORITES: string = 'favorites';
  private static readonly KEY_RECENT: string = 'recent_commands';
  private static readonly RECENT_LIMIT: number = 20;

  private store: preferences.Preferences | null = null;
  private readyPromise: Promise<void> | null = null;

  /**
   * 初始化 Preferences 实例（幂等）。读取/写入内部会等待 readyPromise，
   * 因此调用方无需 await init 即可安全读写。
   */
  init(context: Context): Promise<void> {
    if (this.readyPromise === null) {
      this.readyPromise = preferences.getPreferences(context, PrefsStore.PREFERENCES_NAME)
        .then((prefs: preferences.Preferences): void => {
          this.store = prefs;
        })
        .catch((error: Error): void => {
          this.store = null;
        });
    }
    return this.readyPromise;
  }

  private async ensureReady(): Promise<void> {
    if (this.readyPromise !== null) {
      await this.readyPromise;
    }
  }

  async getFavorites(): Promise<string[]> {
    return this.readStringArray(PrefsStore.KEY_FAVORITES);
  }

  async isFavorite(commandName: string): Promise<boolean> {
    let favorites: string[] = await this.getFavorites();
    return favorites.indexOf(commandName) >= 0;
  }

  async toggleFavorite(commandName: string): Promise<boolean> {
    let favorites: string[] = await this.getFavorites();
    let index: number = favorites.indexOf(commandName);
    let isFavorite: boolean;
    if (index >= 0) {
      favorites.splice(index, 1);
      isFavorite = false;
    } else {
      favorites.push(commandName);
      isFavorite = true;
    }
    await this.writeStringArray(PrefsStore.KEY_FAVORITES, favorites);
    return isFavorite;
  }

  async getRecent(): Promise<string[]> {
    return this.readStringArray(PrefsStore.KEY_RECENT);
  }

  async addRecent(commandName: string): Promise<void> {
    if (commandName.trim().length === 0) {
      return;
    }
    let recent: string[] = await this.getRecent();
    let index: number = recent.indexOf(commandName);
    if (index >= 0) {
      recent.splice(index, 1);
    }
    recent.unshift(commandName);
    if (recent.length > PrefsStore.RECENT_LIMIT) {
      recent.length = PrefsStore.RECENT_LIMIT;
    }
    await this.writeStringArray(PrefsStore.KEY_RECENT, recent);
  }

  private async readStringArray(key: string): Promise<string[]> {
    await this.ensureReady();
    if (this.store === null) {
      return [];
    }
    try {
      let raw: string = await this.store.get(key, '[]') as string;
      let parsed: object = JSON.parse(raw) as object;
      if (!Array.isArray(parsed)) {
        return [];
      }
      let items: string[] = parsed as string[];
      let result: string[] = [];
      for (let i = 0; i < items.length; i++) {
        result.push(items[i]);
      }
      return result;
    } catch (error) {
      return [];
    }
  }

  private async writeStringArray(key: string, values: string[]): Promise<void> {
    await this.ensureReady();
    if (this.store === null) {
      return;
    }
    try {
      await this.store.put(key, JSON.stringify(values));
      await this.store.flush();
    } catch (error) {
      // 持久化失败不影响本次会话内的内存状态
    }
  }
}
