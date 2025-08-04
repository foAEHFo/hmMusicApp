import { media } from "@kit.MediaKit"
import { Song } from "../interface/Song";
import { tempSongList } from "../model/TempData";
import emitter from '@ohos.events.emitter'
import { PlayState } from '../interface/Song'
import { EmitEventType } from "../event/type";
import {Preferences} from "./Preferences"
import {getSong} from "../http/api"
import { SingerInformation, SingerLabel } from "../interface/Personal";

function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array]; // 创建副本（避免修改原数组）
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1)); // 生成 [0, i] 的随机索引
    let temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp
  }
  return shuffled;
}

export class MusicPlayer{
  public player!: media.AVPlayer
  public context!:Context

  public currentTime: number = 0; // 当前播放时间（秒）
  public isPlaying: boolean = false; // 播放状态
  public isEmpty: boolean = true;//刚初始化为空状态

  public playMode:'loop'|'random'|'repeat' = 'loop'
  public songList:Song[] = tempSongList
  public playList:Song[] = tempSongList
  public currentPlayIndex:number = -1

  private originalIndexMap: Map<number, number> = new Map(); // 存储歌曲在原列表的索引
  private currentSongId:number = 0

  public async init(context:Context,songList:Song[],playIndex:number,playMode:'loop'|'random'|'repeat'){
    this.context = context
    this.songList = [...songList]
    this.playList = [...songList]
    this.currentPlayIndex = playIndex
    this.playMode = playMode

    songList.forEach((song, index) => {
      this.originalIndexMap.set(song.id, index);
    });

    this.player = await media.createAVPlayer()
    this.player.on('stateChange', async (state)=>{

      switch(state){
        case 'initialized':
          await this.player.prepare()
          break;

        case 'prepared':
          await this.player.play()
          // //更新播放状态
          this.isPlaying = true
          break

        case 'completed':
          if(this.playMode=='repeat'){
            await this.replay()
          }
          else{
            await this.next()
          }
          break
      }
    })

    this.player.on('timeUpdate',(time)=>{
      this.currentTime = time

      this.updateUIState()
    })

  }

  public async getSongDetails(song:Song): Promise<Song>{
    try {
      const response = await getSong({songId:song.id,artistId:song.singerList.map((singerLabel:SingerLabel):number=>singerLabel.id),userId:globalThis.userInfo.id})
      console.log(song.id.toString())
      console.log(song.singerList.map((singerLabel:SingerLabel):number=>singerLabel.id)[0].toString())
      console.log(globalThis.userInfo.id)
      if (response.success) {
        // console.log('完整响应:', JSON.stringify(response.data));

        let songDetail:object = response.data['song_detail']['songDetail']['songs'][0]
        let singerUserIds:number[] = response.data['song_detail']['artistAccountId']
        let url:string = response.data['song_url']
        let lyricObject:object = response.data['lyric']
        // console.log(url)
        // console.log((songDetail['duration']/1000).toString())
        // console.log(lyricObject['lrc']['lyric'])
        // console.log(lyricObject['tlyric']['lyric'])

        let newSingerList:SingerLabel[] = []
        for(let i=0;i<song.singerList.length;i++){
          let item:SingerLabel = song.singerList[i]
          newSingerList.push({
            id: item.id,
            userId: singerUserIds[i],
            name: item.name,
            avatar: item.avatar,
            isFollowed: item.isFollowed
          } as SingerLabel)
        }

        let newSong:Song = {
          id:song.id,
          url:url,
          name:song.name,
          coverPicture:songDetail['album']['picUrl'],
          duration:songDetail['duration']/1000,
          singerList:newSingerList,
          lyric:lyricObject['lrc']['lyric'],
          translateLyric:lyricObject['tlyric']['lyric'],
          album:song.album,
          isLoved:song.isLoved,
          isVip:song.isVip
        } as Song

        console.log(newSong.coverPicture)

        return newSong

      } else {
        console.log('完整响应:', JSON.stringify(response.data));
        return song
      }
    } catch (error) {
      console.error('请求异常:', error);
      return song
    }
  }

  public updateUIState() {
    const playState:PlayState = {
      currentTime: this.currentTime/1000,
      isPlaying: this.isPlaying,
      playMode: this.playMode,
      playList: this.playList,
      currentPlayIndex: this.currentPlayIndex
    }

    emitter.emit({
      eventId: EmitEventType.UPDATE_STATE
    }, {
      data: {
        playStateStr: JSON.stringify(playState)
      }
    })
    //记录状态到preferences中
    const preferences: Preferences = new Preferences(this.context)
    preferences.setState(playState)

  }

  private getCurrentSong():Song{
    return this.playList[this.currentPlayIndex]
  }

  public async changePlayList(songList:Song[],index:number){
    this.songList = [...songList]
    this.playList = [...songList]
    this.currentPlayIndex = index
    this.currentTime = 0
    await this.replay()
  }

  public async playSong(song: Song) {
    const existingIndex = this.playList.findIndex(item => item.id === song.id);
    const targetIndex = this.currentPlayIndex + 1;

    if (existingIndex !== -1 && existingIndex !== targetIndex) {
      const movedSong = this.playList.splice(existingIndex, 1)[0];
      const adjustedIndex = existingIndex < targetIndex ? targetIndex - 1 : targetIndex;
      this.playList.splice(adjustedIndex, 0, movedSong);
      this.currentPlayIndex = adjustedIndex;
    }

    else if (existingIndex === -1) {
      this.playList.splice(targetIndex, 0, song);
      this.currentPlayIndex = targetIndex;
    }

    else {
      this.currentPlayIndex = targetIndex;
    }

    await this.player.reset();
    this.currentTime = 0;
    this.currentSongId = song.id;

    this.playList[this.currentPlayIndex] = await this.getSongDetails(song)

    this.player.url = this.getCurrentSong().url;
    this.updateUIState();
  }

  public async replay(){
    await this.player.reset()
    this.currentTime = 0
    this.currentSongId = this.getCurrentSong().id;

    this.playList[this.currentPlayIndex] = await this.getSongDetails(this.getCurrentSong())

    this.player.url = this.getCurrentSong().url
    this.isEmpty = false

    this.updateUIState()
  }

  public async pause(){
    console.log(this.player.state)
    await this.player.pause()
    this.isPlaying = false
    this.updateUIState()
  }

  public async play(){
    console.log(this.player.state)
    await this.player.play()
    this.isPlaying = true
    this.updateUIState()
  }

  public togglePlay() {
    if (this.isPlaying) {
      this.pause()
    } else {
      if(this.isEmpty){
        this.replay()
      }
      else{
        this.play()
      }
    }
  }


  public async seek(second:number){
    await this.player.seek(second*1000)
    this.currentTime = second
  }

  public async next(){
    if(this.playMode!="repeat"){
      this.currentPlayIndex =  (this.currentPlayIndex + 1) % this.playList.length
    }
    await this.replay()
  }

  public async prev(){
    if(this.playMode!="repeat"){
      this.currentPlayIndex--
      if(this.currentPlayIndex<0){
        this.currentPlayIndex = this.playList.length-1
      }
    }
    await this.replay()
  }

  public async jumpToIndex(index:number){
    this.currentPlayIndex = index
    await this.replay()
  }

  public changePlayMode(){
    console.log(this.playMode)
    switch (this.playMode){
      case 'loop':{
        this.playMode = 'random'
        break
      }
      case 'random':{
        this.playMode = 'repeat'
        break
      }
      case 'repeat':{
        this.playMode = 'loop'
        break
      }
    }
    this.applyPlayMode()
    this.updateUIState()
  }

  public applyPlayMode(){
    if(this.isEmpty||this.playList.length==0||this.currentPlayIndex==-1){
      return
    }
    switch (this.playMode){
      case 'loop':{
        let id = this.playList[this.currentPlayIndex].id
        this.playList = [...this.songList]
        this.currentPlayIndex = this.playList.findIndex(item => item.id === id);
        break
      }
      case 'random':{
        let shuffled = [...this.songList].filter(song => song.id !== this.currentSongId);
        shuffled = shuffleArray(shuffled);
        // 当前歌曲插入首位
        this.playList = [this.songList.find(song => song.id === this.currentSongId)!, ...shuffled];
        this.currentPlayIndex = 0;

        break
      }
      case 'repeat':{
        let id = this.playList[this.currentPlayIndex].id
        this.playList = [...this.songList]
        this.currentPlayIndex = this.playList.findIndex(item => item.id === id);
        break
      }
    }
  }

  public async removeSongFromPlayList(songId: number) {
    const playListIndex = this.playList.findIndex(song => song.id === songId);
    if (playListIndex === -1) return;

    if(playListIndex==this.currentPlayIndex){
      this.player.reset()

      const songIndexInSongList = this.songList.findIndex(song => song.id === songId);
      if (songIndexInSongList !== -1) {
        this.songList.splice(songIndexInSongList, 1);
      }
      this.originalIndexMap.clear();
      this.songList.forEach((song, index) => {
        this.originalIndexMap.set(song.id, index);
      });

      this.playList.splice(playListIndex, 1);
      if (this.playList.length == 0) {
        this.currentPlayIndex = -1;
        this.isEmpty = true;
        this.isPlaying = false;
      } else {
        if (this.currentPlayIndex >= this.playList.length) {
          this.currentPlayIndex = 0;
        }
        await this.replay()
      }
    }
    else{
      this.playList.splice(playListIndex, 1);

      const songIndexInSongList = this.songList.findIndex(song => song.id === songId);
      if (songIndexInSongList !== -1) {
        this.songList.splice(songIndexInSongList, 1);
      }
      this.originalIndexMap.clear();
      this.songList.forEach((song, index) => {
        this.originalIndexMap.set(song.id, index);
      });

      if(playListIndex<this.currentPlayIndex){
        this.currentPlayIndex--
      }
    }

    this.updateUIState();
  }

  public async addToList(song: Song) {
    this.songList.push(song);
    this.originalIndexMap.set(song.id, this.songList.length - 1);

    if (this.playList.length > 0) {
      this.playList.splice(this.currentPlayIndex + 1, 0, song);
    } else {
      this.playList = [song];
      this.currentPlayIndex = 0;
      this.isEmpty = false;
      await this.replay()
    }

    this.updateUIState();
  }
}