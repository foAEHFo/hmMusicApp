import {Song,PlayList} from "./Song"
import {UserInformation,SingerInformation, SingerLabel, UserLabel} from "./Personal"

export interface SearchAllResults{
  isDone:boolean,
  topSinger:SingerInformation
  songResults:SearchSongResults
  playListResults:SearchPlayListResults
  singerResults:SearchSingerResults
  userResults:SearchUserResults
}

export interface SearchSongResults{
  isDone:boolean,
  songList:Song[]
}

export interface SearchPlayListResults{
  isDone:boolean,
  playListList:PlayList[]
}

export interface SearchSingerResults{
  isDone:boolean,
  singerLabelList:SingerLabel[]
}

export interface SearchUserResults{
  isDone:boolean,
  userLabelList:UserLabel[]
}