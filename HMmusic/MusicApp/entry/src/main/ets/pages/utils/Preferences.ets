import preferences from '@ohos.data.preferences'
import { PlayState } from '../interface/Song'
/**
 * 首选项工具类，用于记录应用程序的状态
 * */
export class Preferences{
  StoreName = "MN_CLOUD_MUSIC"
  PlayStateKey = 'MN_PLAY_STATE'
  context: Context
  constructor(context: Context) {
    this.context = context
  }
  //获取仓库
  async  getStorage(){
    return  preferences.getPreferences(this.context, this.StoreName)
  }
  /**
   * 每次发布事件的时候将状态记录到pre.中
   */
  //存放数据
  async  setState(data: PlayState){
    const storage = await this.getStorage()
    await storage.put(this.PlayStateKey, JSON.stringify(data))
    await storage.flush()
  }
  //获取数据
  async  getState():Promise<PlayState>{
    const storage = await this.getStorage()
    return await JSON.parse(await storage.get(this.PlayStateKey,'') as string) as PlayState
  }

}