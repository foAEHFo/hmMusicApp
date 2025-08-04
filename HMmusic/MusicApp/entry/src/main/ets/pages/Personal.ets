import {UserInformation} from "./interface/Personal"
import {display, router } from '@kit.ArkUI';
import {PlayList} from './interface/Song'
import { tempPlayListList } from "./model/TempData";
import { BottomMusicPlayBar } from "./model/BottomMusicPlayBar";
import { createPlayList, deletePlayList, getUserPlayList } from "./http/api";

@Entry
@Component
export struct PersonalPage {
  @Link isShowSideSheet:boolean
  @Link sideBoxShadowOpacity:number
  @Link @Watch('getPlayLists') isUIUpdate:boolean

  @Prop bottomBarHeight:number = 0

  @State createdPlayLists:PlayList[] = []
  @State collectedPlayLists:PlayList[] = []
  @State subscribedPlayLists:PlayList[] = []

  outScrollerObj: Scroller = new Scroller()
  @State topBarIsChange:boolean = false;
  @State topBarOpacity:number = 0;
  @State selectIndex:number = 0;

  @State touchStartY:number = 0;

  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0
  @State tabsHeight:number = 0
  @State pictureHeight:number = 300;
  @State tempTabsHeight:number = 663;
  @State tabBarHeight:number = 50

  @State currentPictureHeight: number = this.pictureHeight;

  maxPictureHeight:number = this.pictureHeight*1.5 //定义图片能够拉伸的最大值
  fiction:number = 0.5 //弹簧系数

  @State perInformation:UserInformation = globalThis.userInfo

  tabList:string[] = ["创建","收藏","订阅"]

  async aboutToAppear(){
    let screenHeight = display.getDefaultDisplaySync().height
    this.tabsHeight = this.getUIContext().px2vp(screenHeight)-50-this.topStatusBarHeight-this.bottomBarHeight
    if(this.tabsHeight<=0){
      this.tabsHeight = this.tempTabsHeight
    }
    this.getPlayLists()
  }

  @State @Watch('getPlayLists') isUpdateUI:boolean = false

  @State isWebDone:boolean = true
  private async getPlayLists(){
    this.isWebDone = false
    try {
      console.log("正在获取个人歌单")
      let response = await getUserPlayList({id:globalThis.userInfo.id})
      if (response.success) {
        console.log('完整响应:', JSON.stringify(response.data));

        this.createdPlayLists = []
        this.collectedPlayLists = []
        this.subscribedPlayLists = []

        let createList:Array<object> = response.data['isCreate']
        let collectList:Array<object> = response.data['isCollect']
        let subscribeList:Array<object> = response.data['isSubcsribe']

        for(let i=0;i<createList.length;i++){
          let item = createList[i]
          this.createdPlayLists.push({
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
        for(let i=0;i<collectList.length;i++){
          let item = collectList[i]
          this.collectedPlayLists.push({
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
        for(let i=0;i<subscribeList.length;i++){
          let item = subscribeList[i]
          this.subscribedPlayLists.push({
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

  build(){
    Stack(){
      Stack(){
        Scroll(this.outScrollerObj){
          Column(){
            personInformation({
              h:this.currentPictureHeight,
              perInformation : this.perInformation
            });

            Tabs({barPosition: BarPosition.Start}){
              TabContent(){
                if(this.isWebDone){
                  content({playLists:this.createdPlayLists,playListsType:"local",isUpdateUI:this.isUpdateUI})
                }
              }
              .tabBar(SubTabBarStyle.of("创建")
                .indicator({
                  color: $r("app.color.themeColor"), // 下划线颜色
                  height: 3, // 下划线高度
                  width: 16, // 下划线宽度 b
                  borderRadius: 4, // 下划线圆角半径
                  marginTop: 4 // 下划线与文字间距
                })
                .labelStyle({font:{weight:this.selectIndex==0?FontWeight.Bold:FontWeight.Regular,size:18},
                  selectedColor:this.selectIndex==0?$r("app.color.softBlack"):$r("app.color.noteColor"),
                  unselectedColor:this.selectIndex==0?$r("app.color.softBlack"):$r("app.color.noteColor")})
                .padding(0))
              TabContent(){
                if(this.isWebDone){
                  content({playLists:this.collectedPlayLists,playListsType:"local",isUpdateUI:this.isUpdateUI})
                }
              }
              .tabBar(SubTabBarStyle.of("收藏")
                .indicator({
                  color: $r("app.color.themeColor"), // 下划线颜色
                  height: 3, // 下划线高度
                  width: 16, // 下划线宽度 b
                  borderRadius: 4, // 下划线圆角半径
                  marginTop: 4 // 下划线与文字间距
                })
                .labelStyle({font:{weight:this.selectIndex==1?FontWeight.Bold:FontWeight.Regular,size:18},
                  selectedColor:this.selectIndex==1?$r("app.color.softBlack"):$r("app.color.noteColor"),
                  unselectedColor:this.selectIndex==1?$r("app.color.softBlack"):$r("app.color.noteColor")})
                .padding(0))
              TabContent(){
                if(this.isWebDone){
                  content({playLists:this.subscribedPlayLists,playListsType:"web",isUpdateUI:this.isUpdateUI})
                }
              }
              .tabBar(SubTabBarStyle.of("订阅")
                .indicator({
                  color: $r("app.color.themeColor"), // 下划线颜色
                  height: 3, // 下划线高度
                  width: 16, // 下划线宽度
                  borderRadius: 4, // 下划线圆角半径
                  marginTop: 4 // 下划线与文字间距
                })
                .labelStyle({font:{weight:this.selectIndex==2?FontWeight.Bold:FontWeight.Regular,size:18},
                  selectedColor:this.selectIndex==2?$r("app.color.softBlack"):$r("app.color.noteColor"),
                  unselectedColor:this.selectIndex==2?$r("app.color.softBlack"):$r("app.color.noteColor")})
                .padding(0))
            }
            .height(this.tabsHeight)
            .width("100%")
            .barHeight(this.tabBarHeight)
            .onContentWillChange((currentIndex,comingIndex)=>{
              this.selectIndex = comingIndex

              return true
            })
          }
        }
        .height("100%")
        .width("100%")
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .onScroll(()=> {
          this.topBarOpacity = (this.outScrollerObj.currentOffset().yOffset) / 150
          console.log(this.topBarOpacity.toString())
          if(this.topBarOpacity >= 0.95){
            this.topBarIsChange = true;
          }
          else {
            this.topBarIsChange = false;
          }
        })
        .onTouch((event)=>{
          let action:TouchType = event.type
          let y:number = event.touches[0].y
          if(action == TouchType.Down){
            this.touchStartY = y
          }
          else if(action == TouchType.Move){
            let DeltaY:number = y - this.touchStartY
            if(this.outScrollerObj.currentOffset().yOffset<=0 && DeltaY>0){
              let stretch = DeltaY * this.fiction
              this.currentPictureHeight = Math.min(this.pictureHeight + stretch,this.maxPictureHeight)
            }
          }
          else if(action == TouchType.Up || action == TouchType.Cancel){
            if(this.currentPictureHeight != this.pictureHeight){
              this.getUIContext()?.animateTo({
                duration: 300,
                curve: Curve.ExtremeDeceleration
              }, () => {
                this.currentPictureHeight = this.pictureHeight;
              });
            }
          }
        })

        topBarbackground({topOpacity:this.topBarOpacity,topStatusBarHeight:this.topStatusBarHeight})

        topBar({isChange: this.topBarIsChange,
          perInformation : this.perInformation,
          topStatusBarHeight:this.topStatusBarHeight,
          isShowSideSheet:this.isShowSideSheet,
          sideBoxShadowOpacity:this.sideBoxShadowOpacity})

      }
      .height("100%")
      .width("100%")
      .alignContent(Alignment.Top)

      BottomMusicPlayBar()
        .margin({bottom:12})
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Bottom)
  }
}
//内容组件
@Component
struct content{
  ScrollerObj: Scroller = new Scroller()
  @Prop playLists:PlayList[] = []
  @Prop playListsType:"web"|"local"
  @Link isUpdateUI:boolean

  build(){
    Scroll(this.ScrollerObj){
      Column(){
        Column(){
          ForEach(this.playLists,(item:PlayList,index:number)=>{
            PlayListItem({
              playList:item,
              intro:`歌单 · ${item.songCount}首 · ${item.author}`,
              playListsType:this.playListsType,
              isUpdateUI:this.isUpdateUI
            })

          },(item:number)=>item.toString())
        }
      }
    }
    .width("100%")
    .height('100%')
    .align(Alignment.TopStart)
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }
}

@Component
struct personInformation {
  @Builder
  personCount(title:string,count:number){
    Row({space:2}){
      Text(`${count}`)
        .fontSize(15)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
      Text(`${title}`)
        .fontSize(13)
        .fontColor("#dbdbdb")
        .fontWeight(FontWeight.Normal)
    }
    .height("100%")
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
  @Builder
  functBlock(title:string,icon:Resource){
    Stack(){
      Column()
        .height("100%")
        .width("100%")
        .backgroundColor(Color.White)
        .opacity(0.15)
        .borderRadius(5)
      Row({space:5}){
        Image(icon)
          .height(20)
          .width(20)
          .objectFit(ImageFit.Contain)
          .fillColor("#FFE3E3E3")
        Text(`${title}`)
          .fontSize(13)
          .fontColor("#DBDBDB")
          .fontWeight(FontWeight.Normal)
      }
      .height("100%")
      .width("100%")
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .height("100%")
    .width(70)
  }
  @Link perInformation : UserInformation;
  @Prop h: number = 300;
  build(){
    Stack(){
      Image(this.perInformation.coverPicture?this.perInformation.coverPicture:$r("app.media.tempPersonalCover"))
        .height("100%")
        .width("100%")
        .objectFit(ImageFit.Cover)
      Column(){
        Blank();
        Column(){
          Image(this.perInformation.avatar?this.perInformation.avatar:$r("app.media.tempAvatar"))
            .objectFit(ImageFit.Cover)
            .height(90)
            .width(90)
            .borderRadius(45)
            .borderColor(Color.White)
            .borderWidth(2)
            .margin({top:5})
          Row({space:5}){
            Text(`${this.perInformation.name}`)
              .fontSize(22)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            Image(this.perInformation.sex==0?$r("app.media.femaleIcon"):$r("app.media.maleIcon"))
              .height(15)
              .width(15)
              .objectFit(ImageFit.Contain)
              .fillColor(this.perInformation.sex==0?0xfc88b7:0x59b5e6)
          }
          .height(40)
          .width("100%")
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({top:10})

          Row({space:15}){
            this.personCount("关注",this.perInformation.followCount)
            this.personCount("粉丝",this.perInformation.fans)
            this.personCount("小时",this.perInformation.hours)
          }
          .height(30)
          .width("100%")
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({top:10})

          Row({space:30}){
            this.functBlock("最近",$r("app.media.clockIcon"))
            this.functBlock("本地",$r("app.media.downloadIcon"))
          }
          .height(35)
          .width("100%")
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({top:7})
        }
        .height(245)
        .width("100%")
      }
      .height("100%")
      .width("100%")
    }
    .width("100%")
    .height(this.h)
    .borderRadius(5)

  }
}

@Component
struct topBar {
  @Link perInformation : UserInformation;
  @Link isShowSideSheet:boolean
  @Link sideBoxShadowOpacity:number
  @Prop isChange: boolean = false;
  @Prop topStatusBarHeight:number
  build(){
    Stack(){
      if(this.isChange == true){
        Row({space:5}){
          Image(this.perInformation.avatar?this.perInformation.avatar:$r("app.media.tempAvatar"))
            .objectFit(ImageFit.Cover)
            .height(35)
            .width(35)
            .borderRadius(17.5)
          Text(`${this.perInformation.name}`)
            .fontSize(15)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Normal)
        }
        .height("100%")
        .width("100%")
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }

      Row({space:12}){
        Image($r("app.media.menuIcon"))
          .height(25)
          .width(25)
          .fillColor(this.isChange == true ? Color.Black : Color.White)
          .onClick(()=>{
            animateTo({ duration: 200}, () => {
              this.isShowSideSheet = true
              this.sideBoxShadowOpacity = 0.5
            })
          })
        Blank()

        Image($r("app.media.searchIcon"))
          .height(25)
          .width(25)
          .fillColor(this.isChange == true ? Color.Black : Color.White)
          .onClick(()=>{
            router.pushUrl({url:"pages/SearchQuery"})
          })
        // Image($r("app.media.detailsIcon"))
        //   .height(25)
        //   .width(25)
        //   .fillColor(this.isChange == true ? Color.Black : Color.White)
      }
      .width('100%')
      .height('100%')
    }
    .height(50+this.topStatusBarHeight)
    .width("100%")
    .padding({top:10+this.topStatusBarHeight,bottom:10,left:10,right:10})
  }
}

@Component
struct topBarbackground {
  @Prop topOpacity: number = 0;
  @Prop topStatusBarHeight:number
  build(){
    Row(){}
    .width("100%")
    .height(50+this.topStatusBarHeight)
    .padding({top:10+this.topStatusBarHeight})
    .backgroundColor(Color.White)
    .opacity(this.topOpacity)
  }
}

@Component
struct PlayListItem{
  @Prop playList:PlayList
  @Prop intro:string
  @Prop playListsType:"web"|"local"
  @State isShowSheet:boolean = false
  @Link isUpdateUI:boolean

  build() {
    Row(){
      Image(this.playList.coverPicture?this.playList.coverPicture:$r("app.media.tempPlayListCover"))
        .width(50)
        .height(50)
        .borderRadius(4)
      Column({space:8}){
        Text(this.playList.name)
          .fontSize(15)
          .fontColor($r("app.color.softBlack"))
          .fontWeight(FontWeight.Medium)
        Text(this.intro)
          .fontSize(12)
          .fontColor($r("app.color.noteColor"))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({left:8,right:8})
      Image($r("app.media.detailsIcon"))
        .width(24)
        .height(24)
        .fillColor(0x535564)
        .bindSheet(
          $$this.isShowSheet,
          this.detailsSheet(),
          {
            detents: ['50%'],
            showClose: false,
            dragBar: true,
            title: {title:""},
            backgroundColor:Color.White
          })
        .onClick(()=>{
          this.isShowSheet = true
        })
    }
    .width('100%')
    .padding({top:6,bottom:6,left:12,right:12})
    .onClick(()=>{
      router.pushUrl({
        url: "pages/PersonalPlayList",
        params: {playList:this.playList,playListType:this.playListsType}
      })
    })
  }

  @State inputPlayListName:string = ""
  @State isShowNewPlayListSheet:boolean = false
  @State isWebDone:boolean = true

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
          Image($r("app.media.addToSongListIcon"))
            .width(20)
            .height(20)
            .fillColor($r("app.color.softBlack"))
          Text("新建歌单")
            .fontSize(16)
            .fontColor($r("app.color.softBlack"))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
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

        Row({space:16}){
          Image($r("app.media.binIcon"))
            .width(20)
            .height(20)
            .scale({x:1.5,y:1.5})
            .fillColor($r("app.color.softBlack"))
          Text("删除歌单")
            .fontSize(16)
            .fontColor($r("app.color.softBlack"))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .onClick(()=>{
          this.deletePlayList()
        })
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .justifyContent(FlexAlign.Start)
    }
  }

  private async deletePlayList(){
    await deletePlayList({playListId:this.playList.id})
    this.isShowSheet = false
    this.isWebDone = false
    this.isUpdateUI = !this.isUpdateUI
  }

  private async createPlayList(userId:number,name:string){
    await createPlayList({id:userId,name:name})
    this.isShowNewPlayListSheet = false
    this.isWebDone = false
    this.isUpdateUI = !this.isUpdateUI
  }

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
}


