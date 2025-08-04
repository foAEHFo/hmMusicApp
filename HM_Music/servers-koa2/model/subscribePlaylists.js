module.exports = (sequelize, DataTypes) => {
    const subscribePlaylists = sequelize.define("subscribePlaylists", {
      id: {
        type: DataTypes.BIGINT(),
        primaryKey: true,
      },
      userId:{
        type: DataTypes.INTEGER(),
        primaryKey: true,
        comment: "订阅者id",
      },
      playListsName: {
        type: DataTypes.STRING(50),
        allowNull: false,
        unique: false,
        comment: "歌单名",
      },
      songCount:{
        type: DataTypes.INTEGER(),
        defaultValue:0,
        comment: "歌单包含歌曲数"
      },
      playCount:{
        type: DataTypes.INTEGER(),
        defaultValue:0,
        comment: "播放次数"
      },
      coverPicture:{
        type: DataTypes.STRING(200),
        defaultValue:"",
        comment: "歌单封面"
      },
      creatorName:{
        type: DataTypes.STRING(50),
        defaultValue:"",
        comment: "创建者名",
      },
    });  
    return subscribePlaylists;
  };
  