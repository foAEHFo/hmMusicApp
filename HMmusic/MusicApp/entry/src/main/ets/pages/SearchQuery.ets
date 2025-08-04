import {SearchBar} from "./model/SearchBar"
import {SearchHistory} from "./model/SearchHistory"
import { router } from "@kit.ArkUI"
import { BottomMusicPlayBar } from "./model/BottomMusicPlayBar"
import preferencesUtil from "./utils/tokenUtil"

@Entry
@Component
struct SearchQueryPage{
  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  @State query:string = ""
  @State searchHistory:string[] = []

  async onPageShow() {
    try {
      const history = (await preferencesUtil.get("searchHistoryStore", "history", "")) as string
      this.searchHistory = JSON.parse(history);
    } catch (error) {
      console.error("历史记录解析失败:", error);
      this.searchHistory = [];
    }
  }

  private saveHistory(queryText: string) {
    if (!queryText.trim()) return;

    // 去重处理（不区分大小写）
    const normalizedQuery = queryText.toLowerCase();
    const newHistory = [
      queryText,
      ...this.searchHistory.filter(item =>
      item.toLowerCase() !== normalizedQuery
      )
    ].slice(0, 10); // 限制10条

    preferencesUtil.set("searchHistoryStore", "history", JSON.stringify(newHistory))
  }

  private search(query:string) {
    if (!query.trim()) return;
    this.saveHistory(query);
    router.pushUrl({
      url: 'pages/SearchResults',
      params: { searchQuery: query }
    });
  }

  build() {
    Stack(){
      Column({space:16}){
        Row(){
          Image($r("app.media.leftArrow"))
            .width(35)
            .height(35)
            .fillColor(0x0e0f23)
            .onClick(()=>{
              router.back()
            })
          Row(){
            SearchBar({searchQuery:this.query})
          }
          .layoutWeight(1)
          .margin({left:4,right:12})
          Text("搜索")
            .fontSize(16)
            .fontColor($r("app.color.softBlack"))
            .onClick(()=>{
              console.log(this.query)
              this.search(this.query)
            })
        }
        .width('100%')
        .height($r("app.float.top_bar_height"))
        SearchHistory({
          historyList:this.searchHistory,
          itemClickCallBack:(history:string)=>{this.search(history)},
          binClickCallBack:()=>{
            this.searchHistory = []
            preferencesUtil.set("searchHistoryStore", "history", JSON.stringify([]))
          }
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

  }
}