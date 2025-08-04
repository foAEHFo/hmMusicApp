import {Song,PlayState, PlayStateModel, LyricItem} from "./interface/Song"
import {tempSong, tempSong2, tempSong3} from "./model/TempData"
import {getAverageColor,getLighterColor,getDeeperColor,adjustToBrightnessThreshold} from "./method/Color"
import {mergeLyrics} from './method/Song'
import { common } from "@kit.AbilityKit"
import { display, LengthUnit, router } from '@kit.ArkUI';
import { emitter } from "@kit.BasicServicesKit"
import { EmitEventType } from "./event/type"
import { SearchToSongPlay } from "./interface/router"
import { downloadImage } from "./method/Http"

@Entry
@Component
struct SongPlayPage{
  @StorageProp('topStatusBarHeight') topStatusBarHeight:number = 0

  @State song:Song = tempSong
  @State title:string = "搜索"

  @State coverColor:string = "#183f73"
  @State recordStickX:number = 0

  private lyricScroller: Scroller = new Scroller();
  @State lyricItemsGap:number = 30

  @State showLyric:boolean = true
  @State isLyricShowAnimating:boolean = false //唱片和歌词界面正在切换
  @State lyricRecordOpacity:number = 0
  @State lyricItems:LyricItem[] = []
  @State lyricAreaHeight:number = 0
  @State lyricItemsHeight:number[] = []
  @State lyricItemsOffset:number[] = []
  @State lyricItemLoadCount:number = 0
  @State currentLyricIndex: number = -1;
  @State targetLyricIndex: number = -1;
  @State targetLyricFormatTime: string = "00:00"
  @State isUserScrolling: boolean = false
  @State isUserScrollDelaying:boolean = false

  @State isShowPlayList:boolean = false

  private playStateUpdateCallBack(){
    if(this.playState.currentPlayIndex==-1){
      return;
    }
    if(this.song.id!=this.playState.playList[this.playState.currentPlayIndex].id){
      this.song = this.playState.playList[this.playState.currentPlayIndex]
      this.lyricItemLoadCount = 0
      this.lyricItems = mergeLyrics(this.song.lyric,this.song.translateLyric)
      this.getCoverColor(this.song.coverPicture)
    }
    this.setRecordAnimation()
    this.updateLyricIndex()
  }

  @State @Watch('playStateUpdateCallBack') playState:PlayState = {
    currentTime: 0,
    isPlaying: false,
    playMode:'loop',
    playList:[tempSong],
    currentPlayIndex:0
  }

  @State slideBlockSize:number = 10
  @State trackThickness: number = 2.5;
  @State recordStickAngle:number = -10
  @State recordRotateAngle:number = 0

  startTrackThicknessAnimation(targetThickness: number) {
    animateTo({
      duration: 200,
      curve: Curve.EaseInOut
    }, () => {
      this.trackThickness = targetThickness;
    });
  }
  startSlideBlockSizeAnimation(targetSize: number) {
    animateTo({
      duration: 200,
      curve: Curve.EaseInOut
    }, () => {
      this.slideBlockSize = targetSize;
    });
  }
  startRecordStickAngleAnimation(targetAngle: number) {
    animateTo({
      duration: 300,
      curve: Curve.EaseInOut
    }, () => {
      this.recordStickAngle = targetAngle;
    });
  }
  setRecordAnimation(){
    if(this.playState.isPlaying){
      this.startRecordStickAngleAnimation(22)
      this.recordRotateAngle=360
    }
    else{
      this.startRecordStickAngleAnimation(-10)
      this.recordRotateAngle=0
    }
  }
  showLyricAnimation(){
    animateTo({
      duration: 200,
      curve: Curve.EaseInOut,
      onFinish: ()=>{
        this.isLyricShowAnimating = false
      }
    }, () => {
      this.lyricRecordOpacity = 1;
    });
  }
  hideLyricAnimation(){
    animateTo({
      duration: 200,
      curve: Curve.EaseInOut,
      onFinish: ()=>{
        this.isLyricShowAnimating = false
      }
    }, () => {
      this.lyricRecordOpacity = 0;
    });
  }

  // 格式化时间显示（秒转MM:SS）
  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 播放/暂停控制
  // private togglePlay() {
  //   console.log(globalThis.musicPlayer.player.state)
  //   if (globalThis.musicPlayer.isPlaying) {
  //     // 暂停
  //     globalThis.musicPlayer.pause()
  //   } else {
  //     // 播放
  //     if(globalThis.musicPlayer.isEmpty){
  //       globalThis.musicPlayer.replay()
  //     }
  //     else{
  //       globalThis.musicPlayer.play()
  //     }
  //   }
  // }

  async getCoverColor(imageUrl: string) {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const BRIGHTNESS_THRESHOLD = 200; // 亮度阈值（>200视为太亮）
    const DARKEN_FACTOR = 0.6; // RGB调暗比例

    try {
      const imageData: Uint8Array = await downloadImage(imageUrl);
      const color = await getAverageColor(context, imageData);

      const adjustColor = adjustToBrightnessThreshold(color,100)

      this.coverColor = `#${adjustColor.red.toString(16).padStart(2, '0')}${adjustColor.green.toString(16).padStart(2, '0')}${adjustColor.blue.toString(16).padStart(2, '0')}`;

    } catch (err) {
      console.error('处理失败', err);
    }
  }

  async aboutToAppear(){
    emitter.on({ eventId: EmitEventType.UPDATE_STATE }, (data) => {
      this.playState = new PlayStateModel(JSON.parse(data.data!.playStateStr))
    })

    if(globalThis.musicPlayer.isPlaying){
      this.recordStickAngle = 22
    }

    await globalThis.musicPlayer.updateUIState()

    this.lyricItems = mergeLyrics(this.song.lyric,this.song.translateLyric)
    this.lyricAreaHeight = this.getUIContext().px2vp(display.getDefaultDisplaySync().height)-257-this.topStatusBarHeight
  }

  private setLyricItemsOffsets(){
    this.lyricItemsOffset = [-8]; // 第一个歌词项默认在中心线（offset=0）
    const space = this.lyricItemsGap; // 歌词项间距（由List的space:16定义）

    for (let i = 0; i < this.lyricItemsHeight.length - 1; i++) {
      const currentHalf = this.lyricItemsHeight[i] / 2;
      const nextHalf = this.lyricItemsHeight[i + 1] / 2;
      // 累加：当前项下半部分 + 间距 + 下一项上半部分
      const centerDistance = currentHalf + space + nextHalf;
      this.lyricItemsOffset.push(this.lyricItemsOffset[i] + centerDistance);
    }
  }

  private getCurrentLyricIndexByOffset(): number {
    let offset = this.lyricScroller.currentOffset().yOffset
    if (this.lyricItemsHeight.length === 0) return -1;
    // 二分查找：找到第一个大于offset的阈值索引，其前一项即为中心项
    let low = 0, high = this.lyricItemsOffset.length - 1;
    while (low <= high) {
      const mid = Math.floor((low + high) / 2);
      if (this.lyricItemsOffset[mid] <= offset) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    // 边界处理：offset超出范围时返回首/尾项
    return Math.min(Math.max(low - 1, 0), this.lyricItemsHeight.length - 1);
  }

  private updateLyricIndex() {
    const currentTime = this.playState.currentTime;
    let low = 0;
    let high = this.lyricItems.length - 1;
    let newIndex = -1;

    while (low <= high) {
      const mid = Math.floor((low + high) / 2);
      if (this.lyricItems[mid].time <= currentTime) {
        newIndex = mid;  // 当前时间点匹配的歌词
        low = mid + 1;   // 继续向右查找更接近的
      } else {
        high = mid - 1;
      }
    }

    // 仅当索引变化时更新
    if (newIndex !== this.currentLyricIndex) {
      this.currentLyricIndex = newIndex;
      if(!this.isUserScrolling&&this.currentLyricIndex!=-1){
        this.scrollToCurrentLyric();
        this.targetLyricIndex = this.currentLyricIndex
        this.targetLyricFormatTime = this.formatTime(this.lyricItems[this.currentLyricIndex].time)
      }
    }
  }

  private getLyricItemHeight(index:number):number{
    let heightPx = this.getUIContext().getComponentUtils().getRectangleById(`lyricItem${index}`).size.height
    let heightVp = this.getUIContext().px2vp(heightPx)
    return heightVp
  }

  private getLyricItemY(index:number):number{
    let yPx = this.getUIContext().getComponentUtils().getRectangleById(`lyricItem${index}`).localOffset.y
    let yVp = this.getUIContext().px2vp(yPx)
    return yVp
  }

  private scrollToCurrentLyric() {
    console.log(this.lyricItems.length.toString())
    if(this.lyricItems.length==0){
      return;
    }

    if (this.currentLyricIndex >= 0) {
      let fontSizeOffset =  this.lyricItems[this.currentLyricIndex].translateText.length!=0? 8: 4
      let lyricItemHeight = this.lyricItemsHeight[this.currentLyricIndex]
      this.lyricScroller.scrollToIndex(
        this.currentLyricIndex+1,
        true,
        undefined,
        {extraOffset:{
          value:-this.lyricAreaHeight/2+
                lyricItemHeight/2+
                fontSizeOffset/2,
          unit:LengthUnit.VP}}
      );
    }
  }

  private scrollToLyric(index:number) {
    if (index >= 0) {
      let lyricItemHeight = this.lyricItemsHeight[index]
      this.lyricScroller.scrollToIndex(
        index+1,
        true,
        undefined,
        {extraOffset:{
          value:-this.lyricAreaHeight/2+
                lyricItemHeight/2,
          unit:LengthUnit.VP}}
      );
    }
  }

  private scrollTimeoutId: number = 0;
  private scrollDelayTimeoutId:number = 0;

  private clearScrollTimer() {
    if (this.scrollTimeoutId !== 0) {
      clearTimeout(this.scrollTimeoutId);
      this.scrollTimeoutId = 0;
    }
  }

  private clearScrollDelayTimer() {
    if (this.scrollDelayTimeoutId !== 0) {
      clearTimeout(this.scrollDelayTimeoutId);
      this.scrollDelayTimeoutId = 0;
    }
  }

  private jumpToTargetLyric() {
    if (this.targetLyricIndex >= 0 && this.targetLyricIndex < this.lyricItems.length) {
      const time = this.lyricItems[this.targetLyricIndex].time;
      globalThis.musicPlayer.seek(time);
      this.clearScrollTimer();
      this.isUserScrolling = false;
    }
  }

  build() {
    Column({space:8}){
      Stack(){
        //歌词
        Column(){
          Column({space:8}){
            Text(this.playState.playList[this.playState.currentPlayIndex].name)
              .width('75%')
              .fontSize(16)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
              .opacity(0.5)
              .textOverflow({overflow:TextOverflow.MARQUEE})
              .marqueeOptions({
                start:true,
                step:4,
                loop:-1,
                delay:1000
              })
            Text(`${this.playState.playList[this.playState.currentPlayIndex].singerList.map(singer=>singer.name).join('/')}`)
              .fontSize(14)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
              .opacity(0.3)
              .marqueeOptions({
                start:true,
                step:4,
                loop:-1,
                delay:1000
              })
            .width('50%')
          }
          .width('100%')
          .height(50)
          .justifyContent(FlexAlign.Center)

          Stack(){
            List({space:this.lyricItemsGap,scroller:this.lyricScroller}){
              ListItem()
                .height(this.lyricAreaHeight/2-24)
              ForEach(this.lyricItems,(item:LyricItem,index)=>{
                ListItem(){
                  Column({space:4}){
                    Text(item.text)
                      .fontSize(index == this.currentLyricIndex? 20: 16)
                      .fontColor(Color.White)
                      .opacity(index == this.currentLyricIndex? 0.8: 0.3)
                      .textAlign(TextAlign.Center)
                    Text(item.translateText)
                      .fontSize(index == this.currentLyricIndex? 18: 14)
                      .fontColor(Color.White)
                      .opacity(index == this.currentLyricIndex? 0.5: 0.3)
                      .visibility(item.translateText.length!=0?Visibility.Visible:Visibility.None)
                      .textAlign(TextAlign.Center)
                  }
                }
                .width('100%')
                .align(Alignment.Center)
                .id(`lyricItem${index}`)
                .onSizeChange((oldValue,newValue)=>{
                  this.lyricItemsHeight[index] = Number(newValue.height)
                  this.lyricItemLoadCount++
                  if(this.lyricItemLoadCount==this.lyricItems.length){
                    this.setLyricItemsOffsets()
                  }
                })
              })
              ListItem()
                .height(this.lyricAreaHeight/2-24)
            }
            .width('80%')
            .height('100%')
            .scrollBar(BarState.Off)
            .onScrollFrameBegin((offset: number) => {
              this.isUserScrolling = true;
              this.clearScrollTimer();
              this.scrollTimeoutId = setTimeout(() => {
                this.isUserScrolling = false;
                this.scrollToCurrentLyric()
              }, 4000);

              this.isUserScrollDelaying = true;
              this.clearScrollDelayTimer();
              this.scrollDelayTimeoutId = setTimeout(()=>{
                this.isUserScrollDelaying = false;
                this.scrollToLyric(this.getCurrentLyricIndexByOffset())
              },500)

              if (this.isUserScrolling) {
                this.targetLyricIndex = this.getCurrentLyricIndexByOffset()
                if (this.targetLyricIndex >= 0 && this.targetLyricIndex < this.lyricItems.length) {
                  this.targetLyricFormatTime = this.formatTime(this.lyricItems[this.targetLyricIndex].time)
                }
              }
              return { offsetRemain: offset };
            })
            .cachedCount(this.lyricItems.length)

            //中心指示线
            Stack(){
              Row({space:10}){
                Text(this.targetLyricFormatTime)
                  .width(35)
                  .fontSize(13)
                  .fontColor(Color.White)
                  .opacity(0.3)

                Blank()

                Image($r("app.media.playIcon"))
                  .width(20)
                  .height(20)
                  .objectFit(ImageFit.Contain)
                  .fillColor(Color.White)
                  .opacity(0.3)
              }
              .width('100%')

              Row()
                .width('70%')
                .height(0.5)
                .backgroundColor(Color.White)
                .opacity(0.15)
                .visibility((this.isUserScrolling&&this.isUserScrollDelaying)?Visibility.Visible:Visibility.Hidden)
            }
            .width('100%')
            .height(this.lyricItemsHeight[this.targetLyricIndex]+24)
            .padding({left:12,right:12})
            .backgroundColor((!this.isUserScrollDelaying&&this.isUserScrolling)?"rgba(255,255,255,0.1)":"rgba(255,255,255,0)")
            .borderRadius(8)
            .alignContent(Alignment.Center)
            .onClick(() => {
              this.jumpToTargetLyric(); // 点击跳转
            })
            .visibility(this.isUserScrolling?Visibility.Visible:Visibility.None)
          }
          .width('100%')
          .layoutWeight(1)
          .alignContent(Alignment.Center)

          Row(){
            Blank()
            Image(this.playState.playList[this.playState.currentPlayIndex].isLoved?$r("app.media.heartFillIcon"):$r("app.media.heartIcon"))
              .width(25)
              .height(25)
              .fillColor(Color.White)
              .opacity(0.5)
          }
          .width('100%')
          .padding({left:12,right:12})

        }
        .width('100%')
        .height('100%')
        .opacity(this.lyricRecordOpacity)
        .zIndex(this.showLyric?2:1)
        .onClick(()=>{
          if(!this.isLyricShowAnimating){
            this.showLyric = false
            this.isLyricShowAnimating = true
            this.hideLyricAnimation()
          }
        })

        //唱片
        Column(){
          Text(this.title)
            .height(50)
            .fontSize(16)
            .fontColor(Color.White)
            .opacity(0.5)

          Stack(){
            Circle()
              .width(300)
              .height(300)
              .fill(Color.White)
              .fillOpacity(0.1)
              .border({width:1,color:"rgba(255,255,255,0.2)",radius:300})
            Stack(){
              Image($r("app.media.recordBackground"))
                .width(270)
                .height(270)
              Image(this.song.coverPicture?this.song.coverPicture:$r("app.media.tempSongCover"))
                .width(180)
                .height(180)
                .borderRadius(220)
                .rotate({angle:this.recordRotateAngle})
                .animation({
                  duration: 36000,
                  curve: Curve.Linear,
                  iterations: -1, // 无限循环
                  playMode: PlayMode.Normal
                })
            }
            Image($r("app.media.recordStick"))
              .width(150)
              .translate({x:67,y:-160})
              .rotate({angle:this.recordStickAngle,centerX:this.getUIContext().px2vp(24),centerY:this.getUIContext().px2vp(24)})
          }
          .width('100%')
          .layoutWeight(1)

          Row(){
            Column({space:8}){
              Marquee({
                start:true,
                src:this.song.name,
                step:5,
                loop:-1
              })
                .fontColor(Color.White)
                .opacity(0.5)
                .fontSize(20)
                .width('100%')
              Row(){
                Marquee({
                  start:true,
                  src:`${this.song.singerList.map(singer=>singer.name).join('/')}`,
                  step:3,
                  loop:-1
                })
                  .layoutWeight(1)
                  .fontColor(Color.White)
                  .opacity(0.3)
                  .fontSize(14)
              }
              .width('60%')
            }
            .width('60%')
            .alignItems(HorizontalAlign.Start)
            Blank()
            Row(){
              Image($r("app.media.heartIcon"))
                .width(30)
                .height(30)
                .fillColor(Color.White)
                .opacity(0.5)
              Blank()
              Image($r("app.media.commentIconLine"))
                .width(25)
                .height(25)
                .fillColor(Color.White)
                .opacity(0.5)
            }
            .width(90)
          }
          .width('100%')
          .height(50)
          .padding({left:12,right:12})
        }
        .width('100%')
        .height('100%')
        .opacity(1-this.lyricRecordOpacity)
        .zIndex(this.showLyric?1:2)
        .onClick(()=>{
          if(!this.isLyricShowAnimating){
            this.showLyric = true
            this.isLyricShowAnimating = true
            this.showLyricAnimation()
          }
        })

        //顶部栏
        Row(){
          Image($r("app.media.leftArrow"))
            .width(30)
            .height(30)
            .rotate({angle:-90})
            .fillColor(Color.White)
            .opacity(0.5)
            .onClick(()=>{
              router.back()
            })

          Blank()

          Image($r("app.media.detailsIcon"))
            .width(30)
            .height(30)
            .fillColor(Color.White)
            .opacity(0.5)

        }
        .width('100%')
        .height($r("app.float.top_bar_height"))
        .zIndex(3)
      }
      .width('100%')
      .layoutWeight(1)
      .alignContent(Alignment.TopStart)

      Column({space:0}){
        Slider({
          value: this.playState.currentTime,
          min: 0,
          max: this.playState.playList[this.playState.currentPlayIndex].duration,
          step: 1,
          style: SliderStyle.OutSet // 进度条样式
        })
          .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
          .blockColor("rgba(255,255,255,0.8)") // 滑块颜色
          .blockSize({width:this.slideBlockSize,height:this.slideBlockSize})
          .trackColor("rgba(255,255,255,0.2)") // 背景轨道颜色
          .trackThickness(this.trackThickness)
          .selectedColor("rgba(255,255,255,0.5)") // 进度颜色
          .showSteps(false) // 隐藏步进点
          .minResponsiveDistance(0)
          .onChange((value: number,mode:SliderChangeMode) => { // 拖动事件
            if (mode === SliderChangeMode.Moving) {
              this.startTrackThicknessAnimation(7);
              this.startSlideBlockSizeAnimation(16);
            }
            else {
              if(mode === SliderChangeMode.End){
                globalThis.musicPlayer.seek(value)
              }
              this.startTrackThicknessAnimation(2.5);
              this.startSlideBlockSizeAnimation(10);
            }
          })
          .width('100%')
          .height(30)

        Row() {
          Text(this.formatTime(this.playState.currentTime))
            .fontColor("rgba(255,255,255,0.2)")

          Blank()

          Text(this.formatTime(this.playState.playList[this.playState.currentPlayIndex].duration))
            .fontColor("rgba(255,255,255,0.2)")
        }
        .width('100%')
      }
      .width('100%')
      .height(50)
      .padding({left:12,right:12})

      Row(){
        if(this.playState.playMode=='loop'){
          Image($r("app.media.LoopPlayIcon"))
            .width(30)
            .height(30)
            .fillColor(Color.White)
            .opacity(0.5)
            .onClick(()=>{
              globalThis.musicPlayer.changePlayMode()
            })
        }
        else{
          if(this.playState.playMode=='random'){
            Image($r("app.media.randomPlayIcon"))
              .width(30)
              .height(30)
              .scale({x:0.85,y:0.85})
              .fillColor(Color.White)
              .opacity(0.5)
              .onClick(()=>{
                globalThis.musicPlayer.changePlayMode()
              })
          }
          else{
            Image($r("app.media.repeatPlayIcon"))
              .width(30)
              .height(30)
              .fillColor(Color.White)
              .opacity(0.5)
              .onClick(()=>{
                globalThis.musicPlayer.changePlayMode()
              })
          }
        }
        Image($r("app.media.lastPlayIcon"))
          .width(50)
          .height(50)
          .fillColor(Color.White)
          .opacity(0.5)
          .onClick(()=>{
            globalThis.musicPlayer.prev()
          })

        if(this.playState.isPlaying){
          Image($r("app.media.pauseIcon"))
            .width(40)
            .height(40)
            .fillColor(Color.White)
            .opacity(0.5)
            .onClick(() => {
              globalThis.musicPlayer.togglePlay()
            })
        }
        else{
          Image($r("app.media.playIcon"))
            .width(40)
            .height(40)
            .fillColor(Color.White)
            .opacity(0.5)
            .onClick(() => {
              globalThis.musicPlayer.togglePlay()
            })
        }

        Image($r("app.media.lastPlayIcon"))
          .width(50)
          .height(50)
          .rotate({angle:180})
          .fillColor(Color.White)
          .opacity(0.5)
          .onClick(()=>{
            globalThis.musicPlayer.next()
          })

        Image($r("app.media.songPlayListIcon"))
          .width(30)
          .height(30)
          .fillColor(Color.White)
          .opacity(0.5)
          .scale({x:1.2,y:1.2})
          .onClick(()=>{
            this.isShowPlayList = true
          })
          .bindSheet(
            $$this.isShowPlayList,
            this.playListSheet(),
            {
              detents: ['75%'],
              showClose: false,
              dragBar: true,
              title: {title:"当前播放"},
              backgroundColor:Color.White
            })
      }
      .width('100%')
      .height(80)
      .padding({left:15,right:15})
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .padding({left:12,right:12,top:12+this.topStatusBarHeight,bottom:24})
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [
        [getDeeperColor(this.coverColor,0.1), 0.0],
        [this.coverColor, 0.5],
        [getLighterColor(this.coverColor,0.1), 1.0]
      ]
    })
  }

  @Builder
  playListSheet(){
    Column({space:12}){
      Row(){
        Button(){
          if(this.playState.playMode=='loop'){
            Row({space:4}){
              Image($r("app.media.LoopPlayIcon"))
                .width(18)
                .height(18)
                .fillColor(0x252734)
              Text("列表循环")
                .fontSize(14)
                .fontColor(0x262837)
            }
          }
          else{
            if(this.playState.playMode=='random'){
              Row({space:4}){
                Image($r("app.media.randomPlayIcon"))
                  .width(18)
                  .height(18)
                  .fillColor(0x252734)
                  .scale({x:0.85,y:0.85})
                Text("随机播放")
                  .fontSize(14)
                  .fontColor(0x262837)
              }
            }
            else{
              Row({space:4}){
                Image($r("app.media.repeatPlayIcon"))
                  .width(18)
                  .height(18)
                  .fillColor(0x252734)
                Text("单曲循环")
                  .fontSize(14)
                  .fontColor(0x262837)
              }
            }
          }
        }
        .backgroundColor(0xf6f6f6)
        .border({width:0.5,color:0xe2e2e4})
        .padding({left:12,right:12,top:8,bottom:8})
        .onClick(()=>{
          globalThis.musicPlayer.changePlayMode()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({left:18})

      List(){
        ForEach(this.playState.playList,(item:Song,index)=>{
          ListItem(){
            Row(){
              Text(item.name)
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(16)
                .fontColor(this.playState.currentPlayIndex==index?$r("app.color.lightRed"):$r("app.color.softBlack"))
              Text(` · ${item.singerList.map(singer=>singer.name).join('/')}`)
                .maxLines(1)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .fontSize(14)
                .fontColor(this.playState.currentPlayIndex==index?$r("app.color.lightRed"):0x87878f)
              Blank()
              Image($r("app.media.cancelIconLine"))
                .width(18)
                .height(18)
                .fillColor(0xc5c4c9)
                .onClick(()=>{
                  globalThis.musicPlayer.removeSongFromPlayList(item.id)
                })
            }
            .width('100%')
            .alignItems(VerticalAlign.Bottom)
          }
          .width('100%')
          .height(45)
          .padding({left:18,right:18})
          .backgroundColor(this.playState.currentPlayIndex==index?0xf6f6f6:Color.White)
          .onClick(()=>{
            globalThis.musicPlayer.jumpToIndex(index)
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}