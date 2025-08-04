import requests
import time
import json

#令牌
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Im9wcGFvIiwiaWQiOjQsImlhdCI6MTc1MzM3Nzg3MiwiZXhwIjoxNzUzNDY0MjcyfQ.t0-6yx74BLzqrmTWT0kwZYVIYCWXbTX1CeVrjniR6BI"

# 完整的请求头
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
    "Referer": "http://music.163.com/",
    "Origin": "http://music.163.com",
    #"authorization": f"{TOKEN}",
    'X-Real-IP': '10.136.188.8',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Connection': 'keep-alive'
}

# 完整的有效Cookie配置
cookies = {
    "MUSIC_U": "00361BEEFFB6A4CACB358EB10F5CB638804D1D438CA4BA6D11466C61ECC8821327D6ED79A716DB46FEA36B3AF044E3264632742B6F4B906FD3EFC73EE4F6B2A5F183AEA0B21B497D3CB97E1ED944BF2CF41A9891A69C0076BB4D583AA6F064D5346FEB09804058315F6C167139D7F09B7610A9D5152E5F2DD75CEADE6E090EC2C251180662129C6B994CB7A16BEB97D896CE1A3920A70B716AA9B552D852D8BA20875104378DE437D39DAAF59C4596A46409F4B90351C4097BF3DDAB5E6699A16197E0C13EE22C8BFB4BA231A1B7225C7B5AB7E2490696D02AC9B020D2D302E58F26196BA953BA8413C97A5D315207455CDE871FF795C507CCC28145DE71480EDEE864E279C68C5F1F13F59033C0EF8857D4056D6BA6A5B4D12ABAD3361C0D6E678C81D6C140175C1F1EEAF59B4A573E7BB1B5169A169768B155F456D3EB91D4AAD66BE853677ECD55B903E17C0AD75D112D319BF2BCB38F4BF19A81B698939A11E5332F200E959D8A82250B327473B7593FA27F9AD260CCCF3A20874F9FBF8ECDF2B0BE215B15D57353C4185BCFB33373D46A07DEA1722886FE4FE4E2FDB865D6",
    "__csrf": "634f801ec518378e0006c8d682501aab",
    "JSESSIONID-WYYY": "BWcomDwm2DQYI1R6K3dKjasaHjWixzrrVv1CYaSRNpbXct0e8K7bgdpW6i%2BA5T12x%2BG1Vy3meWYgNF%2FqjqE1YJQ8%5CkTEwcW4YHbKTHTA1%2FxZG7rU4%2BYTO1WnEuJl1Cls1sAY51p0tVpa6rZe%5CchkFznzvDbgoZkPodO4jg7B3Fqi8tUS%3A1753275892420",
    "ntes_utid": "tid._.R9BeHFV0B6REUlUEEAaShUT1E8IvjRFN._.0",
    "_ntes_nnid": "bec90b26564174255206e352548a3589,1752549648502",
    "_ntes_nuid": "bec90b26564174255206e352548a3589",
    "sDeviceId": "YD-yjePNeMvdDNAAwRREFKX0QW1B9c%2BzaKc",
    "__remember_me": "true",
    "appver": "1.5.2",
    "NMTID":"00OPWMO-QkBL9pIVUHEoEBWa7hiKoUAAAGX4qbTpg"
}
# 449818741 , 308299 , 423997333 , 238780 , 1342798229 , 1294951288 , 2162160807 , 1815725297
#user_id = 328199093
#artist_id = 14312549,954456
#song_id = 1403318151 , 2709812973
url = "http://192.168.102.44:3000/deleteUserFollow"
#url = "http://music.163.com/api/artist/6452"
#url = "http://music.163.com/api/v3/playlist/detail"
#url = "http://music.163.com/song/media/outer/url?id=2709812973.mp3"
data = {
    #"albumId":78399571,
    "id": 4,
    # # # # # # "name":"我的第二个歌单",
    "userId" : 4,
    # # # # # #"myId" : 4,
    "s" : "把回忆拼好给你",
    #"artistId": 954456,
    # # "limit":10,
    # # "offset": 10,
    "type" : 1,
    "playListId" : 10188602218,
    #"songId":2709812973,
    # # "seconds":600,
    # # # # # "playTime" : 1
    # "phoneNumber": "18876104065",
    # "password": "20050515ogy",
    #"username":"对象测试",
    # "sex":0
    #"level":"exhigh"
    "followId" : 3
}

try:
    start_time = time.time()
    # 发送请求
    response = requests.post(
        url=url,
        data=data,
        headers=headers,
        cookies=cookies,
        timeout=10  # 设置10秒超时
    )

    # 检查HTTP状态码
    print(f"\n处理完成!  耗时: {time.time()-start_time:.2f}秒")
    response.raise_for_status()  # 如果是4xx/5xx错误会抛出异常
    data = response.json()
    print("原始响应内容:", response.text[:20000])
    #print("歌曲数目:", len(data["data"]["tracks"]))

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




# import requests
# import time
# import json

# # 完整的请求头
# headers = {
#     "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
#     "Referer": "http://music.163.com/",
#     "Origin": "http://music.163.com"
# }

# # 完整的有效Cookie配置
# cookies = {
#     "MUSIC_U": "0087311C1A2866EFE19C22066A92D9711FC9F354007FC263F0879E81475819EBE89D5A23A820EEE4F795173EFDBF196134D7A9E1E8DF40F8274437180B2114E6A847D6FD0C2F39E3CA8F9C086D31783185AE91B2D01256D35031E933D7897C261E165E86B612F0C49769317AE73FCBFC98C5DD03D3B1BE96C6E1411780BDD7833372A268A32A7584EF3D462973E9D3F9370FE0432AA12B5C7EB751BEA16AC70416BEAC301276C172C8810EC5A6F38C7F56B30923CD91E71C818C93A6BEEED759026EA261A6D0CC6043B2513C27918A90AEC54AE81C487C86E6DDC21FC9DC5E1F4FE8279A276AABA4C3248998A769390A350E38CFBF2CD929DFC23BD008ECD4D5E68792AB4896B885C93F2770DF516DB3A48736A934ABE34C361A6B941708C4A262391237D89C0965F0C84638DC4A691D59CD99F1182A739EE1ABF6BCEB028E77A8",
#     "__csrf": "a5585a58216a89dc720a771abcd4af04",
#     "JSESSIONID-WYYY": "RmlBMBIuFjb4QbpcW16Rh9zzZPIXPb2ffUzviXkTnaS2nGIcebUwgk40NDC7ic20r8Oiw%2FtuIBH%2F%5CB2%2Fb4F6mVWKdHCZF3IacJPahQc%2F4kFB4TC5omFAg2TfjmgY%2BId6RHARd7dTncFc326rjxDVPSfdbDBxaiOffFjrsk4%2BOi9SgnBm%3A1752551448261",
#     "ntes_utid": "tid._.R9BeHFV0B6REUlUEEAaShUT1E8IvjRFN._.0",
#     "_ntes_nnid": "bec90b26564174255206e352548a3589,1752549648502",
#     "_ntes_nuid": "bec90b26564174255206e352548a3589",
#     "sDeviceId": "YD-yjePNeMvdDNAAwRREFKX0QW1B9c%2BzaKc",
#     "__remember_me": "true",
#     "appver": "1.5.2",
# }

# #user_id = 328199093
# #artist_id = 14312549,954456
# #song_id = 1403318151 , 2709812973
# url = "http://localhost:3000/getSong"
# #url = "http://music.163.com/api/artist/6452"
# data = {
#     "id": 8,
#     # # # "name":"我的第二个歌单",
#     "userId" : 4,
#     # # #"myId" : 4,
#     "s" : "拂晓",
#     "artistId": 1079074,
#     # # #"type" : 1000,
#     # # "playListId" : 13,
#     "songId":2709812973,
#     # # "playTime" : 1
#     "phoneNumber": "18289661751",
#     "password": "admin",
#     "username":"对象测试",
#     "sex":0

# }

# try:
#     start_time = time.time()
#     # 发送请求
#     response = requests.post(
#         url=url,
#         data=data,
#         # headers=headers,
#         # cookies=cookies,
#         timeout=10  # 设置10秒超时
#     )

#     # 检查HTTP状态码
#     print(f"\n处理完成!  耗时: {time.time()-start_time:.2f}秒")
#     response.raise_for_status()  # 如果是4xx/5xx错误会抛出异常

#     print("原始响应内容:", response.text[:20000]) 

# except requests.exceptions.HTTPError as http_err:
#     print(f"HTTP错误发生: {http_err}")
#     if response.text:
#         print(f"错误详情: {response.text}")
# except requests.exceptions.ConnectionError:
#     print("连接错误: 无法连接到服务器")
# except requests.exceptions.Timeout:
#     print("请求超时")
# except requests.exceptions.RequestException as err:
#     print(f"请求异常: {err}")