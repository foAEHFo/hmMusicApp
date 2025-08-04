import { tempSongList } from "../model/TempData"
import {SingerLabel, UserLabel} from "./Personal"

export interface Song{
  id:number
  url:string
  name:string
  coverPicture:string,
  duration:number
  singerList:SingerLabel[]
  lyric:string
  translateLyric:string
  album:AlbumLabel
  isLoved:boolean
  isVip:boolean
}

export interface PlayList{
  id:number,
  name: string,
  author: UserLabel,
  coverPicture:string,
  playCount: number,
  shareCount: number,
  commentCount: number,
  saveCount: number,
  intro: string,
  songList: Song[],
  songCount: number,
  isSave:boolean
}

export interface Album{
  id:number,
  name: string,
  coverPicture:string,
  singerList: SingerLabel[],
  releaseDate:string,
  shareCount: number,
  commentCount: number,
  saveCount: number,
  songList: Song[],
  songCount: number,
  isSave:boolean
}

export interface AlbumLabel{
  id:number,
  name: string,
}

export interface PlayState{
  currentTime: number// 当前播放时间（秒）
  isPlaying: boolean// 播放状态
  playMode:'loop'|'random'|'repeat'
  playList:Song[]
  currentPlayIndex:number
}

export class PlayStateModel implements PlayState{
  currentTime: number = 0// 当前播放时间（秒）
  duration: number = 0// 总时长（秒）
  isPlaying: boolean = false// 播放状态
  playMode:'loop'|'random'|'repeat' = 'loop'
  playList:Song[] = tempSongList
  currentPlayIndex:number = 0

  constructor(playState:PlayState) {
    this.currentTime = playState.currentTime
    this.isPlaying = playState.isPlaying
    this.playMode = playState.playMode
    this.playList = playState.playList
    this.currentPlayIndex = playState.currentPlayIndex
  }
}
export interface LyricItem{
  time:number,
  text:string,
  translateText:string
}