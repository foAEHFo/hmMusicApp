import {HttpGet , HttpPost} from "./httpUtil"

export interface userParams{
  id?:number,
  username?:string,
  phoneNumber?:string,
  password?:string,
  sex?:number,
  headPicture?:string,
  coverPicture?:string,
  type?:number,
  myId?:number,
  seconds?:number
}

export interface playListParams{
  id?:number,
  playListId?:number,
  name?:string,
  description?:string,
  playTime?: number
}

export interface songParams{
  playListId?:number,
  songId?:number,
  artistId?:number[],
  userId?:number
}

export interface albumParams{
  albumId?:number,
}

export interface searchParams{
  s?:string,
  userId?: number,
  type?: number
  offset?: number,
}

export interface artistParams{
  artistId?:number,
  accountId?:number,
  userId?:number,
  limit?:number,
  offset?:number
}

export interface followParams{
  userId?:number,
  followId?:number,
  artistAccountId?:number,
}

// 1.用户相关api

//登录
// 当不成功时，response.message会输出密码错误或用户不存在，请先注册
export const  login = (params:userParams) => HttpPost(`/getUser`,params);

export const getRecommend = (params:userParams) => HttpPost(`/loginInit`,params)

//注册
//当不成功时，response.message会输出用户已经注册过了
export const  register = (params:userParams) => HttpPost(`/addUser`,params);

//修改用户基础信息，不包过添加头像和背景图
export const  updateUser = (params:userParams) => HttpPost(`/updateUserInfo`,params);

//用户注销账户
export const  deleteUser = (params:userParams) => HttpPost(`/deleteUser`,params);

//获取用户界面的信息，包括基础信息和歌单信息
export const  getUserInfo = (params:userParams) => HttpPost(`/getUserInfo`,params);

//积累听歌时长
export const  addUserHours = (params:userParams) => HttpPost(`/addPlayTime`,params);


// 2.歌单相关api

// 获取该用户的所有创建，收藏，订阅歌单
export const  getUserPlayList = (params:playListParams) => HttpPost(`/getUserPlayLists`,params);

//添加歌单至收藏
export const  addPlayListToCollect = (params:playListParams) => HttpPost(`/addPlayListToCollect`,params);

//取消收藏歌单
export const  deletePlayListFromCollect = (params:playListParams) => HttpPost(`/deletePlayListFromCollect`,params);

//添加网络歌单至订阅
export const  addPlayListToSubscribe = (params:playListParams) => HttpPost(`/addPlayListSubscribe`,params);

//取消订阅歌单
export const  deletePlayListFromSubscribe = (params:playListParams) => HttpPost(`/deleteFromSubscribe`,params);

//添加歌曲至歌单
export const  addSongToPlayList = (params:songParams) => HttpPost(`/addSongToPlayList`,params);

//从歌单删除歌曲
export const  deleteSongFromPlayList = (params:songParams) => HttpPost(`/deleteSongFromPlayList`,params);

// 创建歌单
export const  createPlayList = (params:playListParams) => HttpPost(`/addPlayList`,params);

// 修改歌单基础信息
export const  updatePlayListInfo = (params:playListParams) => HttpPost(`/updatePlayListInfo`,params);

// 删除创建歌单
export const  deletePlayList = (params:playListParams) => HttpPost(`/deletePlayList`,params);

// 获取创建歌单或收藏歌单中的所有歌曲
export const  getMyPlayListAllSongs = (params:playListParams) => HttpPost(`/getMyPlayListAllSongs`,params);

// 获取网络歌单的所有歌曲
export const  getNetPlayListAllSongs = (params:playListParams) => HttpPost(`/getPlayListAllSongs`,params);

// 累计歌单的播放次数
export const  addPlayCount = (params:playListParams) => HttpPost(`/addPlayCount`,params);


// 3. 专辑api

// 获取专辑内歌曲列表
export const  getAlbumSongs = (params:albumParams) => HttpPost(`/getSongsFromAlbum`,params);


// 4. 搜索api

// 搜索加载，用于初次搜索加载出所有模块的结果
export const  searchAll = (params:searchParams) => HttpPost(`/searchAll`,params);

// 后续用于特定懒加载用的搜索
export const  search = (params:searchParams) => HttpPost(`/search`,params);


// 5. 单曲api

// 获取一个单曲的详细信息和播放地址
export const  getSong = (params:songParams) => HttpPost(`/getSong`,params);


// 6. 歌手api

// 获取歌手的基本信息，top50歌曲和专辑列表
export const  getArtist = (params:artistParams) => HttpPost(`/getArtist`,params);

// 获取歌手专辑列表,提供了偏移值，以用于懒加载
export const  getArtistAlbums = (params:artistParams) => HttpPost(`/getArtistAlbums`,params);


// 7.关注api

// 关注用户(不是歌手)
export const  followUser = (params:followParams) => HttpPost(`/addUserFollow`,params);

// 取消关注用户(不是歌手)
export const  unfollowUser = (params:followParams) => HttpPost(`/deleteUserFollow`,params);

// 关注歌手
export const  followSinger = (params:followParams) => HttpPost(`/addArtistFollow`,params);

// 取消关注歌手
export const  unfollowSinger = (params:followParams) => HttpPost(`/deleteArtistFollow`,params);

// 获取用户关注列表
export const  getUserFollows = (params:followParams) => HttpPost(`/getUserFollows`,params);






