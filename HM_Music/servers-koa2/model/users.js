module.exports = (sequelize, DataTypes) => {
    const userModel = sequelize.define("users", {
      id: {
        type: DataTypes.INTEGER(),
        primaryKey: true,
        autoIncrement: true,
      },
      username: {
        type: DataTypes.STRING(50),
        allowNull: false,
        unique: true,
        comment: "用户名",
      },
      phoneNumber: {
        type: DataTypes.STRING(11),
        allowNull: false,
        unique: true,
        comment: "手机号",
      },
      password: {
        type: DataTypes.STRING(50),
        allowNull: false,
        comment: "密码"
      },
      followCount:{
        type: DataTypes.INTEGER(),
        defaultValue:0,
        comment: "关注人数"
      },
      fans:{
        type: DataTypes.INTEGER(),
        defaultValue:0,
        comment: "粉丝人数"
      },
      Lv:{
        type: DataTypes.INTEGER(),
        defaultValue:1,
        comment: "等级"
      },
      hours:{
        type: DataTypes.INTEGER(),
        defaultValue:0,
        comment: "听歌时长"
      },
      sex:{
        type: DataTypes.INTEGER(),
        allowNull: true,
        comment: "性别"
      },
      headPicture:{
        type: DataTypes.STRING(200),
        allowNull: true,
        comment: "头像"
      },
      coverPicture:{
        type: DataTypes.STRING(200),
        allowNull: true,
        comment: "个人封面"
      }
      }
    );
    return userModel;
  };
  