import {UserInformation, UserLabel} from "./interface/Personal"
import {display, router } from '@kit.ArkUI';
import {PlayList} from './interface/Song'
import { tempPlayListList } from "./model/TempData";
import { BottomMusicPlayBar } from "./model/BottomMusicPlayBar";
import { getUserInfo, getUserPlayList } from "./http/api";

@Entry
@Component
export struct PersonalPage {
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

  @State perInformation:UserInformation = {
    id:0,
    avatar: "app.media.tempAvatar",
    coverPicture: "app.media.tempPersonalCover",
    name:"20的opp",
    sex: 1,
    followCount:11,
    fans:3,
    hours:164,
    isFollowed:false
  }

  tabList:string[] = ["创建","收藏","订阅"]

  async aboutToAppear(){
    let screenHeight = display.getDefaultDisplaySync().height
    this.tabsHeight = this.getUIContext().px2vp(screenHeight)-50-this.topStatusBarHeight-this.bottomBarHeight
    if(this.tabsHeight<=0){
      this.tabsHeight = this.tempTabsHeight
    }

    let params = router.getParams() as Record<string, UserLabel>
    if(params){
      let userLabel = params['userLabel'] as UserLabel
      await this.getUserPlayList(userLabel)
    }
  }

  @State isWebDone:boolean = false

  private async getUserPlayList(userLabel:UserLabel){
    try {
      console.log("正在获取用户信息")

      let response = await getUserInfo({id:userLabel.id})
      if (response.success) {
        console.log('完整响应:', JSON.stringify(response.data));
        let userInfo:object = response.data['userInfo']
        let playLists:object = response.data['playLists']

        this.perInformation = {
          id:userInfo['id'],
          avatar: userInfo['headPicture'],
          coverPicture: userInfo['coverPicture'],
          name:userInfo['username'],
          sex: userInfo['sex'],
          followCount:userInfo['followCount'],
          fans:userInfo['fans'],
          hours:userInfo['hours'],
          isFollowed:response.data['isLove']
        }

        let newCreatedPlayLists:PlayList[] = []
        for(let i=0;i<playLists['Create'].length;i++){
          let item:object = playLists['Create'][i]
          newCreatedPlayLists.push({
            id:item['id'],
            name: item['playListName'],
            author: userLabel,
            coverPicture: item['coverPicture'],
            playCount: item['playCount'],
            shareCount: 0,
            commentCount: 0,
            saveCount: 0,
            intro: item['description'],
            songList: [],
            songCount: item['songCount'],
            isSave:false
          } as PlayList)
        }

        let newCollectedPlayLists:PlayList[] = []
        for(let i=0;i<playLists['Collect'].length;i++){
          let item:object = playLists['Collect'][i]
          newCollectedPlayLists.push({
            id:item['id'],
            name: item['playListName'],
            author: userLabel,
            coverPicture: item['coverPicture'],
            playCount: item['playCount'],
            shareCount: 0,
            commentCount: 0,
            saveCount: 0,
            intro: item['description'],
            songList: [],
            songCount: item['songCount'],
            isSave:false
          } as PlayList)
        }

        let newSubscribePlayLists:PlayList[] = []
        for(let i=0;i<playLists['Subcsribe'].length;i++){
          let item:object = playLists['Subcsribe'][i]
          newSubscribePlayLists.push({
            id:item['id'],
            name: item['playListName'],
            author: userLabel,
            coverPicture: item['coverPicture'],
            playCount: item['playCount'],
            shareCount: 0,
            commentCount: 0,
            saveCount: 0,
            intro: item['description'],
            songList: [],
            songCount: item['songCount'],
            isSave:false
          } as PlayList)
        }

        this.createdPlayLists = newCreatedPlayLists
        this.collectedPlayLists = newCollectedPlayLists
        this.subscribedPlayLists = newSubscribePlayLists

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
                content({createdPlayLists:this.createdPlayLists,collectedPlayLists:this.collectedPlayLists,subscribedPlayLists:this.subscribedPlayLists})
              }
              .tabBar(SubTabBarStyle.of("音乐")
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

        topBar({isChange: this.topBarIsChange,perInformation : this.perInformation,topStatusBarHeight:this.topStatusBarHeight})

      }
      .height("100%")
      .width("100%")
      .alignContent(Alignment.Top)

      BottomMusicPlayBar()
        .margin({bottom:24})
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
  @State createdPlayLists:PlayList[] = []
  @State collectedPlayLists:PlayList[] = []
  @State subscribedPlayLists:PlayList[] = []

  build(){
    Scroll(this.ScrollerObj){
      Column({space:36}){
        Column(){
          Text(`创建的歌单(${this.createdPlayLists.length})`)
            .width('100%')
            .fontSize(14)
            .fontColor($r("app.color.softBlack"))
            .margin({bottom:12})
            .padding({left:12})

          PlayListItem({
            playList:{
              id:0,
              name:"我喜欢的音乐",
              coverPicture:"",
              author:{
                'id':0,
                'name':"",
                'avatar':""
              },
              playCount: 0,
              shareCount: 0,
              commentCount: 0,
              saveCount: 0,
              intro: "",
              songList: [],
              songCount:0,
              isSave:false
            },
            intro:`歌单 · 0首`
          })
          ForEach(this.createdPlayLists,(item:PlayList,index:number)=>{
            PlayListItem({
              playList:item,
              intro:`歌单 · ${item.songCount}首 · ${item.author.name}`
            })

          },(item:number)=>item.toString())
        }

        Column(){
          Text(`收藏的歌单(${this.collectedPlayLists.length})`)
            .width('100%')
            .fontSize(14)
            .fontColor($r("app.color.softBlack"))
            .margin({bottom:12})
            .padding({left:12})

          ForEach(this.collectedPlayLists,(item:PlayList,index:number)=>{
            PlayListItem({
              playList:item,
              intro:`歌单 · ${item.songCount}首 · ${item.author.name}`
            })

          },(item:number)=>item.toString())
        }

        Blank()
          .height(64)
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

  @Link perInformation : UserInformation;
  @Prop h: number = 300;
  build(){
    Stack(){
      Image($r(this.perInformation.coverPicture))
        .height("100%")
        .width("100%")
        .objectFit(ImageFit.Cover)
      Column(){
        Blank();
        Column(){
          Image($r(this.perInformation.avatar))
            .objectFit(ImageFit.Cover)
            .height(90)
            .width(90)
            .borderRadius(45)
            .borderColor(Color.White)
            .borderWidth(2)
            .margin({top:5})
          Row({space:10}){
            Text(`${this.perInformation.name}`)
              .fontSize(22)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            Image($r(`app.media.${this.perInformation.sex}`))
              .height(20)
              .width(20)
              .objectFit(ImageFit.Contain)
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

          Row(){
            Button(this.perInformation.isFollowed?"已关注":"+ 关注")
              .backgroundColor(this.perInformation.isFollowed?"rgba(255,255,255,0.2)":Color.White)
              .fontColor(this.perInformation.isFollowed?"rgba(255,255,255,0.5)":$r("app.color.softBlack"))
              .onClick(()=>{
                this.perInformation.isFollowed = !this.perInformation.isFollowed
              })
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
  @Prop isChange: boolean = false;
  @Prop topStatusBarHeight:number
  build(){
    Stack(){
      if(this.isChange == true){
        Row({space:5}){
          Image(this.perInformation.avatar)
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
        Image($r("app.media.leftArrow"))
          .height(30)
          .width(30)
          .fillColor(this.isChange == true ? Color.Black : Color.White)
          .onClick(()=>{
            router.back()
          })
        Blank()
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

  build() {
    Row({space:4}){
      Image($r("app.media.tempPlayListCover"))
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
    }
    .width('100%')
    .padding({top:6,bottom:6,left:12,right:12})
    .onClick(()=>{
      router.pushUrl({
        url: "pages/PersonalPlayList",
        params: {playList:this.playList,playListType:"local"}
      })
    })
  }
}


