import { getRecommend, login} from "./http/api"
import { router } from "@kit.ArkUI";
import preferencesUtil from "./utils/tokenUtil";
import { AlbumLabel, PlayList, Song } from "./interface/Song";
import { SingerLabel } from "./interface/Personal";

@Entry
@Component
struct InitialPage{

  async aboutToAppear(){
    await this.tryLogin()
    await getRecommendList()
    router.replace({url:"pages/MainNavigation"})
  }

  async tryLogin(){
    try {
      const response = await login({})
      if (response.success) {
        console.log('完整响应:', JSON.stringify(response.data));

        let userInfo:object = response.data

        globalThis.userInfo = {
          id:userInfo["id"],
          headPicture:userInfo["headPicture"],
          coverPicture:userInfo["coverPicture"],
          name:userInfo["username"],
          sex:userInfo['sex'],
          followCount:userInfo['followCount'],
          fans:userInfo['fans'],
          hours:userInfo['hours'],
          isFollowed:false
        }

        globalThis.token = (await preferencesUtil.get("userinfoStore", "token", "")) as string

      } else {
        console.log('完整响应:', JSON.stringify(response.data));
        router.replace({url:"pages/Login"})
      }
    } catch (error) {
      console.error('请求异常:', error);
    }
  }

  build() {
    Column(){
      Image($r("app.media.appIcon"))
        .width('50%')
        .aspectRatio(1)
        .borderRadius('50%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

export async function getRecommendList(){
  try {
    const response = await getRecommend({ id: globalThis.userInfo.id })
    if (response.success) {
      console.log('完整响应:', JSON.stringify(response.data));

      let hotSongs: Array<object> = response.data['hotSongs']
      let dailyRecommends: Array<object> = response.data['dailyRecommends']
      let personalizedRadar: Array<object> = response.data['PersonalizedRadar']

      let hotSongsPlayList: PlayList = {
        id: 0,
        name: "热歌榜",
        author: {
          id: 0,
          name: "咕嘎音乐",
          avatar: ""
        },
        coverPicture: hotSongs[0]['al']['picUrl'],
        playCount: 0,
        shareCount: 0,
        commentCount: 0,
        saveCount: 0,
        intro: "",
        songList: [],
        songCount: 0,
        isSave: false
      }
      for (let i = 0; i < hotSongs.length; i++) {
        let item = hotSongs[i]

        let songSingers: Array<object> = item['ar']
        let newSongSingers: SingerLabel[] = []
        for (let j = 0; j < songSingers.length; j++) {
          newSongSingers.push({
            id: songSingers[j]['id'],
            userId: 0,
            name: songSingers[j]['name'],
            avatar: "",
            isFollowed: false
          } as SingerLabel)
        }

        hotSongsPlayList.songList.push({
          id: item['id'],
          url: "",
          name: item['name'],
          coverPicture: item['al']['picUrl'],
          duration: 0,
          singerList: newSongSingers,
          lyric: "",
          translateLyric: "",
          album: {
            id: item['al']['id'],
            name: item['al']['name'],
          } as AlbumLabel,
          isLoved: item['isLove'],
          isVip: item['fee'] == 1
        } as Song)
      }

      let dailyRecommendsPlayList: PlayList = {
        id: 0,
        name: "每日推荐",
        author: {
          id: 0,
          name: "咕嘎音乐",
          avatar: ""
        },
        coverPicture: dailyRecommends[0]['album']['picUrl'],
        playCount: 0,
        shareCount: 0,
        commentCount: 0,
        saveCount: 0,
        intro: "",
        songList: [],
        songCount: 0,
        isSave: false
      }
      for (let i = 0; i < dailyRecommends.length; i++) {
        let item = dailyRecommends[i]

        let songSingers: Array<object> = item['artists']
        let newSongSingers: SingerLabel[] = []
        for (let j = 0; j < songSingers.length; j++) {
          newSongSingers.push({
            id: songSingers[j]['id'],
            userId: 0,
            name: songSingers[j]['name'],
            avatar: "",
            isFollowed: false
          } as SingerLabel)
        }

        dailyRecommendsPlayList.songList.push({
          id: item['id'],
          url: "",
          name: item['name'],
          coverPicture: item['album']['picUrl'],
          duration: 0,
          singerList: newSongSingers,
          lyric: "",
          translateLyric: "",
          album: {
            id: item['album']['id'],
            name: item['album']['name'],
          } as AlbumLabel,
          isLoved: item['isLove'],
          isVip: item['fee'] == 1
        } as Song)
      }

      let personalizedRadarPlayList: PlayList = {
        id: 0,
        name: "私人雷达",
        author: {
          id: 0,
          name: "咕嘎音乐",
          avatar: ""
        },
        coverPicture: personalizedRadar[0]['cover'],
        playCount: 0,
        shareCount: 0,
        commentCount: 0,
        saveCount: 0,
        intro: "",
        songList: [],
        songCount: 0,
        isSave: false
      }
      for (let i = 0; i < personalizedRadar.length; i++) {
        let item = personalizedRadar[i]

        let songSingers: Array<object> = item['artists']
        let newSongSingers: SingerLabel[] = []
        for (let j = 0; j < songSingers.length; j++) {
          newSongSingers.push({
            id: songSingers[j]['id'],
            userId: 0,
            name: songSingers[j]['name'],
            avatar: "",
            isFollowed: false
          } as SingerLabel)
        }

        personalizedRadarPlayList.songList.push({
          id: item['id'],
          url: "",
          name: item['name'],
          coverPicture: item['cover'],
          duration: 0,
          singerList: newSongSingers,
          lyric: "",
          translateLyric: "",
          album: {
            id: 0,
            name: item['album'],
          } as AlbumLabel,
          isLoved: item['isLove'],
          isVip: item['is_vip']
        } as Song)
      }

      globalThis.hotSongs = hotSongsPlayList
      globalThis.dailyRecommends = dailyRecommendsPlayList
      globalThis.personalizedRadar = personalizedRadarPlayList


    } else {
      console.log('完整响应:', JSON.stringify(response.data));
    }
  } catch (error) {
    console.error('请求异常:', error);
  }
}