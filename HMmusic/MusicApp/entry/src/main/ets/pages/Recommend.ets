import {Song} from "./interface/Song"
import {TopRecommendBlockItem} from "./interface/Component"
import {SearchBar} from "./model/SearchBar"
import {TopRecommendBlockList} from "./model/TopRecommendBlockList"
import {GridSongRecommend} from "./model/GridSongRecommend"
import {tempSongList} from "./model/TempData"
import { router } from "@kit.ArkUI"
import { BottomMusicPlayBar } from "./model/BottomMusicPlayBar"

@Entry
@Component
export struct RecommendPage{
  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  @State recommendSongList:Song[] = tempSongList.slice(0,9)

  @State TopRecommendBlockList: TopRecommendBlockItem[] = [
    {imageId:1,title:"每日推荐",intro:"今日限定好歌推荐"},
    {imageId:2,title:"热歌榜",intro:"云音乐官方top排行榜"},
    // {imageId:3,title:"心动模式",intro:"红心歌曲和相似推荐"},
    {imageId:4,title:"私人雷达",intro:"你爱的歌值得反复聆听"},
    // {imageId:5,title:"漫游",intro:"多样频道无限畅听"},
    // {imageId:6,title:"相似歌曲",intro:"从你喜欢的歌听起"}
  ];

  @State searchQuery:string = ""

  @Link isShowSideSheet:boolean
  @Link sideBoxShadowOpacity:number

  build() {
    Stack(){
      Scroll(){
        Column({space:32}){
          Row({space:12}){
            Image($r("app.media.menuIcon"))
              .width(25)
              .height(25)
              .onClick(()=>{
                animateTo({ duration: 200 }, () => {
                  this.isShowSideSheet = true
                  this.sideBoxShadowOpacity = 0.5
                })
              })
            SearchBar({
              searchQuery:this.searchQuery,
              inputEnabled:false,
              clickCallBack:()=>{
                router.pushUrl({url:"pages/SearchQuery"})
              }})
            Image($r("app.media.microphoneIcon"))
              .width('30')
              .height('30')
            // .onClick(()=>{
            //   router.pushUrl({url:"pages/microphone/index"})
            // })
          }
          .width('100%')
          .height($r("app.float.top_bar_height"))
          TopRecommendBlockList({blockList:this.TopRecommendBlockList})
          GridSongRecommend({songList:this.recommendSongList})

          Column({space:16}){
            Text("热歌榜")
              .fontSize(16)
              .fontColor($r("app.color.softBlack"))
              .fontWeight("bold")
            List({space:10}){
              ForEach([0,1,2,3,4,5],(item:number,index)=>{
                SongItem({song:globalThis.hotSongs.songList[item]})
              })
            }
          }
          .alignItems(HorizontalAlign.Start)

          Column({space:16}){
            Text("私人雷达")
              .fontSize(16)
              .fontColor($r("app.color.softBlack"))
              .fontWeight("bold")
            List({space:10}){
              ForEach([0,1,2,3,4,5],(item:number,index)=>{
                SongItem({song:globalThis.personalizedRadar.songList[item]})
              })
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
            .height(64)
        }
      }
      .width('100%')
      .height('100%')
      .padding({top:12+this.topStatusBarHeight,bottom:12,left:12,right:12})
      .scrollBar(BarState.Off)

      BottomMusicPlayBar()
        .margin({bottom:12})
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Bottom)
  }

}

@Component
struct SongItem{
  @Prop song:Song

  private async play(){
    console.log(this.song.id.toString())
    await globalThis.musicPlayer.playSong(this.song)
    router.pushUrl({url:"pages/SongPlay"}, router.RouterMode.Single)
  }

  build() {
    Row(){
      Image(this.song.coverPicture?this.song.coverPicture:$r("app.media.tempSongCover"))
        .width(40)
        .height(40)
        .borderRadius(4)
      Column({space:4}){
        Text(this.song.name)
          .fontSize(12)
          .fontColor($r("app.color.softBlack"))
          .fontWeight("bold")
        Row({space:4}){
          Image($r("app.media.heartFillIcon"))
            .width(10)
            .height(10)
            .fillColor($r("app.color.lightRed"))
            .visibility(this.song.isLoved?Visibility.Visible:Visibility.None)
          Text(this.song.singerList.map(singer=>singer.name).join('/'))
            .fontSize(10)
            .fontColor($r("app.color.noteColor"))
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({left:8,right:8})
      Image($r("app.media.playIcon"))
        .width(20)
        .height(20)
        .fillColor(0x535564)
    }
    .width('97%')
    .onClick(()=>{
      this.play()
    })
  }
}