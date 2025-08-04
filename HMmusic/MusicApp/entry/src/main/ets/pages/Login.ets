import {login} from "./http/api"
import { router } from "@kit.ArkUI"
import preferencesUtil from "./utils/tokenUtil"
import {getRecommendList} from "./Initial"

@Entry
@Component
struct LoginPage{
  @State inputPhone:string = ""
  @State inputPassword:string = ""

  private async login(){
    try {
      console.log("正在登录")
      console.log(this.inputPhone)
      console.log(this.inputPassword)
      let response = await login({phoneNumber:this.inputPhone,password:this.inputPassword})
      if (response.success) {
        console.log('完整响应:', JSON.stringify(response.data));

        let data:object = response.data
        let userInfo:object = data["userInfo"]
        globalThis.userInfo = {
          id:userInfo["id"],
          headPicture:userInfo["headPicture"],
          coverPicture:userInfo["coverPicture"],
          name:userInfo["username"],
          sex:userInfo['sex'],
          followCount:userInfo['userInfo'],
          fans:userInfo['fans'],
          hours:userInfo['hours'],
          isFollowed:false
        }
        globalThis.token = data['token']

        preferencesUtil.set("userinfoStore", "token", data['token'])

        await getRecommendList()

        router.replace({url:"pages/MainNavigation"})
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
    Column(){
      Column(){
        Image($r("app.media.appIcon"))
          .width(100)
          .height(100)
          .borderRadius('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      Column({space:20}){
        Row(){
          TextInput({placeholder:"手机号"})
            .fontSize(18)
            // .fontWeight("bold")
            .backgroundColor(Color.White)
            .type(InputType.PhoneNumber)
            .onChange((value)=>{
              this.inputPhone = value
            })
        }
        .width('80%')
        .height(54)
        .padding({left:8,right:8})
        .backgroundColor(Color.White)
        .borderRadius(16)
        Row(){
          TextInput({placeholder:"密码"})
            .fontSize(18)
            // .fontWeight("bold")
            .backgroundColor(Color.White)
            .type(InputType.Password)
            .onChange((value)=>{
              this.inputPassword = value
            })
        }
        .width('80%')
        .height(54)
        .padding({left:8,right:8})
        .backgroundColor(Color.White)
        .borderRadius(16)

        Button("登录")
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight("bold")
          .width('80%')
          .height(50)
          .margin({top:64})
          .backgroundColor($r("app.color.themeColor"))
          .borderRadius('100%')
          .onClick(()=>{
            this.login()
          })
      }
      .width('100%')
      .layoutWeight(3)
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r("app.color.backgroundWhite"))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.backgroundWhite"))
  }
}