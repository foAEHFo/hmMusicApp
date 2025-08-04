import http from '@ohos.net.http';
import { ConfigUtil as Config } from "./httpConfig";
import PreferencesUtil from "../utils/tokenUtil"

export class ResponseModel{
  success:boolean;
  message:string;
  data:Array<object>;
  constructor(){
    this.success = false;
    this.message = "";
    this.data = [];
  }
}

export interface response{
  code:boolean;
  message:string;
  data:object;
}

async function addTokenToHeader(options: http.HttpRequestOptions) {
  // 从存储中获取 Token（实际项目中可能从偏好设置或其他安全存储中获取）
  const token = await  PreferencesUtil.get("userinfoStore", "token", "") || ''
  //console.log('=========',token)
  if (token) {
    // 确保 header 对象存在
    if (!options.header) {
      options.header = {}
    }
    // 添加 Token 到请求头，使用 Bearer 格式
    options.header['authorization'] = `${token}`
  }
  return options
}

// 核心请求函数
async function httpRequest(
  method: http.RequestMethod,
  apiUri: string,
  requestData?: object
): Promise<ResponseModel> {
  const httpReq = http.createHttp();
  let serverData: ResponseModel = new ResponseModel()
  try {
    const url = `${Config.SERVER}${apiUri}`;

    const options: http.HttpRequestOptions = {
      method,
      header: { 'Content-Type': 'application/json' },
      connectTimeout: Config.HTTP_CONNECT_TIMEOUT,
      readTimeout: Config.HTTP_READ_TIMEOUT,
      extraData: requestData ? JSON.stringify(requestData) : undefined
    };
    await addTokenToHeader(options);
    const response = await httpReq.request(url, options);

    let data = `${response.result}` //把json对象转换成json字符串
    let result: object = JSON.parse(data) //把json字符串转换成json对象
    if (result["code"] === Config.HTTP_CODE_200) {
      serverData.success = true
      serverData.message = result["message"]
      serverData.data = result["data"]
      return serverData
    } else {
      serverData.success = false
      serverData.message = result["message"]
      return serverData
    }
  } catch (error) {
    serverData.success = false
    serverData.message = `${Config.SERVER_NET_ERROR}:${JSON.stringify(error)}`;
    return serverData;
  } finally {
    // 确保释放资源
    httpReq.destroy();
  }
}

// GET请求封装
export async function HttpGet(
  apiUri: string,
  data?: object
): Promise<ResponseModel> {
  return httpRequest(http.RequestMethod.GET, apiUri, data);
}

// POST请求封装
export async function HttpPost(
  apiUri: string,
  data?: object
): Promise<ResponseModel> {
  return httpRequest(http.RequestMethod.POST, apiUri, data);
}