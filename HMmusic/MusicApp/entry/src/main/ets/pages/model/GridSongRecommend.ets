import {Song} from "../interface/Song"
import { router } from "@kit.ArkUI"

@Component
export struct GridSongRecommend{
  @Prop songList:Song[]
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.songList = globalThis.dailyRecommends.songList
  }

  build() {
    Column({space:16}){
      Text("推荐的歌曲")
        .fontSize(16)
        .fontColor($r("app.color.softBlack"))
        .fontWeight("bold")
      // Scroll(this.scroller){
      //   Grid(){
      //     ForEach(this.songList,(item:Song)=>{
      //       SongItem({song:item})
      //     })
      //   }
      //   .layoutDirection(GridDirection.Column)
      //   .maxCount(3)
      //   .columnsGap(10)
      //   .rowsGap(10)
      // }
      // .scrollable(ScrollDirection.Horizontal)
      // .scrollBar(BarState.Off)
      Swiper(){
        ForEach([0,1,2],(item1:number)=>{
          Column({space:10}){
            ForEach([0,1,2],(item2:number)=>{
              SongItem({song:this.songList[item1*3+item2]})
            })
          }
        })
      }
      .itemSpace(10)
      .nextMargin(20)
      .indicator(false)
      .loop(false)
      .effectMode(EdgeEffect.None)
    }
    .alignItems(HorizontalAlign.Start)
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