const model = require('../model/index');
const axios = require('axios');
const moment = require('moment');

const api = require("../config/api");
const headers = api.headers;
const cookies = api.cookies;

exports.getArtistAlbums = async (ctx) => {
    try {
        const artistId = ctx.request.body.artistId; // 从路由参数获取歌手ID
        const limit = ctx.request.body.limit || 15; // 从查询参数获取limit，默认15
        const offset = ctx.request.body.offset || 0; // 从查询参数获取offset，默认0
        
        // 网易云API地址
        const url = `http://music.163.com/api/artist/albums/${artistId}`;
        
        // 请求参数
        const params = {
            limit,
            offset
        };
        
        // 发送请求
        const response = await axios.get(url, {
            params,
            timeout: 10000 // 10秒超时
        });
        
        // 检查API响应状态码
        if (response.data.code !== 200) {
            throw new Error(`网易云API返回错误: ${response.data.message || '未知错误'}`);
        }
        
        // 提取专辑信息
        const albums = response.data.hotAlbums.map(album => {
            return {
                id: album.id,
                name: album.name || '未知专辑',
                publish_date: moment(album.publishTime).format('YYYY-MM-DD'),
                song_count: album.size || 0,
                cover_url: album.picUrl || ''
            };
        });
        
        // 返回结果
        return ctx.body = {
            code: 200,
            message: "成功",
            data: {
                artist: {
                    id: artistId,
                    name: response.data.artist?.name || '未知歌手'
                },
                albums,
                has_more: response.data.more || false,
                total: response.data.artist?.albumSize || 0
            }
        };
        
    } catch (error) {
        console.error('获取专辑列表失败:', error);
        ctx.status = 500;
        return ctx.body = {
            code: 500,
            message: "获取专辑列表失败",
            error: error.message
        };
    }
};

exports.getSongsFromAlbum = async (ctx) => {
    try {
        const albumId = ctx.request.body.albumId; // 从路由参数获取专辑ID
        const url = `http://music.163.com/api/album/${albumId}`;
        
        // 发送请求
        const response = await axios.get(url, {
            params: {},
            timeout: 5000,
            // 处理cookie
            headers: {
                ...headers,
                Cookie: Object.entries(cookies)
                    .map(([key, value]) => `${key}=${value}`)
                    .join('; ')
            }
        });
                
        const result = response.data;
        // 检查API返回的状态码
        if (result.code !== 200) {
            ctx.status = 400;
            return ctx.body = { 
                code: 400, 
                message: `API返回错误: ${result.message || '未知错误'}` 
            };
        }
        
        const album = result.album || {};
        
        // 1. 提取付费专辑状态
        const isPaid = album.paid || false;        
        // 2. 提取歌曲信息
        const songsList = album.songs || [];

        const extractedSongs = [];
        for (const song of songsList) {
            const songId = song.id;
            const songName = song.name || '未知歌曲';
            
            // 获取作者列表
            const artists = [];
            for (const artist of song.artists || []) {
                const artistName = artist.name || '未知歌手';
                artists.push(artistName);
            }
            
            // 构建歌曲信息对象
            const songInfo = {
                id: songId,
                name: songName,
                artists: artists
            };
            extractedSongs.push(songInfo);
            
        }
        
        // 返回结果
        ctx.body = {
            code: 200,
            message: "成功",
            data: {
                paid: isPaid,
                songs: extractedSongs,
            }
        };
    } catch (error) {
        // 错误处理
        console.error("处理专辑信息时出错:", error);
        
        if (error.response) {
            // HTTP状态码错误
            console.error(`HTTP错误: ${error.response.status}`);
            console.error("错误详情:", error.response.data);
            
            ctx.status = error.response.status || 500;
            ctx.body = {
                code: ctx.status,
                message: `HTTP错误: ${error.response.statusText}`,
                details: error.response.data
            };
        } else if (error.request) {
            // 请求已发送但未收到响应
            console.error("请求未收到响应:", error.request);
            ctx.status = 504;
            ctx.body = {
                code: 504,
                message: "请求超时，未收到服务器响应"
            };
        } else {
            // 其他错误
            console.error("请求配置错误:", error.message);
            ctx.status = 500;
            ctx.body = {
                code: 500,
                message: "服务器内部错误",
                error: error.message
            };
        }
    }
};