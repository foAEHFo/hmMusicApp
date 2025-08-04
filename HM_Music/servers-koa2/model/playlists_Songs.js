//本表为歌单表和单曲表的关系表，表示每个歌单包含了哪些歌曲
module.exports = (sequelize, DataTypes) => {
    const playlists_Songs_model = sequelize.define("playlists_Songs", {
      playList_id: {
        type: DataTypes.INTEGER(),
        primaryKey: true,
        Comment: "歌单id"
      },
      song_id: {
        type: DataTypes.BIGINT(),
        primaryKey: true,
        Comment: "单曲id"
      },
    });
  
    return playlists_Songs_model;
  };
  