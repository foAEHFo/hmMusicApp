const { generateToken, loginVerifyToken } = require("../funct/token_api");
const { getBatchSongs } = require("../funct/songs_api");
const model = require("../model/index");
const user = model.users;
const playlists = model.playLists;
const userfollow = model.userFollow;
const playlistCollect = model.playLists_Collect;
const subscribePlaylist = model.subscribePlaylists
const playlistSong = model.playLists_Songs

const Sequelize = require("sequelize");
const axios = require("axios");

const api = require("../config/api");
const headers = api.headers
const cookies = api.cookies

//获取用户基本信息,获取前端传来的手机号和密码,进入数据库进行匹配，如果成功则返回成功，失败返回失败
exports.getUser = async (ctx) => {
    let id = null
    const phoneNumber = ctx.request.body.phoneNumber
    const password = ctx.request.body.password
    if (ctx.hasValidToken && !phoneNumber && !password) {
        console.log(1)
        //不需要手机号和密码就可以直接登录了
        id = ctx.user.id
        const data = await user.findOne({
            where: {
                id: id
            }
        })
        return ctx.body = {
            code: 200,
            message: "登录成功",
            data: data
        }
    }
    else {
        //此时需要手机号密码
        if (!phoneNumber || !password) {
            return ctx.body = {
                code: 400,
                message: "必要参数缺失"
            }
        }
        const userInfo = await user.findOne({
            where: {
                phoneNumber: phoneNumber,
                password: password
            }
        });
        if (userInfo) {
            const token = await generateToken({ username: userInfo.username, id: userInfo.id })
            ctx.body = { code: 200, message: "成功", data: { userInfo, token } };
        } else {
            tmp = await user.findOne({
                where: {
                    phoneNumber: ctx.request.body.phoneNumber
                }
            });
            if (tmp) {
                ctx.body = { code: 500, message: "密码错误" };
            }
            else {
                ctx.body = { code: 500, message: "用户不存在，请先注册" };
            }
        }
        return ctx.body;
    }
};

// 获取用户信息，包括基本信息和歌单
exports.getUserInfo = async (ctx) => {
    const userId = ctx.request.body.id;
    const type = ctx.request.body.type;
    const myId = ctx.request.body.myId;
    if (!userId) {
        return ctx.body = { code: 400, message: "缺少参数userId" };
    }
    if (type == 1 && !myId) {
        return ctx.body = { code: 400, message: "缺少参数myId" };
    }
    try {
        const userInfo = await user.findOne({
            where: {
                id: userId
            },
            //除了密码
            attributes: { exclude: ['password'] }
        });
        const isCreate = await playlists.findAll({
            where: {
                creatorId: userId
            },
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });
        const isCollect = await playlists.findAll({
            include: [{
                model: playlistCollect,
                where: { collectorId: userId },
                attributes: [], // 不返回中间表字段
            }],
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });
        const isSubcsribe = await subscribePlaylist.findAll({
            where: {
                userId: userId
            },
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });
        let isLove = null;
        if (type == 1 && myId) {
            let result = await userfollow.findOne({
                where: { userId: myId, followId: userId }
            })
            isLove = result != null;
        }
        //需要把isCreate的最后一个元组放到第一个位置
        isCreate.unshift(isCreate.pop());
        return ctx.body = {
            code: 200,
            message: '成功',
            data: {
                userInfo: userInfo,
                isLove: isLove,
                playLists: {
                    Create: isCreate,
                    Collect: isCollect,
                    Subcsribe: isSubcsribe
                },
            }
        };
    }
    catch (error) {
        return ctx.body = { code: 500, message: "失败", error: error.message };
    }
}

//用户注册，向数据库插入数据，必须有字段username和password
exports.addUser = async (ctx) => {
    try {
        const tmp = await user.findOne({
            where: {
                phoneNumber: ctx.request.body.phoneNumber
            }
        });
        if (tmp) {
            ctx.body = { code: 500, message: "用户已经注册过了" };
            return ctx.body;
        }
        else {
            const newUser = await user.create({
                username: ctx.request.body.username,
                password: ctx.request.body.password,
                phoneNumber: ctx.request.body.phoneNumber,
                //性别
                sex: ctx.request.body.sex
            });
            //在playlists表中创建一个新歌单，歌单名字为"我喜欢的音乐",creatorId为刚创建的这个用户的id
            await playlists.create({
                playListsName: "我喜欢的音乐",
                creatorId: newUser.id
            });
            //创建token
            const token = await generateToken({ username: newUser.username, id: newUser.id })
            ctx.body = { code: 200, message: "成功", data: { newUser, token } };
            return ctx.body;
        }
    } catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message };
        return ctx.body;
    }
};

//修改一个用户的信息
exports.updateUserInfo = async (ctx) => {
    //定义data为可以传入update函数的一个对象
    let data = {};

    if (ctx.request.body.username) {
        data.username = ctx.request.body.username;
    }
    if (ctx.request.body.password) {
        data.password = ctx.request.body.password;
    }
    if (ctx.request.body.sex) {
        data.sex = ctx.request.body.sex;
    }
    if (ctx.request.body.headPicture) {
        data.headPicture = ctx.request.body.headPicture;
    }
    if (ctx.request.body.coverPicture) {
        data.coverPicture = ctx.request.body.coverPicture;
    }

    try {
        const userInfo = await user.update(data, {
            where: {
                id: ctx.request.body.id
            }
        });
        ctx.body = { code: 200, message: "成功" };
        return ctx.body;
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message };
        return ctx.body;
    }

};

//用户注销账户信息
exports.deleteUser = async (ctx) => {
    try {
        const userInfo = await user.destroy({
            where: {
                id: ctx.request.body.id
            }
        });
        ctx.body = { code: 200, message: "成功" };
        return ctx.body;
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message };
    }
};

// 增加听歌时长
exports.addPlayTime = async (ctx) => {
    const id = ctx.request.body.id
    const seconds = parseInt(ctx.request.body.seconds)
    if (!seconds || !id) {
        return ctx.body = { code: 400, message: "缺少必要参数" };
    }
    if (seconds <= 0) {
        return ctx.body = { code: 400, message: "seconds要大于0" };
    }
    try {
        await user.update({
            hours: Sequelize.literal(`hours + ${seconds}`)
        }, {
            where: {
                id: id
            }
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (err) {
        ctx.body = { code: 500, message: "失败", error: err.message };
    }
};

// 获取这个用户的每日推荐歌曲
exports.getDailyRecommendSongs = async (ctx) => {
    const url = "http://interface.music.163.com/api/v1/discovery/recommend/songs";

    // 直接从 ctx 或请求中获取 cookie 值
    const MUSIC_U = cookies["MUSIC_U"] || '';

    // 构建与 Python 完全一致的 Cookie 字符串
    const cookieStr = `MUSIC_U=${MUSIC_U}; __remember_me=true; NMTID=${Math.random().toString(36).substring(2)}`;

    try {
        const { data } = await axios.post(url, null, {
            timeout: 10000,
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
                'Content-Type': 'application/x-www-form-urlencoded',
                'Referer': 'https://music.163.com/',
                'Cookie': cookieStr,
                'X-Real-IP': ctx.ip
            }
        });

        // 验证数据格式
        if (data?.code === 200 && data.recommend?.length > 0) {
            return ctx.body = {
                code: 200,
                data: data.recommend
            };
        }

        // 空结果处理
        return ctx.body = {
            code: 204,
            message: "无推荐内容",
        };

    } catch (error) {
        // 详细错误日志
        console.error('API Error:', {
            message: error.message,
            response: error.response?.data,
            cookies: cookieStr
        });

        return ctx.body = {
            code: 503,
            message: "失败",
        };
    }
};

// 私人雷达功能
exports.getPersonalizedRadar = async (ctx) => {
    const id = ctx.request.body.id;
    try {
        // 只获取歌曲的id，并且去重
        const songs = await playlists.findAll({
            where: {
                creatorId: id
            },
            include: [{
                model: playlistSong,
                attributes: ['song_id']

            }],
        });
        let allSongIds = songs.flatMap(playlist => {
            if (!playlist.playlists_Songs || !Array.isArray(playlist.playlists_Songs)) {
                return [];
            }
            return playlist.playlists_Songs.map(song => song.song_id);
        });
        // 对allSongIds去重
        allSongIds = [...new Set(allSongIds)];

        // 3. 打乱数组顺序
        for (let i = allSongIds.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [allSongIds[i], allSongIds[j]] = [allSongIds[j], allSongIds[i]];
        }

        // 4. 获取前30个（如果数组长度不足30则返回全部）
        const randomSongs = allSongIds.slice(0, 30);
        const randomSongsInfo = await getBatchSongs(randomSongs);
        return ctx.body = {
            code: 200,
            message: "成功",
            data: randomSongsInfo
        };
    }
    catch (error) {
        return ctx.body = {
            code: 500,
            message: "失败",
            error: error.message
        };
    }
};

// 初始化函数
exports.init = async (ctx) => {
    const id = ctx.request.body.id;
    if(!id){
        return ctx.body = { code: 400, message: "缺少必要参数id" };
    }
    const MUSIC_U = cookies["MUSIC_U"] || '';

    // 构建与 Python 完全一致的 Cookie 字符串
    const cookieStr = `MUSIC_U=${MUSIC_U}; __remember_me=true; NMTID=${Math.random().toString(36).substring(2)}`;
    try {
        let urls = [
            // 1. 查询每日推荐
            axios.post(`http://interface.music.163.com/api/v1/discovery/recommend/songs`, null, {
                headers: {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Referer': 'https://music.163.com/',
                    'Cookie': cookieStr,
                    'X-Real-IP': ctx.ip
                },
                timeout: 10000
            }),
            // 2. 热歌榜
            axios.get("http://music.163.com/api/v3/playlist/detail", {
                params: { id: 3778678, n: 10 },
                timeout: 10000
            })
        ];
        const [recommends, HotSongList] = await Promise.all(urls);
        let responses = [recommends, HotSongList];
        responses.forEach(res => {
            if (res.data.code !== 200) throw new Error(`API错误: ${res.data.message || '未知错误'}`);
        });
        let dailyRecommend = recommends.data.recommend;
        let hotSongList = HotSongList.data.playlist.tracks;
        const processResults = async () => {
            // 并行处理所有结果类型
            const [dailyRecommends, hotSongs] = await Promise.all([
                // 1. 处理歌曲
                (async () => {
                    if (!dailyRecommend) return [];
                    // 并行处理每首歌曲
                    const results = await Promise.all(dailyRecommend.map(async song => {
                        // 检查是否在喜欢列表中
                        const result = await playlists.findOne({
                            attributes: [], // 不返回任何字段，只检查是否存在
                            where: {
                                creatorId: id,
                                playListsName: "我喜欢的音乐"
                            },
                            include: [{
                                model: playlistSong,
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
                    if (!hotSongList) return [];
                    // 并行处理每个歌单
                    const results = await Promise.all(hotSongList.map(async song => {
                        // 检查是否在喜欢列表中
                        const result = await playlists.findOne({
                            attributes: [], // 不返回任何字段，只检查是否存在
                            where: {
                                creatorId: id,
                                playListsName: "我喜欢的音乐"
                            },
                            include: [{
                                model: playlistSong,
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
            ]);

            return {
                dailyRecommends: dailyRecommends,
                hotSongs: hotSongs
            };
        };
        const result = await processResults();
        // 只获取歌曲的id，并且去重
        const songs = await playlists.findAll({
            where: {
                creatorId: id
            },
            include: [{
                model: playlistSong,
                attributes: ['song_id']

            }],
        });
        let allSongIds = songs.flatMap(playlist => {
            if (!playlist.playlists_Songs || !Array.isArray(playlist.playlists_Songs)) {
                return [];
            }
            return playlist.playlists_Songs.map(song => song.song_id);
        });
        // 对allSongIds去重
        allSongIds = [...new Set(allSongIds)];

        // 3. 打乱数组顺序
        for (let i = allSongIds.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [allSongIds[i], allSongIds[j]] = [allSongIds[j], allSongIds[i]];
        }

        // 4. 获取前30个（如果数组长度不足30则返回全部）
        const randomSongs = allSongIds.slice(0, 30);
        const randomSongsInfo = await getBatchSongs(randomSongs);
        return ctx.body = {
            code: 200,
            message: "成功",
            data: {
                hotSongs:result.hotSongs,
                dailyRecommends:result.dailyRecommends,
                //hotSongs:result.hotSongs,
                PersonalizedRadar: randomSongsInfo
            }
        };
    }
    catch (error) {
        return ctx.body = {
            code: 500,
            message: "失败",
            error: error.message
        };
    }
};
