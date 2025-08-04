import {TopRecommendBlockItem} from "../interface/Component"
import { router } from "@kit.ArkUI";
import { PlayList } from "../interface/Song";

@Entry
@Component
export struct TopRecommendBlockList {
  @State blockList: TopRecommendBlockItem[] = [
    {imageId:1,title:"每日推荐",intro:"今日限定好歌推荐"},
    {imageId:2,title:"热歌榜",intro:"云音乐官方top排行榜"},
    // {imageId:3,title:"心动模式",intro:"红心歌曲和相似推荐"},
    {imageId:4,title:"私人雷达",intro:"你爱的歌值得反复聆听"},
    // {imageId:5,title:"漫游",intro:"多样频道无限畅听"},
    // {imageId:6,title:"相似歌曲",intro:"从你喜欢的歌听起"}
  ];

  build() {
    Column() {
      List({space:5}){
        ListItem(){
          TopRecommendBlock({block:this.blockList[0],type:"dailyRecommends"})
        }
        ListItem(){
          TopRecommendBlock({block:this.blockList[1],type:"hotSongs"})
        }
        ListItem(){
          TopRecommendBlock({block:this.blockList[2],type:"personalizedRadar"})
        }
      }
      .width("100%")
      .height(210)
      .backgroundColor(0xffffff)
      .padding(5)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    .width("100%")
  }
}

@Component
struct TopRecommendBlock {
  @Prop block: TopRecommendBlockItem;
  @Prop type:string

  build() {
    Stack({alignContent:Alignment.Bottom}){
      if(this.type=="dailyRecommends"){
        Image(globalThis.dailyRecommends.coverPicture)
          .width(150)
          .height(200)
          .borderRadius(5)
      }
      else{
        if(this.type=='hotSongs'){
          Image(globalThis.hotSongs.coverPicture)
            .width(150)
            .height(200)
            .borderRadius(5)
        }
        else{
          Image(globalThis.personalizedRadar.coverPicture)
            .width(150)
            .height(200)
            .borderRadius(5)
        }
      }
      Column(){}
      .height("20%")
      .width("100%")
      .backgroundBlurStyle(BlurStyle.Thin)
      .backdropBlur(10)
      .opacity(0.8)
      .backgroundImage(
        this.type=="dailyRecommends"?globalThis.dailyRecommends.coverPicture:(this.type=="hotSongs"?globalThis.hotSongs.coverPicture:globalThis.personalizedRadar.coverPicture),
        ImageRepeat.NoRepeat)
      .backgroundImagePosition(Alignment.Bottom)
      .borderRadius({topLeft:0,topRight:0,bottomLeft:5,bottomRight:5})

      Column(){
        Row(){
          if(this.block.title == "心动模式"){
            Image($r("app.media.HeartIcon"))
              .width("20%")
              .height("100%")
              .objectFit(ImageFit.Cover)
          }
          if(this.block.title == "每日推荐"){
            Image($r("app.media.calendarIcon"))
              .width("20%")
              .height("100%")
              .objectFit(ImageFit.Cover)
          }
          Text(this.block.title).fontSize(16).fontColor(Color.White).fontWeight(FontWeight.Bold)
            .height("100%").layoutWeight(1)
            .textAlign(TextAlign.Start)
            .padding({left: 5})
        }
        .height("15%")
        .width("100%")

        Blank();

        if(this.block.title == "每日推荐" || this.block.title == "热歌榜" || this.block.title == "私人雷达"){
          Row(){
            Blank()
            Image($r("app.media.playIcon"))
              .width(25)
              .height(25)
              .objectFit(ImageFit.Cover)
              .fillColor(Color.White)
          }
          .width("100%")
          .padding({bottom:10,right:7})
        }
        Text(this.block.intro)
          .fontSize(13)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .height("20%")
          .width("100%")
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .padding({left: 5})
      }.height("100%").width("100%").borderRadius(5)

    }
    .width(150)
    .height(200)
    .onClick(()=>{
      router.pushUrl({
        url: "pages/PersonalPlayList",
        params: { globalType:this.type ,playListType:"null"}
      })
    })
  }
}
