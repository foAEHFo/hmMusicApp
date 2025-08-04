import {SearchBar} from "./model/SearchBar"
import * as Search from "./interface/Search";
import {Song,PlayList, Album, AlbumLabel} from "./interface/Song"
import { UserInformation,SingerInformation, SingerLabel, UserLabel } from "./interface/Personal";
import { router } from "@kit.ArkUI";
import { BottomMusicPlayBar } from "./model/BottomMusicPlayBar";
import { getUserPlayList, searchAll, addSongToPlayList, createPlayList, deleteSongFromPlayList } from "./http/api"
import { emptySong, tempSingerInformation, tempSingerLabelList, tempSingerList, tempSong } from "./model/TempData";
import {formatNumber} from "./method/Number"

@Entry
@Component
struct SearchResultsPage{
  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  tabList:string[] = [
    "综合","单曲","歌单","歌手","用户"
  ]
  private tabBarHeight:number = 50
  @State selectIndex:number = 0

  @State searchResults:Search.SearchAllResults = {
    isDone:false,
    topSinger:tempSingerInformation,
    songResults:{isDone:false,songList:[]},
    playListResults:{isDone:false,playListList:[]},
    singerResults:{isDone:false,singerLabelList:tempSingerLabelList},
    userResults:{isDone:false,userLabelList:[]}
  }

  @State searchQuery:string = ""

  private async getAllResults(){
    try {
      console.log("正在搜索")
      console.log(this.searchQuery)
      console.log(globalThis.userInfo.id)
      let response = await searchAll({s:this.searchQuery,userId:globalThis.userInfo.id})

      if (response.success) {
        console.log('完整响应:', JSON.stringify(response.data));

        let data:object = response.data
        let topArtist:object = data['topArtist']
        let result:object = data['Result']
        let artists:Array<object> = result['artists']
        let songs:Array<object> = result['songs']
        let playLists:Array<object> = result['playlists']
        let users:Array<object> = result['users']

        let newTopSinger:SingerInformation

        if(topArtist){
          newTopSinger = {
            id:topArtist['id'],
            userId:topArtist['accountId']?topArtist['accountId']:0,
            name:topArtist['name'],
            avatar:topArtist['avatar_url'],
            isFollowed:topArtist?artists[0]['isLove']:false,
            coverPicture:"",
            sex:1,
            followCount:0,
            fans:topArtist['followeds'],
            alias:"",
            tags:[""],
            songList:[],
            albumList:[],
            songCount:topArtist['musicSize'],
            albumCount:topArtist['albumSize']
          }
        }
        else{
          newTopSinger = tempSingerInformation
        }

        let newSongs:Song[] = []
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
          newSongs.push({
            id:item['id'],
            url:"",
            name:item['name'],
            coverPicture:"",
            duration:0,
            singerList: newSongSingers,
            lyric:"",
            translateLyric:"",
            album:{
              id:item['album']['id'],
              name: item['album']['name'],
            } as AlbumLabel,
            isLoved:item['isLove'],
            isVip:(item['fee']) as number == 1
          } as Song)
        }

        let newPlayLists:PlayList[] = []
        for(let i=0;i<playLists.length;i++){
          let item = playLists[i]
          newPlayLists.push({
            id:item['id'],
            name: item['name'],
            author: {
              'id':item['creator']['userId'],
              'name':item['creator']['nickname'],
              'avatar':item['creator']['avatarUrl']
            },
            coverPicture:item['coverImgUrl'],
            playCount: item['playCount'],
            shareCount: 0,
            commentCount: 0,
            saveCount: item['bookCount'],
            intro: item['description'],
            songList: [],
            songCount:item['trackCount'],
            isSave:item['isLove']
          })
        }

        let newSingerLabels:SingerLabel[] = []
        for(let i=0;i<artists.length;i++){
          let item = artists[i]
          newSingerLabels.push({
            id:item['id'],
            userId:item['accountId']?item['accountId']:0,
            name:item['name'],
            avatar:item['img1v1Url'],
            isFollowed:item['isLove'],
          } as SingerLabel)
        }

        let newUserLabels:UserLabel[] = []
        for(let i=0;i<users.length;i++){
          let item = users[i]
          newUserLabels.push({
            id:item['id'],
            name:item['username'],
            avatar:item['headPicture']?item['headPicture']:""
          })
        }

        this.searchResults = {
          isDone:true,
          topSinger:newTopSinger,
          songResults:{
            isDone:true,
            songList:newSongs
          },
          playListResults:{
            isDone:true,
            playListList:newPlayLists
          },
          singerResults:{
            isDone:true,
            singerLabelList:newSingerLabels
          },
          userResults:{
            isDone:true,
            userLabelList:newUserLabels
          }
        }

      } else {
        this.getUIContext().showAlertDialog({
          message:response.message
        })
      }
    } catch (error) {
      console.error('请求异常:', error);
    }
  }

  async aboutToAppear(){
    let params = router.getParams() as Record<string, string | number | boolean>
    if(params){
      this.searchQuery = params['searchQuery'] as string
    }
    await this.getAllResults()
  }

  build() {
    Stack(){
      Column({space:0}){
        Row(){
          Image($r("app.media.leftArrow"))
            .width(35)
            .height(35)
            .fillColor(0x0e0f23)
            .onClick(()=>{
              router.back()
            })
          Row(){
            SearchBar({
              searchQuery:this.searchQuery,
              inputEnabled:false,
              clickCallBack:()=>{
                router.back()
              }})
          }
          .layoutWeight(1)
          .margin({left:4,right:12})
        }
        .width('100%')
        .height($r("app.float.top_bar_height"))
        Tabs({barPosition:BarPosition.Start}){
          TabContent() {
            allContent({searchResults:this.searchResults,isShowAddPlayListSheet:this.isShowAddPlayListSheet,selectSong:this.selectSong,isLoved:this.isLoved})
          }
          .align(Alignment.TopStart)
          .tabBar(SubTabBarStyle.of("综合")
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
            SongContent({songResults:this.searchResults.songResults,isShowAddPlayListSheet:this.isShowAddPlayListSheet,selectSong:this.selectSong,isLoved:this.isLoved})
          }
          .tabBar(SubTabBarStyle.of("单曲")
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
          TabContent() {
            PlayListContent({playListResults:this.searchResults.playListResults})
          }
          .tabBar(SubTabBarStyle.of("歌单")
            .indicator({
              color: $r("app.color.themeColor"), // 下划线颜色
              height: 3, // 下划线高度
              width: 16, // 下划线宽度
              borderRadius: 4, // 下划线圆角半径
              marginTop: 4 // 下划线与文字间距
            })
            .labelStyle({font:{weight:FontWeight.Regular,size:16},
              selectedColor:this.selectIndex==2?$r("app.color.softBlack"):$r("app.color.noteColor"),
              unselectedColor:this.selectIndex==2?$r("app.color.softBlack"):$r("app.color.noteColor")})
            .padding(0))
          TabContent() {
            SingerContent({singerResults:this.searchResults.singerResults})
          }
          .tabBar(SubTabBarStyle.of("歌手")
            .indicator({
              color: $r("app.color.themeColor"), // 下划线颜色
              height: 3, // 下划线高度
              width: 16, // 下划线宽度
              borderRadius: 4, // 下划线圆角半径
              marginTop: 4 // 下划线与文字间距
            })
            .labelStyle({font:{weight:FontWeight.Regular,size:16},
              selectedColor:this.selectIndex==3?$r("app.color.softBlack"):$r("app.color.noteColor"),
              unselectedColor:this.selectIndex==3?$r("app.color.softBlack"):$r("app.color.noteColor")})
            .padding(0))
          TabContent() {
            UserContent({userResults:this.searchResults.userResults})
          }
          .tabBar(SubTabBarStyle.of("用户")
            .indicator({
              color: $r("app.color.themeColor"), // 下划线颜色
              height: 3, // 下划线高度
              width: 16, // 下划线宽度
              borderRadius: 4, // 下划线圆角半径
              marginTop: 4 // 下划线与文字间距
            })
            .labelStyle({font:{weight:FontWeight.Regular,size:16},
              selectedColor:this.selectIndex==4?$r("app.color.softBlack"):$r("app.color.noteColor"),
              unselectedColor:this.selectIndex==4?$r("app.color.softBlack"):$r("app.color.noteColor")})
            .padding(0))
        }
        .width("100%")
        .layoutWeight(1)
        .barHeight(this.tabBarHeight)
        .borderRadius(5)
        .onContentWillChange((currentIndex,comingIndex)=>{
          this.selectIndex = comingIndex
          return true
        })
      }
      .width('100%')
      .height('100%')
      .padding({top:12+this.topStatusBarHeight,bottom:12,left:12,right:12})
      .backgroundColor($r("app.color.backgroundWhite"))

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

  @State playLists:PlayList[] = []
  @State @Watch('addToPlayList') isShowAddPlayListSheet:boolean = false
  @State selectSong:Song = emptySong
  @State isWebDone:boolean = false
  @State @Watch('addToLovedList') isLoved:boolean = false

  private async addToPlayList(){
    if(this.isShowAddPlayListSheet){
      await this.getPlayLists();
    }
  }

  private async addToLovedList(){
    if(this.isLoved){
      await this.getPlayLists();
      if(this.selectSong.isLoved){
        deleteSongFromPlayList({playListId:this.playLists[0].id, songId:this.selectSong.id})
        this.selectSong.isLoved = false
      }else{
        addSongToPlayList({playListId:this.playLists[0].id, songId:this.selectSong.id})
        this.selectSong.isLoved = true
      }
      this.isLoved = false
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
struct allContent{
  @Prop searchResults:Search.SearchAllResults
  @Link isShowAddPlayListSheet:boolean
  @Link selectSong:Song
  @Link isLoved:boolean

  private async play(){
    await globalThis.musicPlayer.changePlayList(this.searchResults.songResults.songList,Math.floor(Math.random() * this.searchResults.songResults.songList.length))
    router.pushUrl({url:"pages/SongPlay"}, router.RouterMode.Single)
  }

  build() {
    if(this.searchResults.isDone){
      Scroll(){
        Column({space:12}){
          Column(){
            if(this.searchResults.topSinger!=tempSingerInformation){
              SingerItem({singer:this.searchResults.topSinger})
              Blank()
                .height(12)
            }
            if(this.searchResults.playListResults.playListList.length>0){
              PlayListItem({playList:this.searchResults.playListResults.playListList[0]})
              Blank()
                .height(6)
            }
            if(this.searchResults.topSinger!=tempSingerInformation||this.searchResults.playListResults.playListList.length>0){
              Divider()
                .height(6)
                .strokeWidth(1)
                .color(0xe6eaed)
            }
          }

          Column({space:16}){
            Row({space:8}){
              Text("单曲精选")
                .fontColor($r("app.color.softBlack"))
                .fontWeight(FontWeight.Bold)
                .fontSize(18)
              Row(){
                Image($r("app.media.playIcon"))
                  .width(10)
                  .height(10)
                  .fillColor(Color.White)
                  .onClick(()=>{
                    this.play()
                  })
              }
              .width(24)
              .height(24)
              .borderRadius(24)
              .justifyContent(FlexAlign.Center)
              .backgroundColor($r("app.color.themeColor"))
            }
            .width('100%')
            ForEach(this.searchResults.songResults.songList,(item:Song,_)=>{
              SongItem({song:item,isShowAddPlayListSheet:this.isShowAddPlayListSheet,selectSong:this.selectSong,isLoved:this.isLoved})
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Divider()
            .height(6)
            .strokeWidth(1)
            .color(0xe6eaed)

          Column({space:16}){
            Text("歌单")
              .fontColor($r("app.color.softBlack"))
              .fontWeight(FontWeight.Bold)
              .fontSize(18)
            ForEach(this.searchResults.playListResults.playListList,(item:PlayList,_)=>{
              PlayListItem({playList:item})
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Divider()
            .height(6)
            .strokeWidth(1)
            .color(0xe6eaed)

          Column({space:16}){
            Text("歌手")
              .fontColor($r("app.color.softBlack"))
              .fontWeight(FontWeight.Bold)
              .fontSize(18)
            ForEach(this.searchResults.singerResults.singerLabelList,(item:SingerLabel,_)=>{
              SingerLabelItem({singer:item})
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Divider()
            .height(6)
            .strokeWidth(1)
            .color(0xe6eaed)

          Column({space:16}){
            Text("用户")
              .fontColor($r("app.color.softBlack"))
              .fontWeight(FontWeight.Bold)
              .fontSize(18)
            ForEach(this.searchResults.userResults.userLabelList,(item:UserLabel,_)=>{
              UserItem({user:item})
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Blank()
            .height(100)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({left:6})
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
    }
  }
}

@Component
struct SongContent{
  @Prop songResults:Search.SearchSongResults
  @Link isShowAddPlayListSheet:boolean
  @Link selectSong:Song
  @Link isLoved:boolean

  build() {
    if(this.songResults.isDone){
      Column({space:12}){
        Row({space:8}){
          Row(){
            Image($r("app.media.playIcon"))
              .width(10)
              .height(10)
              .fillColor(Color.White)
          }
          .width(24)
          .height(24)
          .borderRadius(24)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r("app.color.themeColor"))

          Text("播放全部")
            .fontColor($r("app.color.softBlack"))
            .fontSize(18)
        }
        .width('100%')
        Scroll(){
          Column({space:16}){
            ForEach(this.songResults.songList,(item:Song,index)=>{
              SongItem({song:item,songList:this.songResults.songList,index:index,isShowAddPlayListSheet:this.isShowAddPlayListSheet,selectSong:this.selectSong,isLoved:this.isLoved})
            })
            Blank()
              .height(100)
          }
        }
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
      }
    }

  }
}

@Component
struct PlayListContent{
  @Prop playListResults:Search.SearchPlayListResults

  build() {
    if(this.playListResults.isDone){
      Scroll(){
        Column({space:16}){
          ForEach(this.playListResults.playListList,(item:PlayList,_)=>{
            PlayListItem({playList:item})
          })
          Blank()
            .height(100)
        }
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
    }
  }
}

@Component
struct SingerContent{
  @Prop singerResults:Search.SearchSingerResults

  build() {
    if(this.singerResults.isDone){
      Scroll(){
        Column({space:16}){
          ForEach(this.singerResults.singerLabelList,(item:SingerLabel,_)=>{
            SingerLabelItem({singer:item})
          })
          Blank()
            .height(100)
        }
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
    }
  }
}

@Component
struct UserContent{
  @Prop userResults:Search.SearchUserResults

  build() {
    if(this.userResults.isDone){
      Scroll(){
        Column({space:16}){
          ForEach(this.userResults.userLabelList,(item:UserLabel,_)=>{
            UserItem({user:item})
          })
          Blank()
            .height(100)
        }
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
    }
  }
}

@Component
struct SingerItem{
  @Prop singer:SingerInformation

  build() {
    Row({space:12}){
      Image(this.singer.avatar)
        .width(50)
        .height(50)
        .borderRadius(50)
      Column({space:6}){
        Text(`${this.singer.name}`)
          .fontSize(16)
          .fontColor($r("app.color.softBlack"))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
        if(this.singer.fans!=0){
          Text(`粉丝: ${formatNumber(this.singer.fans)},歌曲: ${this.singer.songCount}`,)
            .fontSize(14)
            .fontColor($r("app.color.noteColor"))
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})
        }
        else{
          Text(`专辑: ${this.singer.albumCount},歌曲: ${this.singer.songCount}`)
            .fontSize(14)
            .fontColor($r("app.color.noteColor"))
            .maxLines(1)
            .textOverflow({overflow:TextOverflow.Ellipsis})
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .onClick(()=>{
      router.pushUrl({
        url: 'pages/Singer',
        params: { singerLabel:{
          id:this.singer.id,
          userId:this.singer.userId,
          name:this.singer.name,
          avatar:this.singer.avatar,
          isFollowed:this.singer.isFollowed
        } as SingerLabel }
      });
    })
  }
}

@Component
struct SingerLabelItem{
  @Prop singer:SingerLabel

  build() {
    Row({space:12}){
      Image(this.singer.avatar)
        .width(50)
        .height(50)
        .borderRadius(50)
      Text(`${this.singer.name}`)
        .fontSize(16)
        .fontColor($r("app.color.softBlack"))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({overflow:TextOverflow.Ellipsis})
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .onClick(()=>{
      router.pushUrl({
        url: 'pages/Singer',
        params: { singerLabel:this.singer }
      });
    })

  }
}

@Component
struct PlayListItem{
  @Prop playList:PlayList

  build() {
    Row({space:12}){
      Image(this.playList.coverPicture)
        .width(50)
        .height(50)
        .borderRadius(4)
      Column({space:6}){
        Text(`${this.playList.name}`)
          .fontSize(16)
          .fontColor($r("app.color.softBlack"))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
        Text(`${this.playList.songCount}首音乐,by ${this.playList.author.name},播放${formatNumber(this.playList.playCount)}次`)
          .fontSize(14)
          .fontColor($r("app.color.noteColor"))
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .onClick(()=> {
      router.pushUrl({
        url: "pages/PersonalPlayList",
        params: { playList: this.playList, playListType: "web" }
      })
    })
  }
}

@Component
struct UserItem{
  @Prop user:UserLabel

  build() {
    Row({space:8}){
      Image($r("app.media.tempAvatar"))
        .width(50)
        .height(50)
        .borderRadius(50)
      Column({space:8}){
        Text(this.user.name)
          .fontSize(16)
          .fontColor($r("app.color.softBlack"))
          .maxLines(1)
          .textOverflow({overflow:TextOverflow.Ellipsis})
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .onClick(()=>{
      router.pushUrl({
        url: "pages/User",
        params: { userLabel:this.user }
      })
    })
  }
}

@Component
struct SongItem{
  @Prop song:Song
  @Prop songList:Song[]
  @Prop index:number
  @State isShowSheet:boolean = false
  @Link isShowAddPlayListSheet:boolean
  @Link selectSong:Song
  @Link isLoved:boolean

  private async play(){
    console.log(this.song.id.toString())
    await globalThis.musicPlayer.playSong(this.song)
    router.pushUrl({url:"pages/SongPlay"}, router.RouterMode.Single)
  }

  build() {
    Row(){
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
      Image($r("app.media.addToPlayListIcon"))
        .width(18)
        .height(18)
        .fillColor(0x939496)
        .onClick(()=>{
          globalThis.musicPlayer.addToList(this.song)
        })
      Blank()
        .width(12)
      Image($r("app.media.detailsIcon"))
        .width(20)
        .height(20)
        .fillColor(0x939496)
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
    .justifyContent(FlexAlign.Start)
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
          Image(this.song.isLoved?$r("app.media.heartFillIcon"):$r("app.media.heartIcon"))
            .width(20)
            .height(20)
            .scale({x:1.2,y:1.2})
            .fillColor(this.song.isLoved?$r("app.color.lightRed"):$r("app.color.softBlack"))
          Text("喜欢")
            .fontSize(16)
            .fontColor($r("app.color.softBlack"))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .onClick(()=>{
          this.selectSong = this.song
          this.isLoved = true
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
}

