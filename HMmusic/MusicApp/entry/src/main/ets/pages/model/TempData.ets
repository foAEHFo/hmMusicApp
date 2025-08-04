import {Song,Album,PlayList, LyricItem} from '../interface/Song'
import {UserInformation,SingerInformation, SingerLabel} from '../interface/Personal'

export const tempLyric:string = "[00:00.00]天外来物 - 薛之谦\n" +
  "[00:02.00]词：薛之谦\n" +
  "[00:02.00]曲：罗小黑\n" +
  "[00:18.00]你降落的 太突然了\n" +
  "[00:25.00]我刚好呢 又路过了\n" +
  "[00:32.00]机会难得 又主观觉得\n" +
  "[00:39.00]想明抢 又碰不得\n" +
  "[00:46.00]你带来了 我的快乐\n" +
  "[00:53.00]让这世界 有点颜色\n" +
  "[01:00.00]我好想指责 你太随意了\n" +
  "[01:07.00]宝物该有人捧着 你是不是我的\n" +
  "[01:17.00]你像 天外来物一样 求之不得\n" +
  "[01:24.00]你在世俗里的名字 不重要了\n" +
  "[01:31.00]正好 我隐藏的人格是契而不舍\n" +
  "[01:38.00]直到蜂拥而至的人都透明了\n" +
  "[01:46.00]我在 不近又不远处\n" +
  "[01:50.00]用明天换你 靠近我\n" +
  "[02:07.00]你占领了 我的快乐\n" +
  "[02:14.00]和这世界 已没有瓜葛\n" +
  "[02:21.00]任事物干渴 都褪去颜色\n" +
  "[02:28.00]只有你是天蓝色 我开始找你了\n" +
  "[02:40.00]会像 天外来物一样 失而复得\n" +
  "[02:47.00]你在世俗里的名字 被人用了\n" +
  "[02:54.00]反正 我隐藏的人格是契而不舍\n" +
  "[03:02.00]直到蜂拥而至的人都透明了\n" +
  "[03:08.00]我在 不近又不远处\n" +
  "[03:13.00]用明天换你 靠近我\n" +
  "[03:19.00]你就像 天外来物一样 求之不得\n" +
  "[03:26.00]我在世俗里的描写被取笑了\n" +
  "[03:33.00]反正我隐藏的人格是非你不可\n" +
  "[03:40.00]直到别有用心的人都透明了\n" +
  "[03:47.00]我在 不近又不远处\n" +
  "[03:52.00]用明天换你 靠近我\n" +
  "[03:57.00]制作人：周以力/郑伟\n" +
  "[03:58.00]编曲：周以力\n" +
  "[03:58.00]吉他：张淞\n" +
  "[03:59.00]大提琴：郎莹\n" +
  "[03:59.00]鼓：褚伟明\n" +
  "[04:00.00]bass：努而德柯\n" +
  "[04:01.00]人声录制：郑伟/夏之炜/吴身宝\n" +
  "[04:01.00]人声编辑：郑伟\n" +
  "[04:01.00]人声录音棚：上海广播大厦200studio\n" +
  "[04:02.00]乐器录音棚：soundhub studio\n" +
  "[04:02.00]混音：全相彦 @OK master studio\n" +
  "[04:02.00]母带：全相彦 @OK master studio\n"

export const tempLyric2:string = "[00:00.00]演员 - 薛之谦\n" +
  "[00:02.00]词：薛之谦\n" +
  "[00:04.00]曲：薛之谦\n" +
  "[00:07.00]编曲：郑伟/张宝宇\n" +
  "[00:09.00]制作人：赵英俊\n" +
  "[00:11.00]合声：赵英俊\n" +
  "[00:14.00]录音师：王晓海\n" +
  "[00:16.00]混音师：鲍锐\n" +
  "[00:18.00]母带处理工程师：鲍锐\n" +
  "[00:21.00]简单点\n" +
  "[00:25.00]说话的方式简单点\n" +
  "[00:30.00]递进的情绪请省略\n" +
  "[00:33.00]你又不是个演员\n" +
  "[00:36.00]别设计那些情节\n" +
  "[00:42.00]没意见\n" +
  "[00:46.00]我只想看看你怎么圆\n" +
  "[00:51.00]你难过的太表面\n" +
  "[00:54.00]像没天赋的演员\n" +
  "[00:57.00]观众一眼能看见\n" +
  "[01:02.00]该配合你演出的我演视而不见\n" +
  "[01:07.00]在逼一个最爱你的人即兴表演\n" +
  "[01:12.00]什么时候我们开始收起了底线\n" +
  "[01:18.00]顺应时代的改变看那些拙劣的表演\n" +
  "[01:23.00]可你曾经那么爱我干嘛演出细节\n" +
  "[01:28.00]我该变成什么样子才能延缓厌倦\n" +
  "[01:33.00]原来当爱放下防备后的这些那些\n" +
  "[01:39.00]才是考验\n" +
  "[01:44.00]没意见\n" +
  "[01:49.00]你想怎样我都随便\n" +
  "[01:55.00]你演技也有限\n" +
  "[01:57.00]又不用说感言\n" +
  "[02:00.00]分开就平淡些\n" +
  "[02:05.00]该配合你演出的我演视而不见\n" +
  "[02:10.00]别逼一个最爱你的人即兴表演\n" +
  "[02:15.00]什么时候我们开始没有了底线\n" +
  "[02:20.00]顺着别人的谎言被动就不显得可怜\n" +
  "[02:26.00]可你曾经那么爱我干嘛演出细节\n" +
  "[02:31.00]我该变成什么样子才能配合出演\n" +
  "[02:36.00]原来当爱放下防备后的这些那些\n" +
  "[02:41.00]都有个期限\n" +
  "[02:47.00]其实台下的观众就我一个\n" +
  "[02:53.00]其实我也看出你有点不舍\n" +
  "[02:58.00]场景也习惯我们来回拉扯\n" +
  "[03:02.00]还计较着什么\n" +
  "[03:08.00]其实说分不开的也不见得\n" +
  "[03:14.00]其实感情最怕的就是拖着\n" +
  "[03:19.00]越演到重场戏越哭不出了\n" +
  "[03:24.00]是否还值得\n" +
  "[03:29.00]该配合你演出的我尽力在表演\n" +
  "[03:34.00]像情感节目里的嘉宾任人挑选\n" +
  "[03:39.00]如果还能看出我有爱你的那面\n" +
  "[03:44.00]请剪掉那些情节让我看上去体面\n" +
  "[03:50.00]可你曾经那么爱我干嘛演出细节\n" +
  "[03:55.00]不在意的样子是我最后的表演\n" +
  "[04:01.00]是因为爱你我才选择表演\n" +
  "[04:06.00]这种成全\n"

export const tempTranslateLyric:string = ""

export const emptySong:Song = {
  id:0,
  url:"",
  name: "",
  coverPicture:"",
  duration:0,
  lyric: "",
  translateLyric:"",
  singerList:[{id:0,userId:0,name:"",avatar:"",isFollowed:false}],
  album:{
    id:0,
    name:""
  },
  isLoved:false,
  isVip:false
}

export const tempSong:Song = {
  id:0,
  url:"https://lx-sycdn.kuwo.cn/f7eba0f2ed99ab0eeed88e4a797414e0/6880b9e1/resource/n3/50/25/2509257790.mp3",
  name: `天外来物`,
  coverPicture:"",
  duration:257,
  lyric: tempLyric,
  translateLyric:tempTranslateLyric,
  singerList:[{id:0,userId:0,name:"薛之谦",avatar:"",isFollowed:false}],
  album:{
    id:0,
    name:""
  },
  isLoved:false,
  isVip:false
}

export const tempSong2:Song = {
  id:1,
  url:"https://lk-sycdn.kuwo.cn/8b60fdbff9815e2cc8effd414d1e2c2b/6880b127/resource/n1/51/33/2639139238.mp3",
  name: `演员`,
  coverPicture:"",
  duration:281,
  lyric: tempLyric2,
  translateLyric:tempTranslateLyric,
  singerList:[{id:0,userId:0,name:"薛之谦",avatar:"",isFollowed:false}],
  album:{
    id:0,
    name:""
  },
  isLoved:false,
  isVip:false
}

export const tempSong3:Song = {
  id:2,
  url:"https://lx-sycdn.kuwo.cn/e3bafbe24993bd4b3f55337fe01d1934/6880b0de/resource/n2/35/94/2650049110.mp3",
  name: `意外`,
  coverPicture:"",
  duration:291,
  lyric: tempLyric,
  translateLyric:tempTranslateLyric,
  singerList:[{id:0,userId:0,name:"薛之谦",avatar:"",isFollowed:false}],
  album:{
    id:0,
    name:""
  },
  isLoved:false,
  isVip:false
}

export const tempSongList: Song[] = Array.from<number, Song>({ length: 16 }, (_, index) => {
  return {
    id:index+1,
    url:"https://lx-sycdn.kuwo.cn/750dc17e20f3e7500c11d0671c677378/6880423d/resource/n3/50/25/2509257790.mp3",
    name: `歌曲${index+1}`,
    coverPicture:"",
    duration:257,
    lyric: tempLyric,
    translateLyric:tempTranslateLyric,
    singerList: [{ id: index, userId:0,name: `歌手${String.fromCharCode(65 + index)}`,avatar:"",isFollowed:false}],
    album: {
      id:0,
      name:""
    },
    isLoved: false,
    isVip:false
  };
});

export const tempPlayList:PlayList = {
  id:0,
  name: "K-ON!",
  author: {
    'id': 0,
    'name':`"樱丘女子高等学校轻音部"`,
    'avatar':""
  },
  coverPicture:"",
  playCount: 90402,
  shareCount: 0,
  commentCount: 0,
  saveCount: 0,
  intro: "滑滑蛋~",
  songList:tempSongList,
  songCount:0,
  isSave:false
}

export const tempPlayListList: PlayList[] = Array.from<number, PlayList>({ length: 4 }, (_, index) => ({
  id: index,
  name: `歌单${index}`,
  author: {
    'id': 0,
    'name':`作者${String.fromCharCode(65 + index)}`,
    'avatar':""
  }, // 65 对应 ASCII 码的 'A'
  coverPicture:"",
  playCount: 0,
  shareCount: 0,
  commentCount: 0,
  saveCount: 0,
  intro: "介绍",
  songList: tempSongList, // 引用之前生成的歌曲列表
  songCount:0,
  isSave: false
}));

export const tempAlbum:Album = {
  id:0,
  name:"专辑",
  singerList: [{ id: 0,userId:0, name: `歌手0` ,avatar:"",isFollowed:false}],
  coverPicture:"",
  releaseDate:"2000.1.1",
  shareCount: 12,
  commentCount: 154,
  saveCount: 15,
  songList: tempSongList,
  songCount:0,
  isSave:false
}

export const tempAlbumList: Album[] = Array.from<number, Album>({ length: 4 }, (_, index) => ({
  id: index,
  name: `专辑${index}`,
  coverPicture:"",
  singerList: [{ id: index, userId:0,name: `歌手${String.fromCharCode(65 + index)}` ,avatar:"",isFollowed:false}],
  releaseDate: "2000.1.1",
  shareCount: 0,
  commentCount: 0,
  saveCount: 0,
  songList: tempSongList,
  songCount:0,
  isSave: false
}));


export const tempUserInformation:UserInformation = {
  id:0,
  avatar:"/",  //头像地址
  coverPicture:"/",  ////背景图地址
  name:"巨魔", //昵称
  sex: 0,  // 性别
  followCount:0, //关注数
  fans:0, //粉丝数
  hours:0, //听歌时长
  isFollowed:false
}

export const tempUserList: UserInformation[] = Array.from<number, UserInformation>({ length: 4 }, (_, index) => ({
  id: index,
  avatar: "/",
  coverPicture: "/",
  name: `用户${String.fromCharCode(65 + index)}`, // 生成用户A、用户B、用户C、用户D
  sex: 1,
  followCount: 0,
  fans: 0,
  hours: 0,
  isFollowed:false
}));

export const tempSingerInformation:SingerInformation = {
  id:0,
  userId:0,
  avatar: "/",
  coverPicture: "/",
  name: "放課後テイータイム",
  sex: 0,
  followCount: 0,
  fans: 2986000,
  alias: 'K-ON!',
  tags: ["网易音乐人","歌手","作词","作曲","编曲"],
  isFollowed: false,
  songList:tempSongList,
  songCount:0,
  albumList:tempAlbumList,
  albumCount:0
}

export const tempSingerList: SingerInformation[] = Array.from<number, SingerInformation>({ length: 4 }, (_, index) => ({
  id: index,
  userId: index,
  avatar: "/",
  coverPicture: "/",
  name: `歌手${String.fromCharCode(65 + index)}`,
  sex: 1,
  followCount: 0,
  fans: 0,
  alias: '',
  tags: [],
  isFollowed: false,
  songList: tempSongList,
  albumList: tempAlbumList,
  songCount:0,
  albumCount:0
}));

export const tempSingerLabelList: SingerLabel[] = Array.from<number, SingerLabel>({ length: 4 }, (_, index) => ({
  id: index,
  userId:0,
  avatar: "/",
  name: `歌手${String.fromCharCode(65 + index)}`,
  isFollowed: false,
}));

