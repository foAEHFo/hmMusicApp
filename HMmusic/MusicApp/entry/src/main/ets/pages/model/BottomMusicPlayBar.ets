import { PlayState, PlayStateModel, Song } from "../interface/Song"
import { emptySong, tempSong} from "./TempData"
import { emitter } from "@kit.BasicServicesKit"
import { EmitEventType } from "../event/type"
import { router } from "@kit.ArkUI"

@Component
export struct BottomMusicPlayBar{
  @State song:Song = emptySong

  @State isShowPlayList:boolean = false

  private playStateUpdateCallBack(){
    if(this.playState.currentPlayIndex<0){
      this.song = emptySong
    }
    else{
      this.song = this.playState.playList[this.playState.currentPlayIndex]
    }
  }

  @State @Watch('playStateUpdateCallBack') playState:PlayState = {
    currentTime: 0,
    isPlaying: false,
    playMode:'loop',
    playList:[],
    currentPlayIndex:0
  }

  aboutToAppear(){
    emitter.on({ eventId: EmitEventType.UPDATE_STATE }, (data) => {
      this.playState = new PlayStateModel(JSON.parse(data.data!.playStateStr))
    })
    globalThis.musicPlayer.updateUIState()
  }

  build() {
    Row({space:12}){
      Stack(){
        Image($r("app.media.recordBackground"))
          .height('100%')
        Image(this.song.id!=0?this.song.coverPicture:$r("app.media.tempSongCover"))
          .height('65%')
          .borderRadius('80%')
      }
      .height('100%')
      .onClick(()=>{
        if(this.song.id!=0){
          router.pushUrl({url:"pages/SongPlay"})
        }
      })

      Text(){
        Span(this.song.id!=0?this.song.name:"未知歌曲")
          .fontSize(16)
          .fontColor(0x262739)
        Span(this.song.id!=0?` - ${this.song.singerList.map(singer=>singer.name).join('/')}`:"")
          .fontSize(14)
          .fontColor(0x6f6f77)
      }
      .layoutWeight(1)
      .height('100%')
      .textOverflow({overflow:TextOverflow.MARQUEE})
      .marqueeOptions({
        start:true,
        step:2.5,
        loop:-1,
        delay:1000
      })
      .onClick(()=>{
        router.pushUrl({url:"pages/SongPlay"})
      })

      if(this.playState.isPlaying){
        Image($r("app.media.pauseIcon"))
          .width(20)
          .height(20)
          .fillColor(0x262739)
          .onClick(()=>{
            if(this.song!=emptySong){
              globalThis.musicPlayer.togglePlay()
            }
          })
      }
      else{
        Image($r("app.media.playIcon"))
          .width(20)
          .height(20)
          .fillColor(0x262739)
          .onClick(()=>{
            if(this.song!=emptySong){
              globalThis.musicPlayer.togglePlay()
            }
          })
      }

      Image($r("app.media.songPlayListIcon"))
        .width(26)
        .height(26)
        .fillColor(0x262739)
        .onClick(()=>{
          this.isShowPlayList = true
        })
        .bindSheet(
          $$this.isShowPlayList,
          this.playListSheet(),
          {
            detents: ['75%'],
            showClose: false,
            dragBar: true,
            title: this.playListSheetTitle,
            backgroundColor:Color.White
          })
    }
    .width('90%')
    .height(40)
    .padding({right:18})
    .backgroundColor(Color.White)
    .borderRadius(40)
    .shadow({
      radius:20,
      color: "#ffdcdcdc"
    })
  }

  @Builder
  playListSheetTitle(){
    Column({space:12}){
      Stack() {
        Text("当前播放")
          .fontSize(20)
          .fontColor($r("app.color.softBlack"))
          .fontWeight(FontWeight.Medium)
          .align(Alignment.TopStart)

        Text(this.playState.playList.length.toString())
          .fontSize(14)
          .fontColor($r("app.color.softBlack"))
          .fontWeight(FontWeight.Medium)
          .position({ x: '100%', y: 0 })
          .translate({ x: '-50%', y: '0%' })
          .margin({ top: -8, right: -8 })
      }
      .height(35)
    }
    .width(87)
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({top:12})
  }

  @Builder
  playListSheet(){
    Column({space:12}){
      Row(){}
      .width('100%')
      .height(1)
      .backgroundColor(0xe6e6e6)

      Row(){
        Button(){
          if(this.playState.playMode=='loop'){
            Row({space:4}){
              Image($r("app.media.LoopPlayIcon"))
                .width(16)
                .height(16)
                .fillColor(0x252734)
              Text("列表循环")
                .fontSize(12)
                .fontColor(0x262837)
            }
          }
          else{
            if(this.playState.playMode=='random'){
              Row({space:4}){
                Image($r("app.media.randomPlayIcon"))
                  .width(16)
                  .height(16)
                  .fillColor(0x252734)
                  .scale({x:0.85,y:0.85})
                Text("随机播放")
                  .fontSize(12)
                  .fontColor(0x262837)
              }
            }
            else{
              Row({space:4}){
                Image($r("app.media.repeatPlayIcon"))
                  .width(16)
                  .height(16)
                  .fillColor(0x252734)
                Text("单曲循环")
                  .fontSize(12)
                  .fontColor(0x262837)
              }
            }
          }
        }
        .backgroundColor(0xf6f6f6)
        .border({width:0.5,color:0xe2e2e4})
        .padding({left:12,right:12,top:6,bottom:6})
        .onClick(()=>{
          globalThis.musicPlayer.changePlayMode()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({left:18})

      List(){
        ForEach(this.playState.playList,(item:Song,index)=>{
          ListItem(){
            Row(){
              Text(item.name)
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(16)
                .fontColor(this.playState.currentPlayIndex==index?$r("app.color.lightRed"):$r("app.color.softBlack"))
              Text(` · ${item.singerList.map(singer=>singer.name).join('/')}`)
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(14)
                .fontColor(this.playState.currentPlayIndex==index?$r("app.color.lightRed"):0x87878f)
              Blank()
              Image($r("app.media.cancelIconLine"))
                .width(18)
                .height(18)
                .fillColor(0xc5c4c9)
                .onClick(()=>{
                  globalThis.musicPlayer.removeSongFromPlayList(item.id)
                })
            }
            .width('100%')
            .alignItems(VerticalAlign.Bottom)
          }
          .width('100%')
          .height(45)
          .padding({left:18,right:18})
          .backgroundColor(this.playState.currentPlayIndex==index?0xf6f6f6:Color.White)
          .onClick(()=>{
            globalThis.musicPlayer.jumpToIndex(index)
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}