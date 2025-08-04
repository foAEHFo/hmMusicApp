# 请求地址
url = "http://music.163.com/api/v3/playlist/detail"

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
import requests
import json
import time

def get_playlist_data(playlist_id):
    """获取完整歌单数据 (两步法)"""
    # 1. 获取基础信息
    url = "http://music.163.com/api/v3/playlist/detail"
    params = {"id": playlist_id}
    
    try:
        response = requests.get(
            url,
            params=params,
            cookies=cookies,
            headers=headers,
            timeout=10
        )
        data = response.json()
    except Exception as e:
        print(f"获取歌单失败: {e}")
        return None
    
    # 提取歌单基础信息
    playlist = data.get('playlist', {})
    
    # 2. 获取所有歌曲ID
    track_ids = [item["id"] for item in playlist.get("trackIds", [])]
    total_songs = len(track_ids)
    
    if not track_ids:
        return {
            "info": parse_playlist_info(playlist),
            "tracks": []
        }
    
    # 3. 批量获取歌曲详情
    #print(track_ids)
    all_tracks = get_songs_detail(track_ids)
    
    # 构建最终数据结构
    return {
        "info": parse_playlist_info(playlist),
        "tracks": all_tracks
    }

def parse_playlist_info(playlist):
    """解析歌单基础信息"""
    creator = playlist.get('creator', {})
    return {
        "id": playlist.get('id'),
        "name": playlist.get('name'),
        "total_tracks": playlist.get('trackCount'),
        "play_count": playlist.get('playCount'),
        "cover_img": playlist.get('coverImgUrl'),
        "description": playlist.get('description'),
        "creator": {
            "nickname": creator.get('nickname'),
            "avatar": creator.get('avatarUrl')
        }
    }

def get_songs_detail(track_ids):
    """批量获取歌曲详情"""
    all_songs = []
    
    # 每批最多100首
    for i in range(0, len(track_ids), 100):
        batch = track_ids[i:i+100]
        
        try:
            # 构建批量请求
            payload = {
                "c": json.dumps([{"id": str(id)} for id in batch])
            }
            
            response = requests.get(
                "http://music.163.com/api/v3/song/detail",
                params=payload,
                cookies=cookies,
                headers=headers,
                timeout=15
            )
            data = response.json()
            songs = data.get("songs", [])
            
            # 提取所需字段
            for song in songs:
                artists_info = [
                    {"id": ar.get("id"), "name": ar.get("name")} 
                    for ar in song.get("ar", [])
                ]
                
                album_info = song.get("al", {})
                
                all_songs.append({
                    "id": song.get("id"),
                    "name": song.get("name"),
                    "artists": artists_info,
                    "album": album_info.get("name"),
                    "cover": album_info.get("picUrl"),
                    "is_vip": song.get("fee", 0) == 1
                })
            
            print(f"已获取: {len(all_songs)}/{len(track_ids)}")
            
        except Exception as e:
            print(f"获取歌曲失败: {e}")
    
    return all_songs

# 主程序
if __name__ == "__main__":
    playlist_id = 10188602218
    
    print(f"开始获取歌单 ID={playlist_id}")
    start_time = time.time()
    
    playlist_data = get_playlist_data(playlist_id)
    
    if not playlist_data:
        print("获取歌单失败")
        exit()
    #print(playlist_data)
    print(f"\n处理完成!  耗时: {time.time()-start_time:.2f}秒")