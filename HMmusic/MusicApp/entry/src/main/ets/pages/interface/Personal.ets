import {Song,Album} from "./Song"

export interface UserInformation{
  id:number
  avatar:string;  //头像地址
  coverPicture:string;  ////背景图地址
  name:string; //昵称
  sex:number;  // 性别 0女1男
  followCount:number; //关注数
  fans:number; //粉丝数
  hours:number; //听歌时长
  isFollowed:boolean

  //未完待续....
}

export interface SingerInformation{
  id:number
  userId:number
  avatar:string;  //头像地址
  coverPicture:string;  ////背景图地址
  name:string; //昵称
  sex:number;  // 性别
  followCount:number; //关注数
  fans:number; //粉丝数
  alias:string;//别名
  tags:string[];
  isFollowed:boolean;
  songList:Song[]
  songCount:number
  albumList:Album[]
  albumCount:number

  //未完待续....
}

export interface SingerLabel{
  id:number
  userId:number
  name:string
  avatar:string
  isFollowed:boolean
}

export interface UserLabel{
  id:number
  name:string
  avatar:string
}