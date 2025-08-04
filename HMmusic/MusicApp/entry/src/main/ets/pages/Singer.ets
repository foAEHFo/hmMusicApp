import {SingerInformation, SingerLabel} from "./interface/Personal"
import {tempSingerInformation} from "./model/TempData"
import { display, EllipseShape, router } from "@kit.ArkUI";
import { intl } from "@kit.LocalizationKit";
import {Song,Album, AlbumLabel} from "./interface/Song"
import { BottomMusicPlayBar } from "./model/BottomMusicPlayBar";
import { followSinger, getArtist, unfollowSinger} from "./http/api"
import { ResponseModel } from "./http/httpUtil";


@Entry
@Component
struct SingerPage{
  @State singer:SingerInformation = tempSingerInformation

  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  @State selectIndex:number = 0
  @State tabsHeight:number = 0
  @State headerHeight:number = 450
  @State tempTabsHeight:number = 663;
  @State tabBarHeight:number = 50

  private outsideScroller:Scroller = new Scroller()
  @State scrollOffset:number = 0
  @State scrollRatio:number = 0
  @State isScrollDown:boolean = false

  private ellipseShape:EllipseShape = new EllipseShape()
    .width('300%')
    .height('200%')
    .offset({x:'-100%',y:'-100%'});

  async aboutToAppear(){
    let screenHeight = display.getDefaultDisplaySync().height
    this.tabsHeight = this.getUIContext().px2vp(screenHeight)-50-this.topStatusBarHeight+2
    if(this.tabsHeight<=0){
      this.tabsHeight = this.tempTabsHeight
    }
    let params = router.getParams() as Record<string, SingerLabel>
    if(params){
      let singerLabel = params['singerLabel'] as SingerLabel
      await this.getSingerInformation(singerLabel)
    }
  }

  @State isWebDone:boolean = false

  private async getSingerInformation(singerLabel:SingerLabel){
    try {
      console.log("正在获取歌手信息")

      console.log(singerLabel.id.toString())
      if(singerLabel.userId==0){
        let response:ResponseModel
        response = await getArtist({artistId:singerLabel.id,userId:globalThis.userInfo.id})
        if (response.success) {
          console.log('完整响应:', JSON.stringify(response.data));

          let basicInfo:object = response.data['basic_info']
          let albums:Array<object> = response.data['albums']['albums']
          let topSongs:Array<object> = response.data['top_songs']['songs']

          let newSongs:Song[] = []

          for(let i=0;i<topSongs.length;i++){
            let item = topSongs[i]

            let newSingers:SingerLabel[] = []

            for(let j=0;j<item['ar'].length;j++){
              let newSinger:object = item['ar'][j]
              newSingers.push({
                id:newSinger['id'],
                userId:0,
                name:newSinger['name'],
                avatar:"",
                isFollowed:false
              } as SingerLabel)
            }

            newSongs.push({
              id:item['id'],
              url:"",
              name:item['name'],
              coverPicture:"",
              duration:0,
              singerList:newSingers,
              lyric:"",
              translateLyric:"",
              album:{
                id:item['al']['id'],
                name:item['al']['name']
              } as AlbumLabel,
              isLoved:false,
              isVip:(item['fee'] as number)==1
            })
          }

          let newAlbums:Album[] = []
          for(let i=0;i<albums.length;i++){
            let item = albums[i]
            newAlbums.push({
              id:item['id'],
              name:item['name'],
              coverPicture:item['cover_url'],
              singerList: [singerLabel],
              releaseDate: item['publish_date'],
              shareCount: 0,
              commentCount: 0,
              saveCount: 0,
              songList: [],
              songCount:item['song_count'],
              isSave: false
            } as Album)
          }

          this.singer = {
            id:singerLabel.id,
            userId:singerLabel.userId,
            avatar:singerLabel.avatar,
            coverPicture:basicInfo['background_url'],
            name:singerLabel.name,
            sex:1,
            followCount:basicInfo['follows'],
            fans:basicInfo['followeds'],
            alias:basicInfo['alias']?basicInfo['alias']:"",
            tags:[],
            isFollowed:basicInfo['isLove'],
            songList:newSongs,
            songCount:basicInfo['musicSize'],
            albumList:newAlbums,
            albumCount:basicInfo['albumSize']
          }

          this.isWebDone = true

        } else {
          this.getUIContext().showAlertDialog({
            message:response.message
          })
        }
      }
      else{
        let response:ResponseModel
        response = await getArtist({artistId:singerLabel.id,accountId:singerLabel.userId,userId:globalThis.userInfo.id})
        if (response.success) {
          console.log('完整响应:', JSON.stringify(response.data));
          let basicInfo:object = response.data['basic_info']
          let albums:Array<object> = response.data['albums']['albums']
          let topSongs:Array<object> = response.data['top_songs']['songs']

          let newSongs:Song[] = []

          for(let i=0;i<topSongs.length;i++){
            let item = topSongs[i]

            let newSingers:SingerLabel[] = []

            for(let j=0;j<item['ar'].length;j++){
              let newSinger:object = item['ar'][j]
              newSingers.push({
                id:newSinger['id'],
                userId:0,
                name:newSinger['name'],
                avatar:"",
                isFollowed:false
              } as SingerLabel)
            }

            newSongs.push({
              id:item['id'],
              url:"",
              name:item['name'],
              coverPicture:"",
              duration:0,
              singerList:newSingers,
              lyric:"",
              translateLyric:"",
              album:{
                id:item['al']['id'],
                name:item['al']['name']
              } as AlbumLabel,
              isLoved:false,
              isVip:(item['fee'] as number)==1
            })
          }

          let newAlbums:Album[] = []
          for(let i=0;i<albums.length;i++){
            let item = albums[i]
            newAlbums.push({
              id:item['id'],
              name:item['name'],
              coverPicture:item['cover_url'],
              singerList: [],
              releaseDate: item['publish_date'],
              shareCount: 0,
              commentCount: 0,
              saveCount: 0,
              songList: [],
              songCount:item['song_count'],
              isSave: false
            } as Album)
          }

          this.singer = {
            id:singerLabel.id,
            userId:singerLabel.userId,
            avatar:singerLabel.avatar,
            coverPicture:basicInfo['background_url'],
            name:singerLabel.name,
            sex:1,
            followCount:basicInfo['follows'],
            fans:basicInfo['followeds'],
            alias:basicInfo['alias']?basicInfo['alias']:"",
            tags:basicInfo['tags'],
            isFollowed:basicInfo['isLove'],
            songList:newSongs,
            songCount:basicInfo['musicSize'],
            albumList:newAlbums,
            albumCount:basicInfo['albumSize']
          }

          this.isWebDone = true

        } else {
          this.getUIContext().showAlertDialog({
            message:response.message
          })
        }
      }
    } catch (error) {
      console.error('请求异常:', error);
    }
  }

  private async changeSingerFollow(){
    if(this.singer.isFollowed){
      await unfollowSinger({userId:globalThis.userInfo.id,artistAccountId:this.singer.id})
    }
    else{
      await followSinger({userId:globalThis.userInfo.id,artistAccountId:this.singer.id})
    }
    this.singer.isFollowed = !this.singer.isFollowed
  }

  build(){
    if(this.isWebDone){
      Stack(){
        Stack(){
          Scroll(this.outsideScroller){
            Column(){
              //封面部分
              Stack(){
                Column(){}
                .width('90%')
                .height('50%')
                .borderRadius(15)
                .shadow({
                  radius:10,
                  color: "#ffdcdcdc"
                })
                Column(){
                  Image(this.singer.coverPicture?this.singer.coverPicture:$r("app.media.tempSingerCover"))
                    .width('100%')
                    .height('75%')
                    .objectFit(ImageFit.Cover)
                    .clipShape(this.ellipseShape)
                  Blank()
                }
                .height('100%')
                Column({space:8}){
                  Row(){
                    Image(this.singer.avatar?this.singer.avatar:$r("app.media.tempAvatar"))
                      .width(60)
                      .height(60)
                      .borderRadius(60)
                  }
                  .position({y:-35})
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  Text(this.singer.name)
                    .fontColor($r("app.color.softBlack"))
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .margin({top:35})
                  Text(this.singer.alias)
                    .fontColor(0x999999)
                    .fontSize(12)
                  Row({space:4}){
                    Text(new intl.NumberFormat('zh-Hans',{
                      notation:'compact',
                      compactDisplay:'short'
                    })
                      .format(this.singer.fans))
                      .fontColor(0x999999)
                      .fontSize(14)
                    Text("粉丝")
                      .fontColor(0x808080)
                      .fontSize(14)
                  }
                  .visibility(this.singer.userId==0?Visibility.Hidden:Visibility.Visible)
                  Row(){
                    ForEach(this.singer.tags,(item:string,index)=>{
                      Text(index!=this.singer.tags.length-1?item+'、':item)
                        .fontColor(0x999999)
                        .fontSize(14)
                    })
                  }
                  Button(this.singer.isFollowed?"已关注":"+ 关注")
                    .height(30)
                    .fontSize(14)
                    .fontColor(this.singer.isFollowed?0x929292:Color.White)
                    .backgroundColor(this.singer.isFollowed?0xf3f3f3:$r("app.color.themeColor"))
                    .onClick(()=>{
                      this.changeSingerFollow()
                    })
                    .animation({curve:Curve.Smooth,duration:0.4})
                }
                .width('90%')
                .height('40%')
                .backgroundColor("#f2ffffff")
                .borderRadius(10)
              }
              .height(this.headerHeight)
              .alignContent(Alignment.Bottom)

              //内容部分
              Tabs({barPosition:BarPosition.Start}){
                TabContent() {
                  SongContent({songList:this.singer.songList})
                }
                .tabBar(SubTabBarStyle.of("歌曲")
                  .indicator({
                    color: $r("app.color.themeColor"), // 下划线颜色
                    height: 3, // 下划线高度
                    width: 16, // 下划线宽度
                    borderRadius: 4, // 下划线圆角半径
                    marginTop: 4 // 下划线与文字间距
                  })
                  .labelStyle({font:{weight:FontWeight.Regular,size:16},
                    selectedColor:this.selectIndex==0?$r("app.color.softBlack"):$r("app.color.noteColor"),
                    unselectedColor:this.selectIndex==0?$r("app.color.softBlack"):$r("app.color.noteColor")})
                  .padding(0))
                TabContent() {
                  AlbumContent({albumList:this.singer.albumList})
                }
                .tabBar(SubTabBarStyle.of("专辑")
                  .indicator({
                    color: $r("app.color.themeColor"), // 下划线颜色
                    height: 3, // 下划线高度
                    width: 16, // 下划线宽度
                    borderRadius: 4, // 下划线圆角半径
                    marginTop: 4 // 下划线与文字间距
                  })
                  .labelStyle({font:{weight:FontWeight.Regular,size:16},
                    selectedColor:this.selectIndex==1?$r("app.color.softBlack"):$r("app.color.noteColor"),
                    unselectedColor:this.selectIndex==1?$r("app.color.softBlack"):$r("app.color.noteColor")})
                  .padding(0))
              }
              .width("100%")
              .height(this.tabsHeight)
              .barHeight(this.tabBarHeight)
              .padding({left:12,right:12})
              .borderRadius(5)
              .onContentWillChange((currentIndex,comingIndex)=>{
                this.selectIndex = comingIndex
                return true
              })
            }
            .backgroundColor(Color.White)
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .onScrollFrameBegin((offset)=>{
            this.scrollOffset = this.outsideScroller.currentOffset().yOffset
            this.scrollRatio = this.scrollOffset/200
            this.isScrollDown = this.scrollOffset >= 200
            return {offsetRemain:offset}
          })

          //顶部工具栏部分
          Stack(){
            Row(){}
            .width('100%')
            .height('100%')
            .backgroundColor(Color.White)
            .opacity(this.scrollRatio)
            Row(){
              Image($r("app.media.leftArrow"))
                .width(30)
                .height(30)
                .fillColor(this.isScrollDown?0x0e0f23:Color.White)
                .margin({left:4,right:12})
                .onClick(()=>{
                  router.back()
                })
              Text(this.singer.name)
                .fontSize(20)
                .fontColor($r("app.color.softBlack"))
                .visibility(this.isScrollDown?Visibility.Visible:Visibility.Hidden)
              Blank()
              Button(this.singer.isFollowed?"已关注":"+ 关注")
                .height(25)
                .padding({left:15,right:15})
                .fontSize(10)
                .fontColor(this.singer.isFollowed?0x929292:Color.White)
                .backgroundColor(this.singer.isFollowed?0xf3f3f3:$r("app.color.themeColor"))
                .onClick(()=>{
                  this.changeSingerFollow()
                })
                .animation({curve:Curve.Smooth,duration:0.4})
                .visibility(this.isScrollDown?Visibility.Visible:Visibility.Hidden)
            }
            .width('100%')
            .padding({right:10})
          }
          .width('100%')
          .height(50+this.topStatusBarHeight)
          .alignContent(Alignment.Bottom)
        }
        .height('100%')
        .alignContent(Alignment.TopStart)

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
struct SongContent{
  @Prop songList:Song[]

  build() {
    Column({space:12}){
      Row({space:8}){
        Row(){
          Image($r("app.media.playIcon"))
            .width(11)
            .height(11)
            .fillColor(Color.White)
        }
        .width(24)
        .height(24)
        .borderRadius(24)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r("app.color.themeColor"))

        Text("播放热门50")
          .fontColor($r("app.color.softBlack"))
          .fontSize(18)
      }
      .width('100%')
      .margin({top:12})
      Scroll(){
        Column({space:16}){
          ForEach(this.songList,(item:Song,index)=>{
            SongItem({index:index+1,song:item})
          })
          Row(){
            Text("全部作曲")
              .fontSize(16)
              .fontColor(0x999999)
            Image($r("app.media.leftArrow"))
              .width(16)
              .height(16)
              .rotate({angle:180})
          }
          .margin({bottom:50})

          Blank()
            .height(64)
        }
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
  }
}

@Component
struct AlbumContent{
  @Prop albumList:Album[]

  build() {
    Column({space:12}){
      Scroll(){
        Column({space:24}){
          Blank()
            .height(10)
          ForEach(this.albumList,(item:Album,index)=>{
            AlbumItem({index:index+1,album:item})
          })
          Blank()
            .height(64)
        }
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
  }
}

@Component
struct SongItem{
  @Prop index:number
  @Prop song:Song

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
      .alignItems(HorizontalAlign.Start)
      Image(this.song.isLoved?$r("app.media.heartFillIcon"):$r("app.media.heartIcon"))
        .width(18)
        .height(18)
        .margin({left:12})
        .fillColor(this.song.isLoved?$r("app.color.lightRed"):0x939496)
      Image($r("app.media.addToPlayListIcon"))
        .width(15)
        .height(15)
        .margin({left:16})
        .fillColor(this.song.isLoved?$r("app.color.lightRed"):0x939496)
      Image($r("app.media.detailsIcon"))
        .width(20)
        .height(20)
        .margin({left:8})
        .fillColor(0x939496)

    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .onClick(()=>{
      this.play()
    })
  }
}

@Component
struct AlbumItem{
  @Prop index:number
  @Prop album:Album

  build() {
    Row(){
      Stack(){
        Circle()
          .width(40)
          .height(40)
          .fill(0x272727)
          .translate({y:-15})
        Image(this.album.coverPicture?this.album.coverPicture:$r("app.media.tempAlbumCover"))
          .width(50)
          .height(50)
          .borderRadius(4)
      }
      .width(50)
      .height(50)

      Blank()
        .width(10)

      Column({space:6}){
        Text(this.album.name)
          .fontSize(16)
          .fontColor($r("app.color.softBlack"))
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
        Text(`${this.album.releaseDate} ${this.album.songCount}首`)
          .fontSize(14)
          .fontColor($r("app.color.noteColor"))
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .onClick(()=>{
      router.pushUrl({
        url:"pages/Album",
        params: { album:this.album }
      })
    })
  }
}