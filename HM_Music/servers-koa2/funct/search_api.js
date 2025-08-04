const model = require("../model/index");
const axios = require('axios');

const api = require('../config/api');
const headers = api.headers;
const cookies = api.cookies;

const playList = model.playLists;
const playListSongs = model.playLists_Songs;
const subscribePlaylist = model.subscribePlaylists;
const artistfollows = model.artistFollow;
const userfollow = model.userFollow;
const user = model.users;

exports.search = async (ctx) => {
    // 确保包含所有必要参数
    let data = {
        s: ctx.request.body.s || "海阔天空", // 添加默认值
        limit: 15, // 使用默认值
        type: ctx.request.body.type || 1,    // 添加默认值
        offset: ctx.request.body.offset || 0 //偏移值
    };
    const userId = ctx.request.body.userId;
    if(!userId){
        return ctx.body = { code: 500, message: "缺少参数userId" };
    }

    try {
        const url = "http://music.163.com/api/search/get/";
        const cookies = {
            appver: "1.5.2"
        };
        
        // 使用 URLSearchParams 处理表单数据
        const params = new URLSearchParams();
        for (const [key, value] of Object.entries(data)) {
            params.append(key, value);
        }
        
        const response = await axios.post(url, params.toString(), {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Cookie': Object.entries(cookies)
                    .map(([k, v]) => `${k}=${v}`).join('; ')
            },
            timeout: 5000
        });
        // 检查 HTTP 状态码
        if (response.status >= 400) {
            throw new Error(`HTTP错误: ${response.status} ${response.statusText}`);
        }
        let results = [];
        if(data.type == 1){
            results = await Promise.all(response.data.result.songs.map(async song => {
                // 检查是否在喜欢列表中
            const result = await playList.findOne({
                attributes: [], // 不返回任何字段，只检查是否存在
                where: {
                    creatorId: userId,
                    playListsName: "我喜欢的音乐"
                },
                include: [{
                    model: playListSongs,
                    attributes: ["song_id"], // 不返回歌曲字段
                    where: {
                        song_id: song.id // 指定要检查的歌曲ID
                    },
                    required: true // INNER JOIN
                }]
            });
            const isLove = result != null;
            // 返回添加了isLove字段的歌曲对象
            return {
                isLove,
                ...song,
            };
        }));
        }
        if(data.type == 1000){
            results = await Promise.all(response.data.result.playlists.map(async playlist => {
                // 检查用户是否订阅
                const result = await subscribePlaylist.findOne({
                       where: { userId: userId,id: playlist.id}
                });
                const isLove = result != null;
                return {
                    isLove,
                    ...playlist,
                };
            }));
        }
        if(data.type == 100){
            results = await Promise.all(response.data.result.artists.map(async artist => {
                // 检查是否被关注
                const result = await artistfollows.findOne({
                    where: { userId: userId , followId : artist.id}
                });
                const isLove = result != null;
                return {
                    isLove,
                    ...artist,
                };
            }));
        }

        ctx.body = { 
            code: 200, 
            message: "成功", 
            data: results
        };
        
    } catch (error) {
        // 更详细的错误处理
        let errorCode = 500;
        let errorMessage = "服务器错误";
        
        if (error.code === 'ECONNABORTED') {
            errorCode = 408;
            errorMessage = "请求超时";
        } else if (error.response) {
            // 处理 HTTP 错误
            errorCode = error.response.status;
            errorMessage = `HTTP错误: ${error.response.status}`;
        } else if (error.request) {
            // 处理网络错误
            errorCode = 503;
            errorMessage = "无法连接到服务器";
        }
        
        ctx.body = { 
            code: errorCode, 
            message: errorMessage,
            error: error.message 
        };
    }
}

// 搜索加载接口
exports.searchAll = async (ctx) => {
    const userId = ctx.request.body.userId;
    const s = ctx.request.body.s;
    const limit = 15
    const offset = 0;
    if(!userId){
        ctx.status = 400;
        return ctx.body = {
            code: 400,
            message: "缺少必要参数userId"
        };
    }
    if(!s){
        ctx.status = 400;
        return ctx.body = {
            code: 400,
            message: "缺少必要参数: s"
        };
    }

    try {
        let urls = [
                    // 1. 查询单曲
                    axios.get(`http://music.163.com/api/search/get/`, {
                        params: {
                            s: s,
                            type: 1,
                            limit: limit,
                            offset: offset
                        },
                        headers: {
                            ...headers,
                            'Cookie': Object.entries(cookies)
                            .map(([key, value]) => `${key}=${value}`)
                            .join('; ')
                        },
                        timeout: 10000 
                    }),
                    // 2. 查询歌单
                    axios.get(`http://music.163.com/api/search/get/`, {
                        params: {
                            s: s,
                            type: 1000,
                            limit: limit,
                            offset: offset
                        },
                        headers: {
                            ...headers,
                            'Cookie': Object.entries(cookies)
                            .map(([key, value]) => `${key}=${value}`)
                            .join('; ')
                        },
                        timeout: 10000 
                    }),
                    // 3. 查询歌手
                    axios.get(`http://music.163.com/api/search/get/`, {
                        params: {
                            s: s,
                            type: 100,
                            limit: limit,
                            offset: offset
                        },
                        headers: {
                            ...headers,
                            'Cookie': Object.entries(cookies)
                            .map(([key, value]) => `${key}=${value}`)
                            .join('; ')
                        },
                        timeout: 10000 
                    }),
            ];

        const [songs, playLists, artists] = await Promise.all(urls);
        let responses = [songs, playLists, artists];
        responses.forEach(res => {
            if (res.data.code !== 200) throw new Error(`API错误: ${res.data.message || '未知错误'}`);
        });
    //查询用户
    const users = await user.findAll({
        where: {
            username: s
        }
    });
    // 处理搜索结果，为每个元素添加 isLove 字段
    const processResults = async () => {
        // 并行处理所有结果类型
        const [processedSongs, processedPlaylists, processedArtists, processedUsers] = await Promise.all([
            // 1. 处理歌曲
            (async () => {
                if (!songs?.data?.result?.songs) return [];
                // 并行处理每首歌曲
                const results = await Promise.all(songs.data.result.songs.map(async song => {
                    // 检查是否在喜欢列表中
                    const result = await playList.findOne({
                        attributes: [], // 不返回任何字段，只检查是否存在
                        where: {
                            creatorId: userId,
                            playListsName: "我喜欢的音乐"
                        },
                        include: [{
                            model: playListSongs,
                            attributes: ["song_id"], // 不返回歌曲字段
                            where: {
                                song_id: song.id // 指定要检查的歌曲ID
                            },
                            required: true // INNER JOIN
                        }]
                    });
                    const isLove = result != null;
                    // 返回添加了isLove字段的歌曲对象
                    return {
                        isLove,
                        ...song,
                    };
                }));
                return results;
            })(),
            
            // 2. 处理歌单
            (async () => {
                if (!playLists?.data?.result?.playlists) return [];
                // 并行处理每个歌单
                const results = await Promise.all(playLists.data.result.playlists.map(async playlist => {
                    // 检查用户是否订阅
                    const result = await subscribePlaylist.findOne({
                        where: { userId: userId,id: playlist.id}
                    });
                    const isLove = result != null;
                    return {
                        isLove,
                        ...playlist,
                    };
                }));
                return results;
            })(),
            
            // 3. 处理歌手
            (async () => {
                if (!artists?.data?.result?.artists) return [];
                // 并行处理每个艺人
                const results = await Promise.all(artists.data.result.artists.map(async artist => {
                    // 检查是否被关注
                    const result = await artistfollows.findOne({
                        where: { userId: userId , followId : artist.id}
                    });
                    const isLove = result != null;
                    return {
                        isLove,
                        ...artist,
                    };
                }));
                return results;
            })(),
            
            // 4. 处理用户
            (async () => {
                if (!users || users.length === 0) return [];
                // 并行处理每个用户
                const results = await Promise.all(users.map(async user => {
                    // 检查是否被当前用户关注
                    const result = await userfollow.findOne({
                        where: { userId: userId , followId: user.id}
                    })
                    const isLove = result != null;
                    return {
                        isLove,
                        ...user.get({ plain: true }), // 转换为普通对象
                    };
                }));
                return results;
            })()
        ]);
        
        return {
            songs: processedSongs,
            playlists: processedPlaylists,
            artists: processedArtists,
            users: processedUsers
        };
    };

    const Result = await processResults();

    // 处理歌手信息（保护空结果）
    const artistList = artists.data.result?.artists || [];
    if (artistList.length === 0) { // 无歌手结果时跳过
      return ctx.body = {
        code: 200,
        message: "成功加载搜索结果（无歌手数据）",
        data: {
             Result : Result
        }
      };
    }

    // 取首位歌手
    const topArtist = artistList[0];
    const topArtistArtistId = topArtist.id;
    const topArtistAccountId = topArtist.accountId || null;

    // 2. 获取歌手详细信息
    let artistDetailRequests = [];
    if (topArtistAccountId) {
      artistDetailRequests.push(
        axios.get(`http://music.163.com/api/v1/user/detail/${topArtistAccountId}`, { 
          timeout: 10000 
        })
      );
    }
    artistDetailRequests.push(
      axios.get(`http://music.163.com/api/artist/${topArtistArtistId}`, { 
        timeout: 10000 
      })
    );

    const artistDetails = await Promise.all(artistDetailRequests);
    // 校验歌手详情响应
    for (const res of artistDetails) {
      if (!res?.data || res.data.code !== 200) {
        console.warn("歌手详情API异常", res?.data);
        continue; // 跳过错误响应
      }
    }

    // 解析数据
    const profile = (topArtistAccountId !== -1 && artistDetails[0]?.data?.profile) 
      ? artistDetails[0].data.profile 
      : null;
      
    const artistData = artistDetails[artistDetails.length-1]?.data?.artist || {};

    return ctx.body = {
      code: 200,
      message: "成功加载搜索结果",
      data: {
        topArtist: {
          id: topArtistArtistId,
          accountId: topArtistAccountId,
          name: artistData.name || topArtist.name,
          avatar_url: profile?.avatarUrl || artistData.picUrl || "",
          background_url: profile?.backgroundUrl || artistData.picUrl || "",
          followeds: profile?.followeds || 0,
          follows: profile?.follows || 0,
          allAuthTypes: profile?.allAuthTypes || [],
          musicSize: artistData.musicSize || 0,
          albumSize: artistData.albumSize || 0,
          alias: (artistData.alias && artistData.alias[0]) || "",
        },
        Result : Result
      },
    };
    } catch (error) {
        let errorCode = 500;
        let errorMessage = "服务器错误";
        
        if (error.code === 'ECONNABORTED') {
            errorCode = 408;
            errorMessage = "请求超时";
        } else if (error.response) {
            // 处理 HTTP 错误
            errorCode = error.response.status;
            errorMessage = `HTTP错误: ${error.response.status}`;
        } else if (error.request) {
            // 处理网络错误
            errorCode = 503;
            errorMessage = "无法连接到服务器";
        }
        
        ctx.body = { 
            code: errorCode, 
            message: errorMessage,
            error: error.message 
        };
    }
}

