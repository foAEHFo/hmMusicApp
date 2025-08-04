import {tempAlbum} from "./model/TempData"
import {Song,Album, AlbumLabel} from './interface/Song'
import { EllipseShape, router } from '@kit.ArkUI';
import {PlayList} from './interface/Song'
import {getAverageColor} from "./method/Color"
import { common } from "@kit.AbilityKit"
import { BottomMusicPlayBar } from "./model/BottomMusicPlayBar";
import { getAlbumSongs } from "./http/api";

@Entry
@Component
struct AlbumPage{
  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  @State album:Album = tempAlbum

  private outsideScroller:Scroller = new Scroller()
  private insideScroller:Scroller = new Scroller()

  @State coverColor:string = "#725f53"
  @State scrollOffset:number = 0
  @State scrollRatio:number = 1
  @State isScrollDown:boolean = false

  async getCoverColor() {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const resourceMgr = context.resourceManager;

    try {
      const mediaContent = await resourceMgr.getMediaContent($r("app.media.tempAlbumCover").id);

      let color = await getAverageColor(context,mediaContent)

      this.coverColor = `#${color.red.toString(16).padStart(2, '0')}${color.green.toString(16).padStart(2, '0')}${color.blue.toString(16).padStart(2, '0')}`

    } catch (err) {
      console.error('处理失败', err);
    }
  }

  async aboutToAppear(){
    let params = router.getParams() as Record<string, Album>
    if(params){
      let album = params['album'] as Album
      await this.getAlbumSongList(album)
    }

    this.getCoverColor()
  }

  @State isWebDone:boolean = false
  private async getAlbumSongList(album:Album){
    try {
      this.album = album

      console.log("正在获取专辑信息")
      let response = await getAlbumSongs({albumId:album.id})

      if (response.success) {
        console.log('完整响应:', JSON.stringify(response.data));

        let newSongList:Song[] = []

        let songs:Array<object> = response.data['songs']
        for(let i=0;i<songs.length;i++){
          let item = songs[i]
          newSongList.push({
            id:item['id'],
            url:"",
            name:item['name'],
            coverPicture:"",
            duration:0,
            singerList:this.album.singerList,
            lyric:"",
            translateLyric:"",
            album:{
              id:album.id,
              name:album.name
            }as AlbumLabel,
            isLoved:false,
            isVip:response.data['paid']
          })
        }
        this.album.songList = newSongList

        this.isWebDone = true

      } else {
        this.getUIContext().showAlertDialog({
          message:response.message
        })
      }
    } catch (error) {
      console.error('请求异常:', error);
    }
  }

  build() {
    if(this.isWebDone){
      Stack(){
        Column(){
          Stack(){
            Row({space:12}){
              Image($r("app.media.leftArrow"))
                .width(30)
                .height(30)
                .fillColor(Color.White)
                .onClick(()=>{
                  router.back()
                })
              Blank()
              Image($r("app.media.detailsIcon"))
                .width(28)
                .height(28)
                .fillColor(Color.White)
            }
            .width('100%')
            .height('100%')
            .padding({top:this.topStatusBarHeight,left:12,right:12})
            .alignItems(VerticalAlign.Center)
            .backgroundColor(this.coverColor)
            Row(){
              Text(this.album.name)
                .fontColor(Color.White)
                .opacity((this.scrollOffset-180)/(203.66-180))
                .padding({top:this.topStatusBarHeight,left:12,right:12})
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .height(40+this.topStatusBarHeight)
          Scroll(this.outsideScroller){
            Column(){
              albumHeader({album:this.album,coverColor:this.coverColor})

              Column(){
                albumBar({album:this.album})
                  .margin({top:12})
                Scroll(this.insideScroller){
                  Column(){
                    ForEach(this.album.songList,(item:Song,index)=>{
                      songItem({song:item,index:index})
                    })
                    Blank()
                      .height(64)
                  }
                  .width('100%')
                  .padding({top:6,bottom:8})
                  .justifyContent(FlexAlign.Start)
                }
                .width('100%')
                .layoutWeight(1)
                .scrollBar(BarState.Off)
                .nestedScroll({
                  scrollForward: NestedScrollMode.PARENT_FIRST,
                  scrollBackward: NestedScrollMode.SELF_FIRST
                })
                .align(Alignment.TopStart)
              }
              .width('100%')
              .height('100%')
              .backgroundColor(Color.White)
              .borderRadius({topLeft:8,topRight:8})
            }
            .justifyContent(FlexAlign.Start)
            .backgroundColor(Color.White)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .onScrollFrameBegin((offset)=>{
            this.scrollOffset = this.outsideScroller.currentOffset().yOffset
            this.scrollRatio = (216.33-this.scrollOffset)/216.33
            this.isScrollDown = this.scrollOffset >= 190
            return {offsetRemain:offset}
          })
        }
        .width('100%')
        .height('100%')

        BottomMusicPlayBar()
          .margin({bottom:24})
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Bottom)
    }
  }
}

@Component
struct albumHeader{
  @Prop album:Album
  @Prop coverColor:string
  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  private ellipseShape:EllipseShape = new EllipseShape()
    .width('400%')
    .height('200%')
    .offset({x:'-150%',y:'-108%'});

  build() {
    Stack(){
      Row(){}
      .width(250)
      .height(45)
      .margin({top:20})
      .padding({left:25,right:25})
      .borderRadius(40)
      .justifyContent(FlexAlign.SpaceBetween)
      .shadow({
        radius:10,
        color: "#ffdcdcdc"
      })

      Row(){
        Stack(){
          Circle()
            .width(100)
            .height(100)
            .fill(0x272727)
            .translate({y:-30})
          Image(this.album.coverPicture?this.album.coverPicture:$r("app.media.tempAlbumCover"))
            .width(120)
            .height(120)
            .borderRadius(4)
        }
        .width(120)
        .height(120)
        Column(){
          Text(this.album.name)
            .width('100%')
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight("bold")
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})

          Blank()
            .layoutWeight(1)

          Row({space:0}){
            Text(this.album.singerList.map(singer=>singer.name).join('/'))
              .fontSize(12)
              .fontColor(Color.White)
              .opacity(0.8)
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .constraintSize({maxWidth:110})
              .textOverflow({overflow:TextOverflow.Ellipsis})
            Image($r("app.media.leftArrow"))
              .width(15)
              .height(15)
              .margin({left:5,right:5})
              .fillColor(Color.White)
              .rotate({angle:180})
              .opacity(0.8)
          }
          .width('100%')

          Blank()
            .layoutWeight(2)

          Text(`发行时间: ${this.album.releaseDate}`)
            .width('100%')
            .fontSize(12)
            .fontColor(Color.White)
            .opacity(0.8)
            .textAlign(TextAlign.Start)
        }
        .height(120)
        .layoutWeight(1)
        .margin({left:16})
        .padding({top:16,bottom:16})
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .padding({top:20,bottom:20,left:12,right:12})
      .alignItems(VerticalAlign.Top)
      .backgroundColor(this.coverColor)
      .clipShape(this.ellipseShape)

      Row(){
        Row({space:5}){
          Image($r("app.media.saveLineIcon"))
            .width(18)
            .height(18)
            .fillColor(0x333333)
          Text(this.album.saveCount!=0? this.album.saveCount.toString(): "收藏")
            .fontSize(14)
            .fontColor(0x333333)
            .fontWeight(this.album.saveCount!=0?FontWeight.Medium:FontWeight.Regular)
        }

        Divider()
          .height(25)
          .vertical(true)
          .strokeWidth(1)
          .color(0xe5e5e5)
          .margin({left:12,right:12})

        Row({space:5}){
          Image($r("app.media.commentIconLine"))
            .width(18)
            .height(18)
            .fillColor(0x333333)
          Text(this.album.commentCount!=0? this.album.commentCount.toString(): "评论")
            .fontSize(14)
            .fontColor(0x333333)
            .fontWeight(this.album.saveCount!=0?FontWeight.Medium:FontWeight.Regular)
        }

        Divider()
          .height(25)
          .vertical(true)
          .strokeWidth(1)
          .color(0xe5e5e5)
          .margin({left:12,right:12})

        Row({space:5}){
          Image($r("app.media.shareCircleIcon"))
            .width(22)
            .height(22)
            .fillColor(0x333333)
          Text(this.album.shareCount!=0? this.album.shareCount.toString(): "分享")
            .fontSize(14)
            .fontColor(0x333333)
            .fontWeight(this.album.saveCount!=0?FontWeight.Medium:FontWeight.Regular)
        }
      }
      .width(250)
      .height(45)
      .margin({top:20})
      .padding({left:25,right:25})
      .backgroundColor(Color.White)
      .borderRadius(40)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(220.33)
    .padding({bottom:4})
    .alignContent(Alignment.Bottom)
  }
}

@Component
struct albumBar{
  @Prop album:Album

  build() {
    Row(){
      Row(){
        Image($r("app.media.playIcon"))
          .fillColor(Color.White)
          .width('45%')
          .height('45%')
      }
      .height('50%')
      .aspectRatio(1)
      .backgroundColor($r("app.color.themeColor"))
      .borderRadius('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      Column({space:4}){
        Text("播放全部")
          .fontSize(15)
          .fontColor($r("app.color.softBlack"))
          .fontWeight(FontWeight.Medium)
      }
      .height("100%")
      .margin({left:12})
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      Blank()
      Image($r("app.media.downloadIcon"))
        .height('35%')
        .aspectRatio(1)
        .fillColor(0x252638)
        .margin({right:20})
      Image($r("app.media.multiCheckIcon"))
        .height('31%')
        .aspectRatio(1)
        .fillColor(0x252638)
    }
    .width('100%')
    .height(50)
    .padding({left:16,right:16})
    .backgroundColor(Color.White)
  }
}

@Component
struct songItem{
  @Prop song:Song
  @Prop index:number

  private async play(){
    console.log(this.song.id.toString())
    await globalThis.musicPlayer.playSong(this.song)
    router.pushUrl({url:"pages/SongPlay"}, router.RouterMode.Single)
  }

  build() {
    Row(){
      Text(this.index.toString())
        .width(40)
        .fontSize(16)
        .fontColor(0x999999)
        .textAlign(TextAlign.Center)
        .margin({right:8})

      Column({space:6}){
        Text(this.song.name)
          .fontSize(16)
          .fontColor($r("app.color.softBlack"))
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
        Row(){
          Image($r("app.media.vipIcon"))
            .width(15)
            .height(15)
            .visibility(this.song.isVip?Visibility.Visible:Visibility.None)
          Text(this.song.album.name.length!=0?`${this.song.singerList.map(singer=>singer.name).join('/')} - ${this.song.album.name}`:`${this.song.singerList.map(singer=>singer.name).join('/')}`)
            .fontSize(14)
            .fontColor($r("app.color.noteColor"))
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})
        }
      }
      .layoutWeight(1)
      .height(30)
      .margin({left:8,right:8})
      .alignItems(HorizontalAlign.Start)

      Image($r("app.media.detailsIcon"))
        .width(30)
        .height(30)
        .fillColor(0xb0b3ba)
    }
    .width('100%')
    .padding({top:8,bottom:8,left:16,right:8})
    .onClick(()=>{
      this.play()
    })
  }
}