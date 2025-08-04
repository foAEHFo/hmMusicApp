import { http } from "@kit.NetworkKit";

export async function downloadImage(url: string): Promise<Uint8Array> {
  const httpRequest = http.createHttp();
  try {
    const response = await httpRequest.request(url, { method: http.RequestMethod.GET });
    if (response.responseCode !== 200) { // 直接使用数字状态码[1](@ref)
      throw new Error(`HTTP错误: ${response.responseCode}`);
    }
    // 将ArrayBuffer转换为Uint8Array
    const buffer = response.result as ArrayBuffer;
    return new Uint8Array(buffer);
  } finally {
    httpRequest.destroy();
  }
}