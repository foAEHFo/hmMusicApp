import { Song } from '../interface/Song';

export class SongDataSource implements IDataSource {
  // 核心数据存储
  public _songs: Song[] = [];
  // 监听器列表（LazyForEach 自动注册）
  private _listeners: DataChangeListener[] = [];

  notifyDataReload(): void {
    this._listeners.forEach(listener => {
      listener.onDataReloaded(); // 触发LazyForEach重载所有组件 [1,3](@ref)
    });
  }

  updateAllSongs(songs: Song[]): void {
    this._songs = [...songs];
    this.notifyDataReload(); // 使用全量刷新而非增量更新 [1](@ref)
  }

  // 返回歌曲总数
  totalCount(): number {
    return this._songs.length;
  }

  // 按索引获取歌曲数据
  getData(index: number): Song {
    if (index < 0 || index >= this._songs.length) {
      throw new Error(`Index ${index} out of bounds`);
    }
    return this._songs[index];
  }

  // 注册数据监听器（LazyForEach 自动调用）
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this._listeners.indexOf(listener) === -1) {
      this._listeners.push(listener);
    }
  }

  // 移除数据监听器（LazyForEach 自动调用）
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this._listeners.indexOf(listener);
    if (index >= 0) {
      this._listeners.splice(index, 1);
    }
  }

  // === 以下是数据操作接口（按需调用）===

  // 添加单首歌曲（尾部追加）
  addSong(song: Song): void {
    this._songs.push(song);
    this._notifyDataAdd(this._songs.length - 1); // 通知新增
  }

  // 批量添加歌曲
  addSongs(songs: Song[]): void {
    const startIndex = this._songs.length;
    this._songs.push(...songs);
    this._notifyDataAdd(startIndex); // 批量新增只需通知起始位置
  }

  // 删除指定索引的歌曲
  deleteSong(index: number): void {
    if (index >= 0 && index < this._songs.length) {
      this._songs.splice(index, 1);
      this._notifyDataDelete(index); // 通知删除
    }
  }

  // 更新歌曲数据
  updateSong(index: number, newSong: Song): void {
    if (index >= 0 && index < this._songs.length) {
      this._songs[index] = newSong;
      this._notifyDataChange(index); // 通知变更
    }
  }

  // === 私有通知方法（触发 LazyForEach 更新）===
  private _notifyDataAdd(index: number): void {
    this._listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  private _notifyDataDelete(index: number): void {
    this._listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  private _notifyDataChange(index: number): void {
    this._listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }
}