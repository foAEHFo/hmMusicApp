module.exports = (sequelize, DataTypes) => {
    const artistFollow_model = sequelize.define("artistFollow", {
      userId: {
        type: DataTypes.INTEGER(),
        primaryKey: true,
        Comment: "关注者id"
      },
      followId: {
        type: DataTypes.BIGINT(),
        primaryKey: true,
        Comment: "被关注歌手的id"
      },
      followAccountId:{
        type: DataTypes.BIGINT(),
        allowNull: true,
        Comment: "被关注歌手的账号id"
      }
    });
    return artistFollow_model;
  };