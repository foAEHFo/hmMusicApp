import { emptySong, tempPlayList} from "./model/TempData"
import { AlbumLabel, Song} from './interface/Song'
import {PlayList} from './interface/Song'
import {interpolateColors,getAverageColor,createPixelMapFromBuffer, adjustToBrightnessThreshold} from "./method/Color"
import { common } from "@kit.AbilityKit"
import { router} from "@kit.ArkUI"
import { BottomMusicPlayBar } from "./model/BottomMusicPlayBar"
import { addSongToPlayList,
  createPlayList,
  deleteSongFromPlayList,
  getMyPlayListAllSongs, getNetPlayListAllSongs, getUserPlayList, } from "./http/api"
import { SingerLabel } from "./interface/Personal"
import {downloadImage} from "./method/Http"
import {SongDataSource} from "./utils/LazyList"
import {formatNumber} from "./method/Number"



@Entry
@Component
struct PersonalPlayListPage{
  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  @State playList:PlayList = tempPlayList
  @State playListType:"web"|"local"|"null" = "local"

  private outsideScroller:Scroller = new Scroller()
  private insideScroller:Scroller = new Scroller()

  @State coverColor:string = "#725f53"
  @State curCoverColor:string = "#725f53"
  @State scrollOffset:number = 0
  @State scrollRatio:number = 1
  @State isScrollDown:boolean = false

  async getCoverColor(imageUrl:string) {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;

    try {
      const imageData  = await downloadImage(imageUrl);

      const color = await getAverageColor(context, imageData);

      const adjustColor = adjustToBrightnessThreshold(color,150)

      this.coverColor = `#${adjustColor.red.toString(16).padStart(2, '0')}${adjustColor.green.toString(16).padStart(2, '0')}${adjustColor.blue.toString(16).padStart(2, '0')}`
      this.curCoverColor = this.coverColor

    } catch (err) {
      console.error('处理失败', err);
    }
  }

  @State songDataSource:SongDataSource = new SongDataSource()

  async aboutToAppear(){
    let params = router.getParams() as Record<string, PlayList|("web"|"local"|"null")>
    if(params){
      this.playList = params['playList'] as PlayList
      this.playListType = params['playListType'] as ("web"|"local"|"null")
      if(this.playListType!="null"){
        await this.getSongList()
      }
      else{
        let globalType = params['globalType'] as string
        if(globalType=="hotSongs"){
          this.playList = globalThis.hotSongs
        }
        else{
          if(globalType=="dailyRecommends"){
            this.playList = globalThis.dailyRecommends
          }
          else{
            this.playList = globalThis.personalizedRadar
          }
        }
        await this.getCoverColor(this.playList.coverPicture)

        this.isWebDone = true
      }
      this.songDataSource._songs = this.playList.songList
    }
  }

  @State @Watch('getSongList') isUIUpdate:boolean = true

  @State isWebDone:boolean = false
  private async getSongList(){
    try {
      console.log("正在获取歌单信息")
      console.log(this.playList.id.toString())
      console.log(this.playListType)
      if(this.playListType=="local"){
        let response = await getMyPlayListAllSongs({playListId:this.playList.id})
        if (response.success) {
          console.log('完整响应:', JSON.stringify(response.data));
          this.playList.songList = []
          let songs:Array<object> = response.data['songs']
          for(let i=0;i<songs.length;i++){
            let item = songs[i]

            let songSingers:Array<object> = item['artists']
            let newSongSingers:SingerLabel[] = []
            for(let j=0;j<songSingers.length;j++){
              newSongSingers.push({
                id:songSingers[j]['id'],
                userId:0,
                name:songSingers[j]['name'],
                avatar:"",
                isFollowed:false
              } as SingerLabel)
            }

            this.playList.songList.push({
              id:item['id'],
              url:"",
              name:item['name'],
              coverPicture:item['album']['picUrl'],
              duration:0,
              singerList: newSongSingers,
              lyric:"",
              translateLyric:"",
              album:{
                id:item['album']['id'],
                name: item['album']['name'],
              } as AlbumLabel,
              isLoved:false,
              isVip:item['fee']
            } as Song)
          }

          await this.getCoverColor(this.playList.coverPicture)

          this.isWebDone = true

          this.songDataSource.updateAllSongs(this.playList.songList)

        } else {
          this.getUIContext().showAlertDialog({
            message:response.message
          })
        }
      }
      else {
        let response = await getNetPlayListAllSongs({ playListId: this.playList.id })
        if (response.success) {
          console.log('完整响应:', JSON.stringify(response.data));

          this.playList.songList = []

          let songs: Array<object> = response.data['tracks']
          let info: object = response.data['info']
          this.playList.intro = info['description']
          this.playList.author = {
            id:info['id'],
            name:info['creator']['nickname'],
            avatar:info['creator']['avatar']
          }
          this.playList.coverPicture = info['cover_img']

          for (let i = 0; i < songs.length; i++) {
            let item = songs[i]

            let songSingers: Array<object> = item['artists']
            let newSongSingers: SingerLabel[] = []
            for (let j = 0; j < songSingers.length; j++) {
              newSongSingers.push({
                id: songSingers[j]['id'],
                userId:0,
                name: songSingers[j]['name'],
                avatar: "",
                isFollowed: false
              } as SingerLabel)
            }

            this.playList.songList.push({
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
              isLoved: false,
              isVip:item['is_vip']
            } as Song)
          }

          await this.getCoverColor(this.playList.coverPicture)

          this.isWebDone = true

          this.songDataSource.updateAllSongs(this.playList.songList)
        }
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
            Row()
              .width('100%')
              .height('100%')
              .backgroundColor(this.curCoverColor)
            Row({space:12}){
              Image($r("app.media.leftArrow"))
                .width(30)
                .height(30)
                .fillColor(this.isScrollDown?$r("app.color.softBlack"):$r("app.color.backgroundWhite"))
                .onClick(()=>{
                  router.back()
                })
              Blank()
              Image($r("app.media.detailsIcon"))
                .width(28)
                .height(28)
                .fillColor(this.isScrollDown?$r("app.color.softBlack"):$r("app.color.backgroundWhite"))
            }
            .width('100%')
            .height('100%')
            .padding({top:this.topStatusBarHeight,left:12,right:12})
            .alignItems(VerticalAlign.Center)
            Row(){
              Text(this.playList.name)
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
              Stack(){
                playListHeader({playList:this.playList,curOpacity:this.scrollRatio})
              }
              Column(){
                playListBar({playList:this.playList})
                  .margin({top:12})
                List() {
                  LazyForEach(this.songDataSource, (item: Song,index) => {
                    ListItem() {
                      songItem({song:item,songList:this.playList.songList,index:index,isShowAddPlayListSheet:this.isShowAddPlayListSheet,selectSong:this.selectSong,playListId:this.playList.id,isUIUpdate:this.isUIUpdate})
                    }
                  }, (item: Song) => item.id.toString())

                  ListItem() {
                    Row()
                      .height(64)
                  }
                }
                .width('100%')
                .layoutWeight(1)
                .scrollBar(BarState.Off)
                .nestedScroll({
                  scrollForward: NestedScrollMode.PARENT_FIRST,
                  scrollBackward: NestedScrollMode.SELF_FIRST
                })
                .align(Alignment.TopStart)
                .padding({ top: 6, bottom: 8 })
              }
              .width('100%')
              .height('100%')
              .backgroundColor($r("app.color.backgroundWhite"))
              .borderRadius({topLeft:8,topRight:8})
            }
            .justifyContent(FlexAlign.Start)
            .backgroundColor(this.curCoverColor)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .onScrollFrameBegin((offset)=>{
            this.scrollOffset = this.outsideScroller.currentOffset().yOffset
            this.scrollRatio = (206.33-this.scrollOffset)/206.33
            this.isScrollDown = this.scrollOffset >= 180
            this.curCoverColor = interpolateColors("#f3f7fa",this.coverColor,this.scrollRatio)
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
      .bindSheet(
        $$this.isShowAddPlayListSheet,
        this.addToPlayListSheet(),
        {
          detents: ['75%'],
          showClose: false,
          dragBar: true,
          title: {title:"收藏到歌单"},
          backgroundColor:Color.White
        })
    }
  }
  @State playLists:PlayList[] = []
  @State @Watch('addToPlayList') isShowAddPlayListSheet:boolean = false
  @State selectSong:Song = emptySong

  private async addToPlayList(){
    if(this.isShowAddPlayListSheet){
      await this.getPlayLists();
      globalThis.personalUIUpdate = true
    }
  }

  private async getPlayLists(){
    try {
      this.playLists = []
      console.log("正在获取个人歌单")
      let response = await getUserPlayList({id:globalThis.userInfo.id})
      if (response.success) {
        console.log('完整响应:', JSON.stringify(response.data));

        let createList:Array<object> = response.data['isCreate']

        for(let i=0;i<createList.length;i++){
          let item = createList[i]
          this.playLists.push({
            id:item['id'],
            name: item['playListsName'],
            author: globalThis.userInfo.name,
            coverPicture: item['coverPicture'],
            playCount: item['playCount'],
            shareCount: 0,
            commentCount: 0,
            saveCount: 0,
            intro: item['description'],
            songList: [],
            songCount: item['songCount'],
            isSave:true
          } as PlayList)
        }

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

  @Builder
  addToPlayListSheet(){
    Column(){
      if(this.isWebDone){
        Column(){
          Row(){}
          .width('100%')
          .height(1)
          .backgroundColor(0xe6e6e6)

          List({space:15}){
            ListItem(){
              Row({space:12}) {
                Row() {
                  Image($r("app.media.addIcon"))
                    .width(35)
                    .height(35)
                    .fillColor($r("app.color.themeColor"))
                }
                .width(60)
                .height(60)
                .borderRadius(10)
                .backgroundColor(0xf1f1f1)
                .justifyContent(FlexAlign.Center)

                Column({ space: 4 }) {
                  Text("新建歌单")
                    .fontSize(16)
                    .fontColor($r("app.color.softBlack"))
                    .fontWeight(FontWeight.Medium)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
            }
            .bindSheet(
              $$this.isShowNewPlayListSheet,
              this.createNewPlayList(),
              {
                detents: ['50%'],
                showClose: false,
                dragBar: true,
                title: this.createNewPlayListTitle(),
                backgroundColor:Color.White
              })
            .onClick(()=>{
              this.isShowNewPlayListSheet = true
            })

            ForEach(this.playLists,(item:PlayList,index)=>{
              ListItem(){
                Row({space:12}){
                  Image(item.coverPicture)
                    .width(60)
                    .height(60)
                    .borderRadius(10)
                  Column({space:4}){
                    Text(item.name)
                      .fontSize(16)
                      .fontColor($r("app.color.softBlack"))
                      .fontWeight(FontWeight.Medium)
                    Text(`${item.songCount}首`)
                      .fontSize(14)
                      .fontColor($r("app.color.noteColor"))
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
              }
              .onClick(()=>{
                addSongToPlayList({playListId:item.id, songId:this.selectSong.id})
                this.isShowAddPlayListSheet = false
              })
            })
          }
          .width('100%')
          .height('100%')
          .padding(12)
        }
      }
    }
  }

  @State inputPlayListName:string = ""
  @State isShowNewPlayListSheet:boolean = false

  @Builder
  createNewPlayList(){
    Column(){
      Row(){
        TextInput()
          .onChange((value)=>{
            this.inputPlayListName = value
          })
      }
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  createNewPlayListTitle(){
    Row(){
      Text("取消")
        .fontColor($r("app.color.softBlack"))
        .fontSize(16)
        .onClick(()=>{
          this.inputPlayListName = ""
          this.isShowNewPlayListSheet = false
        })
      Blank()
      Text("新建歌单")
        .fontColor($r("app.color.softBlack"))
        .fontSize(16)
      Blank()
      Text("完成")
        .fontColor($r("app.color.softBlack"))
        .fontSize(16)
        .onClick(()=>{
          this.createPlayList(globalThis.userInfo.id,this.inputPlayListName)
        })
    }
    .width('100%')
    .height('100%')
    .padding({left:12,right:12,top:12})
  }

  private async createPlayList(userId:number,name:string){
    await createPlayList({id:userId,name:name})
    this.isShowNewPlayListSheet = false
    this.isWebDone = false
    this.getPlayLists()
  }
}

@Component
struct playListHeader{
  @Prop playList:PlayList
  @Prop curOpacity:number
  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0
  build() {
    Column(){
      Row(){
        Image(this.playList.coverPicture?this.playList.coverPicture:$r("app.media.tempPlayListCover"))
          .width(120)
          .height(120)
          .borderRadius(4)
          .opacity(this.curOpacity)
        Column(){
          Text(this.playList.name)
            .width('100%')
            .fontSize(20)
            .fontColor($r("app.color.backgroundWhite"))
            .fontWeight("bold")
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})
          Row(){
            Text(this.playList.author.name)
              .fontSize(12)
              .fontColor(Color.White)
              .opacity(0.8)
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .constraintSize({maxWidth:110})
              .textOverflow({overflow:TextOverflow.Ellipsis})
            Image($r("app.media.verticalLine"))
              .width(5)
              .height(15)
              .margin({left:5,right:5})
              .fillColor(Color.White)
              .opacity(0.3)
              .scale({x:0.5})

            Text(`${formatNumber(this.playList.playCount)}次播放`)
              .fontSize(12)
              .fontColor(Color.White)
              .opacity(0.8)
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .margin({top:8})
          Text(this.playList.intro)
            .width('100%')
            .height(42)
            .margin({top:8})
            .padding({right:10})
            .fontSize(12)
            .fontColor($r("app.color.backgroundWhite"))
            .opacity(0.5)
            .maxLines(3)
            .textOverflow({overflow:TextOverflow.Ellipsis})
            .align(Alignment.TopStart)
        }
        .height(120)
        .layoutWeight(1)
        .margin({left:16})
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height(120)
      Row(){
        Button(){
          Row({space:5}){
            Image($r("app.media.shareIconFace"))
              .width(18)
              .height(18)
              .fillColor($r("app.color.backgroundWhite"))
            Text(this.playList.shareCount!=0? this.playList.shareCount.toString(): "分享")
              .fontSize(14)
              .fontColor($r("app.color.backgroundWhite"))
          }
          .height(16)
          .alignItems(VerticalAlign.Center)
        }
        .width(105)
        .height(36)
        .backgroundColor("rgba(255,255,255,0.1)")
        Button(){
          Row({space:5}){
            Image($r("app.media.commentIconFace"))
              .width(16)
              .height(16)
              .fillColor($r("app.color.backgroundWhite"))
            Text(this.playList.shareCount!=0? this.playList.shareCount.toString(): "评论")
              .fontSize(14)
              .fontColor($r("app.color.backgroundWhite"))
          }
          .height(16)
          .alignItems(VerticalAlign.Center)
        }
        .width(105)
        .height(36)
        .backgroundColor("rgba(255,255,255,0.1)")
        Button(){
          Row({space:5}){
            Image($r("app.media.saveIcon"))
              .width(14)
              .height(14)
              .fillColor($r("app.color.backgroundWhite"))
            Text(this.playList.shareCount!=0? this.playList.shareCount.toString(): "收藏")
              .fontSize(14)
              .fontColor($r("app.color.backgroundWhite"))
          }
          .height(16)
          .alignItems(VerticalAlign.Center)
        }
        .width(105)
        .height(36)
        .backgroundColor("rgba(255,255,255,0.1)")
      }
      .width('100%')
      .margin({top:20})
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({top:10,bottom:20,left:12,right:12})
  }
}

@Component
struct playListBar{
  @Prop playList:PlayList

  build() {
    Row(){
      Row(){
        Image($r("app.media.playIcon"))
          .fillColor($r("app.color.backgroundWhite"))
          .width('50%')
          .height('50%')
      }
      .height('80%')
      .aspectRatio(1)
      .backgroundColor($r("app.color.themeColor"))
      .borderRadius('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      Column({space:4}){
        Text("播放全部")
          .fontSize(15)
          .fontColor($r("app.color.softBlack"))
          .fontWeight("bold")
        Text(`${this.playList.songCount}首`)
          .fontSize(12)
          .fontColor($r("app.color.noteColor"))
      }
      .height("100%")
      .margin({left:12})
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      Blank()
      Image($r("app.media.downloadIcon"))
        .height('40%')
        .aspectRatio(1)
        .fillColor(0x252638)
        .margin({right:20})
      Image($r("app.media.multiCheckIcon"))
        .height('35%')
        .aspectRatio(1)
        .fillColor(0x252638)
    }
    .width('100%')
    .height(50)
    .padding({left:16,right:16})
    .backgroundColor($r("app.color.backgroundWhite"))
  }
}

@Component
struct songItem{
  @Prop song:Song
  @Prop songList:Song[]
  @Prop index:number
  @Prop playListId:number
  @State isShowSheet:boolean = false
  @Link isShowAddPlayListSheet:boolean
  @Link selectSong:Song
  @Link isUIUpdate:boolean

  private async play(){
    console.log(this.song.id.toString())
    await globalThis.musicPlayer.changePlayList(this.songList,this.index)
    router.pushUrl({url:"pages/SongPlay"}, router.RouterMode.Single)
  }

  build() {
    Row(){
      Image(this.song.coverPicture?this.song.coverPicture:$r("app.media.tempSongCover"))
        .width(40)
        .height(40)
        .borderRadius(2)
      Column(){
        Text(this.song.name)
          .width('100%')
          .fontSize(14)
          .fontColor($r("app.color.softBlack"))
          .textAlign(TextAlign.Start)
        Text(this.song.album.name.length!=0?`${this.song.singerList.map(singer=>singer.name).join('/')} - ${this.song.album.name}`:`${this.song.singerList.map(singer=>singer.name).join('/')}`)
          .width('100%')
          .fontSize(11)
          .fontColor($r("app.color.noteColor"))
          .textAlign(TextAlign.Start)
      }
      .layoutWeight(1)
      .height(30)
      .margin({left:8,right:8})
      Image($r("app.media.detailsIcon"))
        .width(30)
        .height(30)
        .fillColor(0xb0b3ba)
        .bindSheet(
          $$this.isShowSheet,
          this.detailsSheet(),
          {
            detents: ['75%'],
            showClose: false,
            dragBar: true,
            title: this.detailsSheetHeader,
            backgroundColor:Color.White
          })
        .onClick(()=>{
          this.isShowSheet = true
        })
    }
    .width('100%')
    .padding({top:8,bottom:8,left:16,right:8})
    .onClick(()=>{
      this.play()
    })
  }

  @Builder
  detailsSheetHeader(){
    Row({space:12}){
      Column({space:6}){
        Text(this.song.name)
          .fontSize(16)
          .fontColor($r("app.color.softBlack"))
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
        Row({space:8}){
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
      Blank()
        .width(12)
    }
    .width('100%')
    .padding({left:12,right:12,top:12})
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  detailsSheet(){
    Column(){
      Row(){}
      .width('100%')
      .height(1)
      .backgroundColor(0xe6e6e6)
      .margin({top:12})

      Column({space:32}){
        Row({space:16}){
          Image($r("app.media.addToPlayListIcon"))
            .width(20)
            .height(20)
            .fillColor($r("app.color.softBlack"))
          Text("下一首播放")
            .fontSize(16)
            .fontColor($r("app.color.softBlack"))
            .onClick(()=>{
              globalThis.musicPlayer.addToList(this.song)
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Row({space:16}){
          Image($r("app.media.binIcon"))
            .width(20)
            .height(20)
            .scale({x:1.5,y:1.5})
            .fillColor($r("app.color.softBlack"))
          Text("删除歌曲")
            .fontSize(16)
            .fontColor($r("app.color.softBlack"))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .onClick(()=>{
          this.deleteSong()
        })

        Row({space:16}){
          Image($r("app.media.addToSongListIcon"))
            .width(20)
            .height(20)
            .fillColor($r("app.color.softBlack"))
          Text("收藏到歌单")
            .fontSize(16)
            .fontColor($r("app.color.softBlack"))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .onClick(()=>{
          this.selectSong = this.song
          this.isShowSheet = false
          this.isShowAddPlayListSheet = true;
        })
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .justifyContent(FlexAlign.Start)
    }
  }

  private async deleteSong(){
    await deleteSongFromPlayList({playListId:this.playListId,songId:this.song.id})
    this.isUIUpdate = !this.isUIUpdate
    this.isShowSheet = false
  }
}