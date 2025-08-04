import * as api from "./api"
import * as model from "../interface/Personal"


@Entry
@Component
struct test {
  @State user: model.UserInformation = {
    id: 0,
    avatar: "",
    coverPicture: "",
    name: "",
    sex: 0,
    followCount: 0,
    fans: 0,
    hours: 0 ,
    isFollowed: false
  }
  async getUserData () {
    try {
      console.log('开始获取数据...');
      const startTime = new Date().getTime(); // 记录开始时间
      const response = await api.getUserFollows({
        //这里填参数，就按照api文档里的填，参数名称不能错
        //s : "deadman",
        userId: 4,
        followId:14312549,
        artistAccountId: 328199093,
        //artistId: 5781,
        //limit: 10,
        //offset: 10
        //accountId:97137413
        //id : 4,
        //playListId  : 13,
        //albumId:273213528
        //playTime:1
        //songId: 2708984802
        // name: "我的第三个歌单",
        // description: "测试前端api"
      });
      const endTime = new Date().getTime(); // 记录结束时间
      const duration = endTime - startTime; // 计算耗时（毫秒）
      console.log(`请求耗时: ${duration}ms`);
      if (response.success) {
        //打印出来就知道有哪些字段了，再给数据机构赋值
        console.log('完整响应:', JSON.stringify(response.data));
      } else {
        console.error('获取失败:', response.message);
      }
    } catch (error) {
      console.error('请求异常:', error);
    }
  }
  build() {
    Column() {
      Text("Hello World")
        .fontSize(50)
        .onClick(()=>{
          this.getUserData()
        })
    }
  }
}
