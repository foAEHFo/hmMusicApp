module.exports = (sequelize, DataTypes) => {
    const userFollow_model = sequelize.define("userFollow", {
      userId: {
        type: DataTypes.INTEGER(),
        primaryKey: true,
        Comment: "关注者id"
      },
      followId: {
        type: DataTypes.INTEGER(),
        primaryKey: true,
        Comment: "被关注者id"
      },
    });
  
    return userFollow_model;
  };
  