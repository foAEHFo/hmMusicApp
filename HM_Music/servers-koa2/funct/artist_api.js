const model = require("../model/index");
const axios = require('axios');
const moment = require('moment');

const api = require("../config/api");
const headers = api.headers;
const cookies = api.cookies;

const artistfollows = model.artistFollow;

exports.getArtistInfo = async (ctx) => {
    try {
        const accountId = ctx.request.body.accountId; // 从前端获取这个歌手的用户ID
        if(!accountId) {
            return ctx.body = {
            code: 400,
            message: "缺少必要参数: accountId"
        };
        }
        // 网易云API地址
        let url = `http://music.163.com/api/v1/user/detail/${accountId}`;
        
        // 请求参数
        const params = {};
        
        // 发送请求
        const response = await axios.get(url, {
            params,
            timeout: 10000 // 10秒超时
        });
        
        // 检查API响应状态码
        if (response.data.code !== 200) {
            throw new Error(`网易云API返回错误: ${response.data.message || '未知错误'}`);
        }
        
        let tmp = response.data.profile;

        // 获取歌手的作品数量
        const artistId = ctx.request.body.artistId;
        url = `http://music.163.com/api/artist/${artistId}`
        const response2 = await axios.get(url, {
            params,
            timeout: 10000 // 10秒超时
        });
        if (response2.data.code !== 200) {
            throw new Error(`网易云API返回错误: ${response.data.message || '未知错误'}`);
        }

        let tmp2 = response2.data.artist;

        return ctx.body = {
            code: 200,
            message: "成功",
            data: {
                avatar_url : tmp.avatarUrl,
                background_url : tmp.backgroundUrl ,
                followeds : tmp.followeds,
                follows : tmp.follows,
                allAuthTypes : tmp.allAuthTypes,
                musicSize : tmp2.musicSize,
                albumSize : tmp2.albumSize
            }
        }
        
    } catch (error) {
        console.error('获取歌手信息失败:', error);
        ctx.status = 500;
        return ctx.body = {
            code: 500,
            message: "获取歌手信息失败失败",
            error: error.message
        };
    }
};

// 获取歌手top50的热门歌曲
exports.getArtistTopSongs = async (ctx) => {
    try {
        const artistId = ctx.request.body.artistId; // 从前端获取这个歌手的用户ID
        console.log(artistId);
        // 网易云API地址
        const url = "http://music.163.com/api/artist/top/song/";
        
        // 请求参数
        const params = {
            id :  artistId
        };
        
        // 发送请求
        const response = await axios.get(url, {
            params,
            headers: {
                ...headers,
                Cookie: Object.entries(cookies)
                    .map(([key, value]) => `${key}=${value}`)
                    .join('; ')
            },
            timeout: 10000 // 10秒超时
        });
        
        // 检查API响应状态码
        if (response.data.code !== 200) {
            throw new Error(`网易云API返回错误: ${response.data.message || '未知错误'}`);
        }
        
        let tmp = response.data;
        return ctx.body = {
            code: 200,
            message: "成功",
            data: tmp
        }
        
    } catch (error) {
        console.error('获取歌手信息失败:', error);
        ctx.status = 500;
        return ctx.body = {
            code: 500,
            message: "获取歌手信息失败失败",
            error: error.message
        };
    }
};

exports.getArtist = async (ctx) => {
    // 从请求中获取参数
    const userId = ctx.request.body.userId;
    const artistId = ctx.request.body.artistId;
    const accountId = ctx.request.body.accountId;
    const limit = ctx.request.body.limit || 15;     // 默认每页15个专辑
    const offset = ctx.request.body.offset || 0;     // 默认偏移0
    
    // 参数校验
    if (!artistId) {
        ctx.status = 400;
        return ctx.body = {
            code: 400,
            message: "缺少必要参数: artistId"
        };
    }
    if(!userId){
        ctx.status = 400;
        return ctx.body = {
            code: 400,
            message: "缺少必要参数: userId"
        };
    }

    try {
        const islove = await artistfollows.findOne({
            where: { userId: userId , followId : artistId}
        });
        const isLove = islove != null;
        // 定义并行请求
        let urls = []
        let userDetailRes = null;
        let artistInfoRes = null;
        let topSongsRes = null;
        let albumsRes = null;
        if(accountId){
            urls = [
            // 1. 歌手基本信息（原getArtistInfo）
            axios.get(`http://music.163.com/api/v1/user/detail/${accountId}`, { timeout: 10000 }),
            // 2. 歌手详情（包含作品数量）
            axios.get(`http://music.163.com/api/artist/${artistId}`, { timeout: 10000 }),
            // 3. TOP50歌曲（原getArtistTopSongs）
            axios.get("http://music.163.com/api/artist/top/song/", {
                params: { id: artistId },
                timeout: 10000
            }),
            // 4. 专辑列表（原getArtistAlbums）
            axios.get(`http://music.163.com/api/artist/albums/${artistId}`, {
                params: { limit, offset },
                timeout: 10000
            })
            ];
            [userDetailRes, artistInfoRes, topSongsRes, albumsRes] = await Promise.all(urls);
        }
        else {
            urls = [
            // 2. 歌手详情（包含作品数量）
            axios.get(`http://music.163.com/api/artist/${artistId}`, { timeout: 10000 }),
            // 3. TOP50歌曲（原getArtistTopSongs）
            axios.get("http://music.163.com/api/artist/top/song/", {
                params: { id: artistId },
                timeout: 10000
            }),
            // 4. 专辑列表（原getArtistAlbums）
            axios.get(`http://music.163.com/api/artist/albums/${artistId}`, {
                params: { limit, offset },
                timeout: 10000
            })
            ];
            [artistInfoRes, topSongsRes, albumsRes] = await Promise.all(urls);

        }
            
        // 统一检查API响应码
        if(accountId){
            const responses = [userDetailRes, artistInfoRes, topSongsRes, albumsRes];
            responses.forEach(res => {
                if (res.data.code !== 200) throw new Error(`API错误: ${res.data.message || '未知错误'}`);
            });
        }
        else {
            const responses = [artistInfoRes, topSongsRes, albumsRes];
            responses.forEach(res => {
                if (res.data.code !== 200) throw new Error(`API错误: ${res.data.message || '未知错误'}`);
            });
        }
        

        // 处理基本信息
        let profile = null;
        if(accountId){
            profile = userDetailRes.data.profile;
        }
        const artistData = artistInfoRes.data.artist;
        
        // 处理专辑列表
        const albums = albumsRes.data.hotAlbums.map(album => ({
            id: album.id,
            name: album.name || '未知专辑',
            publish_date: moment(album.publishTime).format('YYYY-MM-DD'),
            song_count: album.size || 0,
            cover_url: album.picUrl || ''
        }));

        // 整合所有数据
        return ctx.body = {
            code: 200,
            message: "成功获取所有数据",
            data: {
                // 基础信息
                basic_info: {
                    isLove : isLove,
                    name : artistData.name,
                    avatar_url: profile?profile.avatarUrl : "",
                    background_url: profile?profile.backgroundUrl : artistData.picUrl, 
                    followeds: profile?profile.followeds : 0,
                    follows: profile?profile.follows : 0,
                    allAuthTypes: profile?profile.allAuthTypes : [],
                    musicSize: artistData.musicSize,
                    albumSize: artistData.albumSize,
                    alias : artistData.alias[0]
                },
                // 专辑列表
                albums: {
                    artist: { id: artistId, name: albumsRes.data.artist?.name || '未知歌手' },
                    albums,
                    has_more: albumsRes.data.more || false,
                    total: albumsRes.data.artist?.albumSize || 0
                },
                // TOP50歌曲（保留原始结构）
                top_songs: topSongsRes.data,
            }
        };

    } catch (error) {
        console.error('获取歌手信息失败:', error);
        ctx.status = error.response?.status || 500;
        return ctx.body = {
            code: ctx.status,
            message: "请求失败",
            error: error.message
        };
    }
};