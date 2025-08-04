module.exports = (sequelize, DataTypes) => {
    const playListsModel = sequelize.define("playLists", {
      id: {
        type: DataTypes.INTEGER(),
        primaryKey: true,
        autoIncrement: true,
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
      //播放次数
      playCount:{
        type: DataTypes.INTEGER(),
        defaultValue:0,
        comment: "播放次数"
      },
      hours:{
        type: DataTypes.INTEGER(),
        defaultValue:0,
        comment: "听歌时长"
      },
      //歌单封面
      coverPicture:{
        type: DataTypes.STRING(200),
        allowNull: true,
        unique: false,
        comment: "歌单封面",
      },
      //歌单简介
      description:{
        type: DataTypes.STRING(500),
        defaultValue:"",
        comment: "歌单简介",
      },
      //歌单创建者
      creatorId:{
        type: DataTypes.INTEGER(),
        allowNull: false,
        comment: "歌单创建者id",
      },
      isPicFit:{
        type: DataTypes.INTEGER(),
        defaultValue:0,
        comment: "歌单封面是否被用户设置过了",
      },
    });
  
    return playListsModel;
  };
  