@Component
export struct SearchHistory{
  @Prop historyList: string[]
  public itemClickCallBack:(history:string)=>void = ()=>{}
  public binClickCallBack:()=>void = ()=>{}

  @State isExpanded:boolean = false

  build() {
    Column({space:12}){
      Row(){
        Text('搜索记录')
          .fontSize(14)
          .fontColor($r("app.color.softBlack"))
        Blank()
        Image($r("app.media.binIcon"))
          .height(25)
          .width(25)
          .onClick(()=>{
            this.binClickCallBack()
          })
      }
      .width('100%')
      .height(20)
      Stack(){
        Flex({direction:FlexDirection.Row,wrap:FlexWrap.Wrap,alignItems:ItemAlign.Center}){
          ForEach(this.historyList,(item:string)=>{
            Text(item)
              .height(35)
              .margin({right:8,bottom:8})
              .padding({top:8,bottom:8,left:16,right:16})
              .maxLines(1)
              .constraintSize({maxWidth:140})
              .textOverflow({overflow:TextOverflow.Ellipsis})
              .fontSize(14)
              .fontColor(0x515362)
              .border({width:1,color:0xdfe2e7})
              .borderRadius(20)
              .onClick(()=>{
                this.itemClickCallBack(item)
              })
          })
          Image($r('app.media.leftArrow'))
            .fillColor(0x999ca5)
            .rotate({angle:90})
            .width(30)
            .height(30)
            .padding(7)
            .border({ width: 1, color: 0xdfe2e7 })
            .borderRadius(20)
            .visibility(this.isExpanded ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.isExpanded = !this.isExpanded
            })
        }
        .width('100%')

        Row(){}
        .width(80)
        .height(35)
        .visibility(this.isExpanded?Visibility.None:Visibility.Visible)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [
            ['rgba(243,247,250,0)', 0.0],
            ['rgba(243,247,250,1)', 0.5]
          ]
        })

        Image($r('app.media.leftArrow'))
          .fillColor(0x999ca5)
          .rotate({angle:-90})
          .width(30)
          .height(30)
          .padding(7)
          .border({ width: 1, color: 0xdfe2e7 })
          .borderRadius(20)
          .visibility(this.isExpanded ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            console.log("2222")
            this.isExpanded = !this.isExpanded
          })
      }
      .width('100%')
      .height(this.isExpanded? 'auto': 35)
      .clip(!this.isExpanded)
      .alignContent(Alignment.TopEnd)
    }
  }
}
