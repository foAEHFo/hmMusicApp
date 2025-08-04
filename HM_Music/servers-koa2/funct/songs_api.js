const model = require("../model/index");
const api = require("../config/api");
const playLists_Songs = model.playLists_Songs;
const playList = model.playLists;
const playListSongs = model.playLists_Songs;

const axios = require('axios');
const headers = api.headers
const cookies = api.cookies

// 获取一个自建歌单的所有歌曲
exports.getMyPlayListAllSongs = async (ctx) => {
    try {
        // 从前端请求体中获取 ids 参数
        let id = ctx.request.body.playListId;
        //从playLists_Songs表中查询出所有playList_id = id的song_id
        let songs = await playLists_Songs.findAll({
            where: {
                playList_id: id
            },
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });
        let ids = [];
        songs.forEach(element => {
            ids.push(element.song_id);
        });
        // 准备请求参数
        const params = {
            ids: `[${ids.join(',')}]`  // 转换为字符串格式的数组
        };

        // 配置请求选项
        const config = {
            url: "http://music.163.com/api/song/detail/",
            params: params,
            headers: {
                'Cookie': Object.entries(cookies)
                    .map(([key, value]) => `${key}=${value}`)
                    .join('; ')
            },
            timeout: 10000
        };

        // 发送 GET 请求到网易云API
        const response = await axios.get(config.url, config);

        // 返回数据给前端
        return ctx.body = { code: 200, message: "成功", data: response.data };
    }
    catch (error) {
        // 错误处理
        let status = 500;
        let message = "服务器错误";

        if (error.response) {
            status = error.response.status;
            message = `网易云API错误: ${status}`;
        } else if (error.request) {
            if (error.code === 'ECONNABORTED') {
                message = "请求超时";
            } else {
                message = "无法连接到网易云服务器";
            }
        } else {
            message = error.message;
        }

        ctx.status = status || 500;
        return ctx.body = {
            code: status || 500,
            message: message,
            error: error.message
        };
    }
};

//获取网络歌单的所有歌曲
exports.getPlayListAllSongs = async (ctx) => {
    try {
        // 从前端请求体中获取歌单ID
        const playlistId = ctx.request.body.playListId;

        // 获取完整歌单数据
        const playlistData = await getPlaylistData(playlistId);

        if (!playlistData) {
            return ctx.body = { code: 500, message: "获取歌单数据失败" };
        }

        // 返回数据给前端
        return ctx.body = {
            code: 200,
            message: "成功",
            data: playlistData
        };
    } catch (error) {
        // 错误处理
        let status = 500;
        let message = "服务器错误";

        if (error.response) {
            status = error.response.status;
            message = `网易云API错误: ${status}`;
        } else if (error.request) {
            if (error.code === 'ECONNABORTED') {
                message = "请求超时";
            } else {
                message = "无法连接到网易云服务器";
            }
        } else {
            message = error.message;
        }

        ctx.status = status || 500;
        return ctx.body = {
            code: status || 500,
            message: message,
            error: error.message
        };
    }
};

// 获取完整歌单数据
async function getPlaylistData(playlistId) {
    // 1. 获取歌单基础信息
    const playlistInfo = await getPlaylistInfo(playlistId);
    if (!playlistInfo) return null;

    // 2. 获取所有歌曲ID
    const trackIds = playlistInfo.trackIds.map(item => item.id);
    if (!trackIds || trackIds.length === 0) {
        return {
            info: parsePlaylistInfo(playlistInfo),
            tracks: []
        };
    }

    // 3. 批量获取歌曲详情
    const allTracks = await getSongsDetail(trackIds);

    return {
        info: parsePlaylistInfo(playlistInfo),
        tracks: allTracks
    };
}

// 获取歌单基础信息
async function getPlaylistInfo(playlistId) {
    const url = "http://music.163.com/api/v3/playlist/detail";

    try {
        const response = await axios.get(url, {
            params: { id: playlistId },
            headers: {
                // 使用配置文件
                ...headers,

                'Cookie': Object.entries(cookies)
                    .map(([key, value]) => `${key}=${value}`)
                    .join('; ')
            },
            timeout: 10000
        });

        return response.data.playlist || {};
    } catch (error) {
        console.error(`获取歌单失败: ${error.message}`);
        return null;
    }
}

// 解析歌单基础信息
function parsePlaylistInfo(playlist) {
    const creator = playlist.creator || {};
    return {
        id: playlist.id,
        name: playlist.name,
        total_tracks: playlist.trackCount,
        play_count: playlist.playCount,
        cover_img: playlist.coverImgUrl,
        description: playlist.description,
        creator: {
            nickname: creator.nickname,
            avatar: creator.avatarUrl
        }
    };
}
async function getSongsDetail(trackIds) {
    const batchSize = 50;
    const concurrency = 8; // 最大并发数
    const allSongs = [];

    // 创建批次数组
    const batches = [];
    for (let i = 0; i < trackIds.length; i += batchSize) {
        batches.push(trackIds.slice(i, i + batchSize));
    }

    // 并发控制函数
    const runBatch = async (batchIndex) => {
        const batch = batches[batchIndex];
        try {
            const batchSongs = await getBatchSongs(batch);
            allSongs.push(...batchSongs);
            console.log(`已获取: ${Math.min((batchIndex + 1) * batchSize, trackIds.length)}/${trackIds.length}`);
        } catch (error) {
            console.error(`批次 ${batchIndex} 失败: ${error.message}`);
        }
    };

    // 并发执行
    let currentIndex = 0;
    const workers = Array(concurrency).fill().map(async (_, i) => {
        while (currentIndex < batches.length) {
            const batchIndex = currentIndex++;
            await runBatch(batchIndex);
        }
    });

    await Promise.all(workers);

    return allSongs;
}

// 获取一批歌曲的详细信息
async function getBatchSongs(batch) {
    const url = "http://music.163.com/api/v3/song/detail";

    // 构建批量请求参数
    const cValue = JSON.stringify(batch.map(id => ({ id: String(id) })));

    const response = await axios.get(url, {
        params: { c: cValue },
        headers: {
            // 使用配置文件
            ...headers,

            'Cookie': Object.entries(cookies)
                .map(([key, value]) => `${key}=${value}`)
                .join('; ')
        },
        timeout: 15000
    });
    const songs = response.data.songs || [];

    return songs.map(song => {
        const artists = song.ar || [];
        const albumInfo = song.al || {};

        return {
            id: song.id,
            name: song.name,
            artists: artists.map(ar => ({
                id: ar.id,
                name: ar.name
            })),
            album: albumInfo.name,
            cover: albumInfo.picUrl,
            is_vip: song.fee === 1
        };
    });
}
module.exports.getBatchSongs = getBatchSongs;

// 获取一个单曲的详细信息和它的播放url
exports.getSong = async (ctx) => {
    const songId = ctx.request.body.songId; // 从前端获取单曲ID
    let artistId = ctx.request.body.artistId; // 从前端获取歌手ID
    const userId = ctx.request.body.userId;
    if (!songId || !artistId) {
        return ctx.body = { code: 400, message: "缺少必要参数" };
    }
    let artistIds = Array.isArray(artistId) ? artistId : [artistId];
    const song = JSON.stringify([songId]); // 转换为json格式
    try {
        const islove = await playList.findOne({
            attributes: [], // 不返回任何字段，只检查是否存在
            where: {
                creatorId: userId,
                playListsName: "我喜欢的音乐"
            },
            include: [{
                model: playListSongs,
                attributes: ["song_id"], // 不返回歌曲字段
                where: {
                    song_id: songId // 指定要检查的歌曲ID
                },
                required: true // INNER JOIN
            }]
        });
        const isLove = islove != null;
        // 歌单信息url
        const urls = [
            // 1.获取歌曲播放的详细信息
            axios.get("http://music.163.com/api/song/detail", {
                params: { ids: song },
                timeout: 5000,
            }),
            // 4. 获取歌曲歌词
            axios.get("http://music.163.com/api/song/lyric", {
                params: {
                    id: songId,
                    lv: -1,
                    tv: -1,
                    kv: -1
                },
                timeout: 5000,
            })
        ]
        // 为每位歌手创建请求
        const artistRequests = artistIds.map(artistId =>
            axios.get(`http://music.163.com/api/artist/${artistId}`, {
                timeout: 5000,
            })
        );

        // 执行所有请求
        const [songDetail, lyric, ...artistResponses] = await Promise.all([
            ...urls,
            ...artistRequests
        ]);

        // 统一检查API响应码
        const responses = [songDetail, lyric];
        responses.forEach(res => {
            if (res.data.code !== 200) {
                throw new Error(`API错误: ${res.data.message || '未知错误'}`);
            }
        });
        let artistAccountIds = [];
        artistResponses.forEach((res, index) => {
            if (res.data.code === 200 && res.data.artist && res.data.artist.accountId) {
                artistAccountIds.push(res.data.artist.accountId);
            } else {
                artistAccountIds.push(-1);
            }
        });
        // 返回结果
        return ctx.body = {
            code: 200,
            message: "成功",
            data: {
                song_detail: {

                    isLove: isLove,
                    artistAccountId: artistAccountIds,
                    songDetail: songDetail.data,
                },
                song_url: `http://music.163.com/song/media/outer/url?id=${songId}.mp3`,
                lyric: lyric.data
            }
        };
    } catch (error) {
        console.error('获取歌曲信息失败:', error);
        ctx.status = 500;
        return ctx.body = {
            code: 500,
            message: "获取歌曲信息失败",
            error: error.message
        };
    }
}