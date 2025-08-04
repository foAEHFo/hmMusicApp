const model = require("../model/index");
const Sequelize = require('sequelize');
const axios = require('axios');

const userfollow = model.userFollow;
const artistfollow = model.artistFollow;
const user = model.users;

// 将一个用户添加到我的关注
exports.addUserFollow = async (ctx) => {
    const userId = ctx.request.body.userId;
    const followId = ctx.request.body.followId;
    if (!userId) {
        ctx.body = { code: 500, message: "缺少参数用户id" };
        return ctx.body;
    }
    if (!followId) {
        ctx.body = { code: 500, message: "缺少参数关注id" };
        return ctx.body;
    }
    if (userId == followId) {
        ctx.body = { code: 500, message: "不能关注自己" };
        return ctx.body;
    }
    try {
        const userInfo = await userfollow.create({
            userId: userId,
            followId: followId
        });
        // 在users表中将关注数加1
        await user.update({
            followCount: Sequelize.literal('followCount + 1')
        }, {
            where: {
                id: userId
            }
        });
        // 在users表中将粉丝数加1
        await user.update({
            fans: Sequelize.literal('fans + 1')
        }, {
            where: {
                id: followId
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

// 取消对一个用户的关注
exports.deleteUserFollow = async (ctx) => {
    const userId = ctx.request.body.userId;
    const followId = ctx.request.body.followId;
    if (!userId) {
        ctx.body = { code: 500, message: "缺少参数用户id" };
        return ctx.body;
    }
    if (!followId) {
        ctx.body = { code: 500, message: "缺少参数关注id" };
        return ctx.body;
    }
    try {
        // 取消关注
        await userfollow.destroy({
            where: {
                userId: userId,
                followId: followId
            }
        });
        // 在users表中将关注数减1
        await user.update({
            followCount: Sequelize.literal('followCount - 1')
        }, {
            where: {
                id: userId
            }
        });
        // 在users表中将粉丝数减1
        await user.update({
            fans: Sequelize.literal('fans - 1')
        }, {
            where: {
                id: followId
            }
        });
        return ctx.body = { code: 200, message: "成功" }
    }
    catch (error) {
        ctx.body = { code: 500, message: "失败", error: error.message };
        return ctx.body;
    }

};

// 将一个歌手添加到我的关注
exports.addArtistFollow = async (ctx) => {
    const userId = ctx.request.body.userId;
    const followId = ctx.request.body.followId;
    const followAccountId = ctx.request.body.artistAccountId;
    if (!userId) {
        ctx.body = { code: 500, message: "缺少参数用户id" };
        return ctx.body;
    }
    if (!followId) {
        ctx.body = { code: 500, message: "缺少参数关注id" };
        return ctx.body;
    }
    try {
        await artistfollow.create({
            userId: userId,
            followId: followId,
            followAccountId: followAccountId || null,
        });
        // 在users表中将关注数加1
        await user.update({
            followCount: Sequelize.literal('followCount + 1')
        }, {
            where: {
                id: userId
            }
        }
        )
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        return ctx.body = { code: 500, message: "失败", error: error.message };
    }
};

// 取消一个歌手的关注
exports.deleteArtistFollow = async (ctx) => {
    const userId = ctx.request.body.userId;
    const followId = ctx.request.body.followId;
    if (!userId) {
        ctx.body = { code: 500, message: "缺少参数用户id" };
        return ctx.body;
    }
    if (!followId) {
        ctx.body = { code: 500, message: "缺少参数关注id" };
        return ctx.body;
    }
    try {
        await artistfollow.destroy({
            where: {
                userId: userId,
                followId: followId
            }
        });
        // 在users表中将关注数减1
        await user.update({
            followCount: Sequelize.literal('followCount - 1')
        }, {
            where: {
                id: userId
            }
        }
        )
        return ctx.body = { code: 200, message: "成功" };
    }
    catch (error) {
        return ctx.body = { code: 500, message: "失败", error: error.message };
    }
};

// 获取用户关注列表
exports.getUserFollows = async (ctx) => {
    const userId = ctx.request.body.userId;
    try {
        const artistfollows = await artistfollow.findAll({
            where: { userId: userId },
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });

        // 使用Promise.all进行并行请求
        const results = await Promise.all(artistfollows.map(async (follow) => {
            try {
                const base = follow.toJSON(); // 获取模型的JSON表示
                let artistInfo;

                if (follow.followAccountId) {
                    // 请求用户详情接口
                    const response = await axios.get(
                        `http://music.163.com/api/v1/user/detail/${follow.followAccountId}`,
                        { timeout: 5000 } // 设置超时时间
                    );
                    artistInfo = {
                        name: response.data.profile.nickname,
                        avatar: response.data.profile.avatarUrl
                    };
                } else {
                    // 请求歌手详情接口
                    const response = await axios.get(
                        `http://music.163.com/api/artist/${follow.followId}`,
                        { timeout: 5000 }
                    );
                    artistInfo = {
                        name: response.data.artist.name,
                        avatar: response.data.artist.picUrl
                    };
                }

                return { ...base, ...artistInfo };
            } catch (error) {
                // 记录错误但继续返回基础数据
                return {
                    ...follow.toJSON(),
                    error: `请求失败: ${error.message}`
                };
            }
        }));
        //联合查询，查询出关注的用户列表
        const userList = await userfollow.findAll({
            where: { userId: userId },
            include: [{
                model: user,
                as: 'following',  // 获取被关注的用户信息
                attributes: { exclude: ['password'] } // 排除密码字段
            }],
            //倒序返回
            order: [
                ['createdAt', 'DESC']
            ]
        });
        ctx.body = {
            code: 200,
            message: "成功",
            data: { artistList: results, userList: userList }
        };
    } catch (error) {
        ctx.body = {
            code: 500,
            message: "获取关注列表失败",
            error: error.message
        };
    }
};