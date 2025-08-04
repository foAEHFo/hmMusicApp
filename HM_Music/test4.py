import requests
import time
import json

# 完整的请求头
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
    "Referer": "http://music.163.com/",
    "Origin": "http://music.163.com"
}

# 完整的有效Cookie配置
cookies = {
    "MUSIC_U": "0087311C1A2866EFE19C22066A92D9711FC9F354007FC263F0879E81475819EBE89D5A23A820EEE4F795173EFDBF196134D7A9E1E8DF40F8274437180B2114E6A847D6FD0C2F39E3CA8F9C086D31783185AE91B2D01256D35031E933D7897C261E165E86B612F0C49769317AE73FCBFC98C5DD03D3B1BE96C6E1411780BDD7833372A268A32A7584EF3D462973E9D3F9370FE0432AA12B5C7EB751BEA16AC70416BEAC301276C172C8810EC5A6F38C7F56B30923CD91E71C818C93A6BEEED759026EA261A6D0CC6043B2513C27918A90AEC54AE81C487C86E6DDC21FC9DC5E1F4FE8279A276AABA4C3248998A769390A350E38CFBF2CD929DFC23BD008ECD4D5E68792AB4896B885C93F2770DF516DB3A48736A934ABE34C361A6B941708C4A262391237D89C0965F0C84638DC4A691D59CD99F1182A739EE1ABF6BCEB028E77A8",
    "__csrf": "a5585a58216a89dc720a771abcd4af04",
    "JSESSIONID-WYYY": "RmlBMBIuFjb4QbpcW16Rh9zzZPIXPb2ffUzviXkTnaS2nGIcebUwgk40NDC7ic20r8Oiw%2FtuIBH%2F%5CB2%2Fb4F6mVWKdHCZF3IacJPahQc%2F4kFB4TC5omFAg2TfjmgY%2BId6RHARd7dTncFc326rjxDVPSfdbDBxaiOffFjrsk4%2BOi9SgnBm%3A1752551448261",
    "ntes_utid": "tid._.R9BeHFV0B6REUlUEEAaShUT1E8IvjRFN._.0",
    "_ntes_nnid": "bec90b26564174255206e352548a3589,1752549648502",
    "_ntes_nuid": "bec90b26564174255206e352548a3589",
    "sDeviceId": "YD-yjePNeMvdDNAAwRREFKX0QW1B9c%2BzaKc",
    "__remember_me": "true",
    "appver": "1.5.2",
}
#歌手的用户id  accountId:328199093 ,,, 2602782039
artistId = "6452"
#song_id = 1403318151
url = "http://music.163.com/api/v1/user/detail/"
url = url + "328199093"
data = {
}

try:
    start_time = time.time()
    # 发送请求
    response = requests.get(
        url=url,
        params=data,
        # headers=headers,
        # cookies=cookies,
        timeout=10000  # 设置10秒超时
    )

    # 检查HTTP状态码
    print(f"\n处理完成!  耗时: {time.time()-start_time:.2f}秒")
    response.raise_for_status()  # 如果是4xx/5xx错误会抛出异常

    print("原始响应内容:", response.text[:5000])
    #print("返回数据:", response.json())
except requests.exceptions.HTTPError as http_err:
    print(f"HTTP错误发生: {http_err}")
    if response.text:
        print(f"错误详情: {response.text}")
except requests.exceptions.ConnectionError:
    print("连接错误: 无法连接到服务器")
except requests.exceptions.Timeout:
    print("请求超时")
except requests.exceptions.RequestException as err:
    print(f"请求异常: {err}")