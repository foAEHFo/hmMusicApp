// 1. 连接mysql的配置
const config = require('../config/db.js');
// 2.连接mysql (使用sequelize )
const { Sequelize, DataTypes } = require('sequelize');
const sequelize = new Sequelize(config.database, config.username, config.password,config.option);
// 3. 引入表结构对象
//用户实体集合相关表
const users = require('./users.js')(sequelize,DataTypes);
//歌单实体集合相关表
const playLists = require("./playlists.js")(sequelize,DataTypes);
const playLists_Songs = require("./playlists_Songs.js")(sequelize,DataTypes);
const playLists_Collect = require("./playlists_Collect.js")(sequelize,DataTypes);
const subscribePlaylists = require("./subscribePlaylists.js")(sequelize,DataTypes);

//关注实体集合相关表
const userFollow = require("./userFollow.js")(sequelize,DataTypes);
const artistFollow = require("./artistFollow.js")(sequelize,DataTypes);

//建立表关系，一个用户可以有多个歌单，并且歌单表中的creatorId是外键，关联users表中的id字段
playLists.belongsTo(users,{
  foreignKey:'creatorId',
  targetKey:'id'
})
users.hasMany(playLists,{
  foreignKey:'creatorId',
  targetKey:'id'
})
//一个歌单可以有多首歌曲，并且歌曲表中的playList_id是外键，关联playLists表中的id字段
playLists_Songs.belongsTo(playLists,{
  foreignKey:'playList_id',
  targetKey:'id'
})
playLists.hasMany(playLists_Songs,{
  foreignKey:'playList_id',
  targetKey:'id'
})
//一个用户可以收藏很多个歌单，并且收藏表中的collectorId是外键，关联users表中的id字段
//同时一个歌单可以被多个用户收藏，并且收藏表中的id是外键，关联playLists表中的id字段
playLists_Collect.belongsTo(users,{
  foreignKey:'collectorId',
  targetKey:'id'
})
playLists_Collect.belongsTo(playLists,{
  foreignKey:'id',
  targetKey:'id'
})
users.hasMany(playLists_Collect,{
  foreignKey:'collectorId',
  targetKey:'id'
})
playLists.hasMany(playLists_Collect,{
  foreignKey:'id',
  targetKey:'id'
})
//一个用户可以收藏很多网络歌单，并且近期表中的userId是外键，关联users表中的id字段
subscribePlaylists.belongsTo(users,{
  foreignKey:'userId',
  targetKey:'id'
})
users.hasMany(subscribePlaylists,{
  foreignKey:'userId',
  targetKey:'id'
})

//一个用户可以关注很多个用户，一个用户也可以被很多个用户关注
// userFollow 属于 关注者 (发出关注关系的用户)
userFollow.belongsTo(users, {
  foreignKey: 'userId',
  targetKey: 'id',
  as: 'follower'  // 关注者
});

// userFollow 属于 被关注者 (被关注的用户)
userFollow.belongsTo(users, {
  foreignKey: 'followId',
  targetKey: 'id',
  as: 'following'  // 被关注者
});

// 用户有很多关注记录 (作为关注者)
users.hasMany(userFollow, {
  foreignKey: 'userId',
  as: 'followings'  // 我的关注列表
});

// 用户有很多粉丝记录 (作为被关注者)
users.hasMany(userFollow, {
  foreignKey: 'followId',
  as: 'followers'  // 我的粉丝列表
});

//一个用户可以关注很多个歌手
artistFollow.belongsTo(users,{
  foreignKey:'userId',
  targetKey:'id'
})
users.hasMany(artistFollow,{
  foreignKey:'userId',
  targetKey:'id'
})


// 5.模型同步   sequelize.sync() 自动同步所有模型
sequelize.sync()
// 6 . 导出模型
exports.users = users;
exports.playLists = playLists;
exports.playLists_Songs = playLists_Songs;
exports.playLists_Collect = playLists_Collect;
exports.subscribePlaylists = subscribePlaylists;
exports.userFollow = userFollow;
exports.artistFollow = artistFollow;

exports.sequelize = sequelize;



