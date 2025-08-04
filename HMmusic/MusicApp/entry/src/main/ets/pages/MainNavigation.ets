import {PersonalPage} from "./Personal"
import {RecommendPage} from "./Recommend"
import { router } from "@kit.ArkUI"

@Entry
@Component
struct MainNavigation{
  @State selectIndex:number = 0
  @State tabBarHeight:number = 50

  @State isShowSideSheet:boolean = false
  @State isUIUpdate:boolean = false

  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  @Builder TabBuilder(index:number){
    Column({space:4}){
      if(index==0){
        Image($r("app.media.recommendPageIcon"))
          .width(20)
          .height(20)
          .fillColor(this.selectIndex==index?$r("app.color.softBlack"):0x828490)
        Text("推荐")
          .fontSize(10)
          .fontColor(this.selectIndex==index?$r("app.color.softBlack"):0x828490)
      }
      else if(index==1){
        Image($r("app.media.personalPageIcon"))
          .width(20)
          .height(20)
          .fillColor(this.selectIndex==index?$r("app.color.softBlack"):0x828490)
        Text("我的")
          .fontSize(10)
          .fontColor(this.selectIndex==index?$r("app.color.softBlack"):0x828490)
      }
    }
    .justifyContent(FlexAlign.Center)
  }

  @State sideBoxShadowOpacity:number = 0

  onPageShow(){
    this.isUIUpdate = !this.isUIUpdate
  }

  build() {
    SideBarContainer(SideBarContainerType.Overlay){
      this.sideSheet()

      Stack(){
        Tabs({barPosition:BarPosition.End}){
          TabContent() {
            RecommendPage({isShowSideSheet:this.isShowSideSheet,sideBoxShadowOpacity:this.sideBoxShadowOpacity})
          }
          .tabBar(this.TabBuilder(0))
          TabContent() {
            PersonalPage({bottomBarHeight:this.tabBarHeight,isShowSideSheet:this.isShowSideSheet,sideBoxShadowOpacity:this.sideBoxShadowOpacity,isUIUpdate:this.isUIUpdate})
          }
          .tabBar(this.TabBuilder(1))
        }
        .width("100%")
        .height('100%')
        .barHeight(this.tabBarHeight)
        .onContentWillChange((currentIndex,comingIndex)=>{
          this.selectIndex = comingIndex
          return true
        })
        .backgroundColor($r("app.color.backgroundWhite"))
        .animationMode(AnimationMode.NO_ANIMATION)

        Row(){}
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .opacity(this.sideBoxShadowOpacity)
        .zIndex(this.isShowSideSheet?1:-1)
      }
    }
    .showSideBar($$this.isShowSideSheet)
    .showControlButton(false)
    .onClick(() => {
      animateTo({ duration: 200}, () => {
        this.isShowSideSheet = false
        this.sideBoxShadowOpacity = 0
      })
    })
  }
  @Builder
  sideSheet(){
    Column({space:32}){
      Row({space:16}){
        Image(globalThis.userInfo.headPicture?globalThis.userInfo.headPicture:$r("app.media.tempAvatar"))
          .width(30)
          .height(30)
          .borderRadius(20)
        Text(globalThis.userInfo.name)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column({space:6}){
       Row({space:12}){
         Image($r("app.media.changeAvatarIcon"))
           .width(20)
           .height(20)
           .scale({x:1.2,y:1.2})
           .fillColor($r("app.color.softBlack"))
           .objectFit(ImageFit.Contain)
         Text("切换头像")
       }
       .width('100%')
       .padding(15)

        Row(){}
        .width('100%')
        .height(1)
        .backgroundColor($r("app.color.backgroundWhite"))

        Row({space:12}){
          Image($r("app.media.changeCoverIcon"))
            .width(20)
            .height(20)
            .fillColor($r("app.color.softBlack"))
            .objectFit(ImageFit.Contain)
          Text("切换封面")
        }
        .width('100%')
        .padding(15)

        Row(){}
        .width('100%')
        .height(1)
        .backgroundColor($r("app.color.backgroundWhite"))

        Row({space:12}){
          Image($r("app.media.lockIcon"))
            .width(20)
            .height(20)
            .fillColor($r("app.color.softBlack"))
            .objectFit(ImageFit.Contain)
          Text("账号密码")
        }
        .width('100%')
        .padding(15)
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(10)


      Blank()

      Text("退出登录")
        .width('100%')
        .height(40)
        .backgroundColor(Color.White)
        .fontColor($r("app.color.softBlack"))
        .textAlign(TextAlign.Center)
        .borderRadius(10)
        .onClick(()=>{
          router.replaceUrl({url:"pages/Login"})
        })
    }
    .width('100%')
    .height('100%')
    .padding({top:this.topStatusBarHeight+24,bottom:24,left:12,right:12})
    .backgroundColor($r("app.color.backgroundWhite"))
  }
}