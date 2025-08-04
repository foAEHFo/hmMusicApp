const api = require('../config/api');
const model = require('../model/index');
const Sequelize = require('sequelize');
const axios = require('axios');
const headers = api.headers
const cookies = api.cookies

const playLists = model.playLists;
const playLists_Songs = model.playLists_Songs;
const playLists_Collect = model.playLists_Collect;
const subscribePlaylists = model.subscribePlaylists;

//选出所有的符合条件的歌单
exports.getPersonPlayLists = async (ctx) => {
    try {
        let isCreate = await playLists.findAll({
            where: {
                creatorId: ctx.request.body.id
            },
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });
        //联合查询，联合playLists_Collect和playLists表进行查询
        //联合条件为playLists_Collect中的id字段等于playLists中的id字段，最后查询出collectorId字段等于ctx.request.body.id的行
        const isCollect = await playLists.findAll({
            include: [{
                model: playLists_Collect,
                where: { collectorId: ctx.request.body.id },
                attributes: [], // 不返回中间表字段
            }],
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });
        //同样的联合查询
        const isSubcsribe = await subscribePlaylists.findAll({
            where: {
                userId: ctx.request.body.id
            },
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });
        //需要把isCreate的最后一个元组放到第一个位置
        isCreate.unshift(isCreate.pop());
        const data = {
            isCreate,
            isCollect,
            isSubcsribe
        }
        return ctx.body = { code: 200, message: "成功", data: data };
    } catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message };
        return ctx.body;
    }
};

//用户创建一个歌单
exports.addPlayList = async (ctx) => {
    try {
        const newPlayList = await playLists.create({
            playListsName: ctx.request.body.name,
            creatorId: ctx.request.body.id
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message };
        return ctx.body;
    }
};

//用户将一首歌添加到歌单中
exports.addSongToPlayList = async (ctx) => {
    const songId = ctx.request.body.songId;
    const playListId = ctx.request.body.playListId;
    const song = JSON.stringify([songId]); // 转换为json格式
    try {
        await playLists_Songs.create({
            playList_id: playListId,
            song_id: songId
        });
        //并且更新歌单表中的歌曲数量值为之前的值加1
        //注：还应该实现的功能是添加歌曲时，将歌单封面变为这个歌曲的封面，先欠着
        await playLists.update({
            songCount: Sequelize.literal('songCount + 1')
        }, {
            where: {
                id: playListId
            }
        });
        // 获取tmp的isPicFit字段的值
        const isPicFit = await playLists.findAll({
            attributes: ['isPicFit'],
            where: {
                id: playListId
            }
        });
        if (isPicFit[0].isPicFit === 0) {
            let url = "http://music.163.com/api/song/detail";
            let tmp = await axios.get(url, {
                params: { ids: song },
                timeout: 5000
            });
            let URL = tmp.data.songs[0].album.picUrl;
            //将这个歌单的封面url更新
            await playLists.update({
                coverPicture: URL
            }, {
                where: {
                    id: playListId
                }
            });
        }
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message };
        return ctx.body;
    }
};

//将一个歌单添加到自己的收藏中
exports.addPlayListToCollect = async (ctx) => {
    try {
        await playLists_Collect.create({
            id: ctx.request.body.playListId,
            collectorId: ctx.request.body.id
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message }
    }
}

//将一个歌单从自己的收藏中删除
exports.deletePlayListFromCollect = async (ctx) => {
    try {
        await playLists_Collect.destroy({
            where: {
                id: ctx.request.body.playListId,
                collectorId: ctx.request.body.id
            }
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message }
    }
}

// 将一个歌单添加到网络歌单中
exports.addPlayListSubscribe = async (ctx) => {
    const playListId = ctx.request.body.playListId;
    const id = ctx.request.body.id;
    const url = "http://music.163.com/api/v3/playlist/detail";

    try {
        const response = await axios.get(url, {
            params: { id: playListId },
            headers: {
                // 使用配置文件
                ...headers,

                'Cookie': Object.entries(cookies)
                    .map(([key, value]) => `${key}=${value}`)
                    .join('; ')
            },
            timeout: 10000
        });
        const data = response.data.playlist;
        //console.log(response.data);
        await subscribePlaylists.create({
            id: playListId,
            userId: id,
            playListsName: data.name,
            songCount: data.trackCount,
            playCount: data.playCount,
            coverPicture: data.coverImgUrl,
            creatorName: data.creator.nickname,
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message }
    }
}

// 将一个歌单从网络歌单中删除
exports.deleteFromSubscribe = async (ctx) => {
    try {
        await subscribePlaylists.destroy({
            where: {
                id: ctx.request.body.playListId,
                userId: ctx.request.body.id
            }
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message }
    }
}



//修改歌单信息
exports.updatePlayListInfo = async (ctx) => {
    let data = {};
    if (ctx.request.body.newPlayListsName) {
        data.playListsName = ctx.request.body.name;
    }
    if (ctx.request.body.description !== undefined) {
        if (ctx.request.body.description === null) {
            data.description = null;
        }
        if (ctx.request.body.description != null) {
            data.description = ctx.request.body.description;
        }
    }
    try {
        await playLists.update(data, {
            where: {
                id: ctx.request.body.playListId
            }
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message }
    }
}

//删除某个歌单
exports.deletePlayList = async (ctx) => {
    try {
        await playLists.destroy({
            where: {
                id: ctx.request.body.playListId
            }
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message }
    }
}

//将一首歌从某一个歌单中删去
exports.deleteSongFromPlayList = async (ctx) => {
    const playListId = ctx.request.body.playListId
    const songId = ctx.request.body.songId
    try {
        await playLists_Songs.destroy({
            where: {
                playList_id: playListId,
                song_id: songId
            }
        })
        // 歌单歌曲数量减一
        // 添加日志检查影响行数

        // 获取tmp的isPicFit字段的值
        const isPicFit = await playLists.findAll({
            attributes: ['isPicFit'],
            where: {
                id: playListId
            }
        });
        if (isPicFit[0].isPicFit === 0) {
            //查找出这个歌单内最新的歌
            let change = await playLists_Songs.findAll({
                where: {
                    playList_id: playListId
                },
                //倒序返回
                order: [
                    ['createdAt', 'DESC']
                ]
            })
            //取第一个歌曲的id
            const changeId = change[0] ? change[0].song_id : null;
            let URL = "";
            if (changeId) {
                const song = JSON.stringify([changeId]);
                let url = "http://music.163.com/api/song/detail";
                let tmp = await axios.get(url, {
                    params: { ids: song },
                    timeout: 5000
                });
                URL = tmp.data.songs[0].album.picUrl;
            }
            //将这个歌单的封面url更新
            await playLists.update({
                coverPicture: URL
            }, {
                where: {
                    id: playListId
                }
            });
            await playLists.update({
                songCount: Sequelize.literal('songCount - 1')
            }, {
                where: { id: playListId }
            });
        }
        return ctx.body = { code: 200, message: "成功" }
    }
    catch (err) {
        return ctx.body = { code: 500, message: "失败", error: err.message }
    }
}

// 增加一个歌单的播放次数
exports.addPlayCount = async (ctx) => {
    const playTime = parseInt(ctx.request.body.playTime)
    const playListId = ctx.request.body.playListId
    if (!playTime || !playListId) {
        return ctx.body = { code: 500, message: "缺少必要参数" };
    }
    if (playTime <= 0) {
        return ctx.body = { code: 500, message: "playTime要大于0" };
    }
    try {
        await playLists.update({
            playCount: Sequelize.literal(`playCount + ${playTime}`)
        }, {
            where: { id: playListId }
        });
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (err) {
        ctx.body = { code: 500, message: "失败", error: err.message }
    }
}


// 获取热歌榜
exports.getHotSongList = async (ctx) => {
    const url = "http://music.163.com/api/v3/playlist/detail";
    const playListId = 3778678
    const n = 50
    try {
        const response = await axios.get(url, {
            params: { id: playListId, n: n },
            headers: {
                // 使用配置文件
                ...headers,

                'Cookie': Object.entries(cookies)
                    .map(([key, value]) => `${key}=${value}`)
                    .join('; ')
            },
            timeout: 10000
        });
        const data = response.data.playlist;
        return ctx.body = { code: 200, message: "成功", data: data };
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message }
    }


}