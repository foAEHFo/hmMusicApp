module.exports = (sequelize, DataTypes) => {
    const playlists_Collect = sequelize.define("playlists_Collect", {
      id: {
        type: DataTypes.INTEGER(),
        primaryKey: true,
      },
      collectorId:{
        type: DataTypes.INTEGER(),
        primaryKey: true,
        comment: "歌单收藏者id",
      }
    });
  
    return playlists_Collect;
  };
  