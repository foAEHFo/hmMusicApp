import { router } from "@kit.ArkUI"

@Component
export struct SearchBar{
  @Link searchQuery:string
  @State isInputting:boolean = false
  @State inputEnabled:boolean = true

  public clickCallBack:()=>void = ()=>{}

  private textInputController:TextInputController = new TextInputController()

  build() {

    Row(){
      Image($r("app.media.searchIcon"))
        .width(20)
        .height(20)
        .fillColor(0x646673)
      TextInput({controller:this.textInputController,text:this.searchQuery})
        .height('100%')
        .layoutWeight(1)
        .padding(5)
        .fontColor($r("app.color.softBlack"))
        .backgroundColor(0xe8e9ed)
        .placeholderColor(0x7a7c89)
        .onChange((value:string)=>{
          this.isInputting = value.length!=0
          this.searchQuery = value
        })
        .enabled(this.inputEnabled)

      Image($r("app.media.cancelIcon"))
        .width(20)
        .height(20)
        .fillColor(0xb0b3ba)
        .visibility(this.isInputting?Visibility.Visible:Visibility.Hidden)
        .onClick(()=>{
          if(this.inputEnabled){
            this.textInputController.deleteText()
          }
          else{
            this.clickCallBack()
          }
        })
    }
    .layoutWeight(1)
    .height(40)
    .padding({left:10,right:10})
    .backgroundColor(0xe8e9ed)
    .borderRadius(50)
    .onClick(()=>{
      this.clickCallBack()
    })
  }
}
