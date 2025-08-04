import picker from '@ohos.file.picker';

import fs from '@ohos.file.fs';

import request from '@ohos.request';
import http from '@ohos.net.http';
import {ConfigUtil} from "../http/httpConfig"

// 定义类型
interface UploadResponse {
  body: string
}

export interface Response {
  code: number;
  data: Data;
  message: string;
}

/**
 * 响应数据
 */
export interface Data {
  /**
   * 上传成功的图片-在线地址
   */
  url: string;
}


// 实例化 选项对象
const photoSelectOptions = new picker.PhotoSelectOptions();
// 过滤选择媒体文件类型为IMAGE
photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
// 选择媒体文件的最大数目
photoSelectOptions.maxSelectNumber = 1;

@Entry
@Component
export struct Comment {
  build() {
    Navigation() {

      Column() {
        //Image('http://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/ajax/17128585871360.5802423440443907.jpg')
        Button('选择并上传图片')
          .onClick(() => {
            // 创建 图片选择对象
            const photoViewPicker = new picker.PhotoViewPicker();
            // 调用 select 方法，传入选项对象
            photoViewPicker.select(photoSelectOptions)
              .then(res => {
                const uri = res.photoUris[0]
                // 因为只选了一张
                // AlertDialog.show({ message: '图片路径为:' + uri })

                // 三、拷贝文件到缓存目录
                // 将文件保存到缓存目录(只能上传在缓存目录中的文件)
                const context = getContext(this)
                const fileType = 'jpg'
                // 生成一个新的文件名
                const fileName = Date.now() + '.' + fileType
                // 通过缓存路径+文件名 拼接出完整的路径
                const copyFilePath = context.cacheDir + '/' + fileName

                // 将文件 拷贝到 临时目录
                const file = fs.openSync(uri, fs.OpenMode.READ_ONLY)
                fs.copyFileSync(file.fd, copyFilePath)

                // 四、上传图片
                // 上传文件
                let files: Array<request.File> = [
                // internal://cache/ 固定的，后面跟上 咱们上一步拷贝文件名即可
                // name 和接口文档的要求对上
                  { filename: fileName, type: fileType, name: 'file', uri: `internal://cache/${fileName}` }
                ]

                request.uploadFile(context, {
                  // url: "http://10.130.170.198:3000/uploads", // url 地址
                  url:`${ConfigUtil.SERVER}/uploads`,
                  method: http.RequestMethod.POST, // 请求方法
                  header: {
                    // 和接口文档的要求的格式对象
                    contentType: 'multipart/form-data',
                  },
                  files, // 文件信息
                  data: [] // 额外提交的数据，不能省略
                })
                  .then((res => {
                    // 这里可以获取到响应的内容
                    res.on('headerReceive', (value) => {
                      // body 是 JSON
                      // AlertDialog.show({
                      //   message: JSON.stringify(value)
                      // })

                      const uploadRes = (value as UploadResponse)
                      const response = JSON.parse(uploadRes.body) as Response
                      AlertDialog.show({
                        message: response.data.url
                      })
                      console.log('上传的地址为:', response.data.url)

                    })
                  }))

              })

          })
      }
    }
    .titleMode(NavigationTitleMode.Mini)
    .title('上传图片')

  }
}