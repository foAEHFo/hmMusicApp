const token = require("../funct/token_api");
const model = require('../model/index')
const user = require('../funct/user_api')
const playLists = require('../funct/playLists_api')
const search = require('../funct/search_api')
const songs = require('../funct/songs_api')
const albums = require('../funct/albums_api')
const artist = require('../funct/artist_api')
const follow = require('../funct/follow_api')

const loginVerifyToken = token.loginVerifyToken
const verifyToken = token.verifyToken

const router = require('koa-router')()
const path = require('path')

const multer = require('@koa/multer')
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null,path.join(__dirname, '../public/uploads')); // 文件存储的目录
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(
      null,
      file.fieldname +
        "-" +
        uniqueSuffix +
        "." +
        file.originalname.split(".").pop()
    ); // 文件名设置
  },
});
const upload = multer({ storage: storage })




// 1.用户相关api

//获取登录用户的基本数据，用于验证登录并返回用户数据
router.post('/getUser',loginVerifyToken,user.getUser)
//注释
//参数：phoneNumber:string(11),password:string(50)
//返回值：数据库中用户表的所有字段组成的对象data

//用户注册
router.post('/addUser',user.addUser)
//参数：username:string(12),phoneNumber:string(11),password:string(50),sex:number(0代表女，1代表男)
//当用户注册成功时，会自动在这个用户上创建一个歌单："我喜欢的音乐"
//返回值：无

//修改用户信息
router.post('/updateUserInfo',user.updateUserInfo)
//参数：id:number , username?:string(12),password?:string(50),sex?:string(10),headPicture?:string(200),coverPicture?:string(200)
//注释：传入的参数就是前端用户修改过的数据，其他没修改过的可以传null也可以不传，但是不要把用户没改过的字段也传非null的值
//返回值：无

//账户注销
router.post('/deleteUser',verifyToken(),user.deleteUser) 
//参数：id:number
//注释：由于数据库使用的是restrict模式约束，所以可以存在恢复一部分用户注销的数据的方法，后面需要再写
//返回值：无

// 获取用户界面的信息，包括基础信息和歌单信息
router.post('/getUserInfo',user.getUserInfo) 
//参数：目标用户id id:number , 获取类型 type:number , 我的id myId?:number
//注释：获取用户信息，当type为1时，获取的是别的用户的主页信息，当type为其他值时，获取的是自己的信息，当获取的是其他人的信息时isLove字段有值，否则没值
//当获取的是别的用户的信息时，myId必须传自己的id，否则拿不到isLove字段
//返回值：用户基本信息和用户歌单信息

// 获取用户每日推荐的信息
router.post('/getDailyRecommendSongs',user.getDailyRecommendSongs)
//参数：无
// 注释：使用谁的cookies返回的就是谁的每日推荐，这里使用的是我的
//返回值：每日推荐歌曲对象的数组

// 获取用户的私人雷达
router.post('/getUserRadar',user.getPersonalizedRadar)
//参数：用户id id:number
//注释：会返回30首歌曲，不足30首则有多少返回多少
//返回值：包含歌曲对象的数组

// 登录初始化
router.post('/loginInit',user.init)
// 参数：用户id id:number
// 默认返回今天所有的推荐歌曲，今天热歌棒的前10名
// 返回值：包含每日推荐，热歌榜和私人雷达的数据

//用于积累听歌时长
router.post('/addPlayTime',user.addPlayTime)
//参数：用户id:number , 本次听歌时常(秒) seconds:number
//返回值：无



// 2.歌单操作相关api

//获取用户创建过的所有歌单
router.post('/getUserPlayLists',playLists.getPersonPlayLists)
//参数 ：用户id:number
//注释：这个api能够返回所有该用户的歌单，包括近期，创建和收藏；另外由于我的喜欢本质也是一个歌单，所以该api也会将我的喜欢一并返回
//返回值：一个对象，包含订阅，创建和收藏数组，通过isSubcsribe，isCreate，isCollect引用，每个数组对象都是一个歌单对象，拥有所有歌单表的字段

//用户将一个歌单添加到自己的收藏中
router.post('/addPlayListToCollect',playLists.addPlayListToCollect)
//参数：用户标识 id:number，歌单标识 playListId:number
//返回值：无

//用户将一个歌单从自己的收藏中删除
router.post('/deletePlayListFromCollect',playLists.deletePlayListFromCollect)
//参数：用户标识 id:number，歌单标识 playListId:number
//返回值：无

// 用户将一个歌单添加到订阅中
router.post('/addPlayListSubscribe',playLists.addPlayListSubscribe)
//参数：用户标识 id:number，歌单标识 playListId:number
//返回值：无

// 用户将一个歌单从订阅中删除
router.post('/deleteFromSubscribe',playLists.deleteFromSubscribe)
//参数：用户标识 id:number，歌单标识 playListId:number
//返回值：无

//用户将一首歌添加到一个歌单中
router.post('/addSongToPlayList',playLists.addSongToPlayList)
//参数：playListId:number , songId:number
//注释：前端要保证只能让用户这么操作自己的歌单(通过UI来保证),后端要过滤会增加时间复杂度；同样的，将一首歌添加到我的喜欢也是用这个
//返回值：无

// 用户把一首歌从一个歌单中删除
router.post('/deleteSongFromPlayList',playLists.deleteSongFromPlayList)
//参数：歌单 playListId:number , 歌曲 songId:number
//注释：前端要保证只能让用户这么操作自己的歌单(通过UI来保证),后端要过滤会增加时间复杂度；同样的，我的喜欢的取消喜欢操作也是用这个
//返回值：无

//用户创建歌单，创建出的歌单啥都为为空，封面也为空，你需要调用'/addSongToPlayList'才能加歌
router.post('/addPlayList',playLists.addPlayList)
//参数：创建者id:number ，歌单名字name:string(50)
//歌单的封面取决于最新加入歌单的那首歌的封面，暂时不支持自定义歌单封面
//返回值：无

//修改歌单的名称和简介，只能修改自己的歌单
router.post('/updatePlayListInfo',playLists.updatePlayListInfo)
//参数：目标歌单的id playListId:number , 新的歌单名称 name?:string(50) , 新的简介 description?:string(500)
//注释：歌单简介可以为空(传""即可)，传回来什么就修改为什么，如果不想修改直接不传就行；歌单名称不接受为空，可以不传;UI保证不能修改我的喜欢的名称
//返回值：无

//删除创建歌单
router.post('/deletePlayList',playLists.deletePlayList)
//参数：目标歌单的id playListId:number
//注释：理论上每个用户的"我喜欢的音乐"都是一个歌单，并且仿照网易云的前端，这个歌单不能删除，前端不能有这个功能
//返回值：无

// 获取某一个自建或收藏歌单中的所有歌曲(不包括网络歌单)
router.post('/getMyPlayListAllSongs',songs.getMyPlayListAllSongs)
//参数：歌单id：playListId
//注释：由于我的喜欢也是一个歌单，所以获取我的喜欢也是用的这个api
//返回值：一个结构体，包含一个单曲数组，每个单曲都是网易云那边的比较复杂的结构体，自己打印出来看看

// 获取网络歌单的所有歌曲
router.post('/getPlayListAllSongs',songs.getPlayListAllSongs)
//参数：歌单id：playListId:number
//只用于网络歌单获取所有包含歌曲以及自身的相应信息
//返回值：一个包含歌单自身基本信息，以及歌单创建者基本信息，和一个单曲数组，每个单曲对象都包含了一些单曲基本信息，自己打印出来看看


// 获取热歌榜
router.post('/getHotSongList',playLists.getHotSongList)
// 参数：无
// 注释：固定返回网易云热歌榜前50首歌曲
// 返回值：歌曲数组，包含50个歌曲对象


//增加歌单的播放次数，理论上只对自己的歌单有效
router.post('/addPlayCount',playLists.addPlayCount)
//参数：歌单id：playListId:number , 播放增加的次数 playTime:number
//返回值：无



// 3.专辑相关api

// 获取专辑内歌曲列表
router.post('/getSongsFromAlbum',albums.getSongsFromAlbum)
//参数：专辑 albumId:number
//注释：这里网易直接就是默认全部获取的，可能是因为单个专辑内歌曲数目不多
//返回值：自己打印出来看，已经过滤了不复杂


// 4.搜索相关api

// 搜索加载所有结果
router.post('/searchAll',search.searchAll)
//参数：搜索内容 s:string , 用户ID userId:number
//一开始搜索的时候用这个api加载所有内容，随后有需要再使用search接口配合偏移值动态加载剩下的东西
//返回值：复杂，包含所有搜索信息

// 按需搜索获取各种结果
router.post('/search',search.search)
//参数：搜索内容 s:string , 用户ID userId:number ,搜索类型 type:number , 搜索偏移 offset:number
//注释：其实还有两个参数一个是limit我观察网易云得知是10，我就默认赋了15前端不用传了，另一个是分页，我默认偏移是0，前端可以传,可以根据字段hasMore来判断还有没有更多搜索结果
//type: 搜索的种类,[1 单曲] [10 专辑] [100 歌手] [1000 歌单] [1002 用户],我给的默认值是1，前端可以传不同值达到不同搜索目的
//但是其中我们不使用[10 专辑],[1002 用户],原因是用户在searchAll中就一次性返回完毕了
//s我给的默认值是"海阔天空",后期可以开发算法根据用户听歌类型推荐歌曲赋默认值
//返回值：搜单曲时的如下，歌单的不想列了太长了自己打印出来看吧


// 5.单曲相关api

//获取任意一个单曲的详细信息和播放地址
router.post('/getSong',songs.getSong)
//参数：歌曲 songId:number , 歌手id artistId:number[] , 用户ID userId:number
//返回值：返回歌曲的基本信息，歌手的用户id，歌曲的播放地址

// 6.歌手相关的api

// 获取一个歌手的用户主页个人基本信息
router.post('/getArtistInfo',artist.getArtistInfo)
// 参数：歌手的用户ID，不是歌手ID accountId:number , 歌手ID artistId: number
// 返回值：包括歌手的关注数，粉丝数，演唱过的歌曲数，专辑数，歌手的头像，背景图，还有歌手的头衔等，足够前端使用

// 获取一个歌手top50的热门歌曲
router.post('/getArtistTopSongs',artist.getArtistTopSongs)
//参数 : 歌手ID artistId:number
//注释 : 这个是固定获取top50的，也就是固定返回50首，不足50就有多少返回多少，不可以控制limit
//返回值：很复杂，整体来说就是很多个歌曲对象，主要每个歌曲对象都比较复杂

// 获取歌手专辑列表
router.post('/getArtistAlbums',albums.getArtistAlbums)
//参数：歌手 artistId:number , 最多返回数量 limit:number ， 偏移值 offset:number
//注释：这里的limit默认是15，通过偏移值获取更多
//返回值：自己打印出来看，已经过滤了不复杂

// 获取一个歌手的包括基本信息，top50歌曲，专辑列表在内的所有信息
router.post('/getArtist',artist.getArtist)
//参数：歌手ID artistId:number , 歌手的用户ID accountId?:number , 用户ID userId:number , 专辑列表(默认15) limit?:number , 专辑列表偏移值(默认0) offset?:number
//注释：accountId的有无决定了该歌手是否在网易云注册了用户，决定了该采取哪种布局，如果是没有注册用户，那么无法获取歌手粉丝数
//返回值：自己打印出来看，字段很多

// 关注相关的api

//将一个用户添加到我的关注
router.post('/addUserFollow',follow.addUserFollow)
//参数：用户ID userId:number  , 关注者ID followId:number
//注释：这是用于关注用户的接口，不是用于关注歌手的
//返回值：无

//取消对一个用户的关注
router.post('/deleteUserFollow',follow.deleteUserFollow)
//参数：用户ID userId:number  , 关注者ID followId:number
//注释：这是用于取消关注用户的接口，不是用于取消关注歌手的
//返回值：无

//将一个歌手添加到我的关注
router.post('/addArtistFollow',follow.addArtistFollow)
//参数：用户ID userId:number  , 关注歌手ID followId:number , 关注歌手的用户ID artistAccountId?:number
//注释：用于将一个歌手添加到我的关注列表的接口,artistAccountId是选填，没有可以不填，有一定要填
//返回值：无

//删除对一个歌手的关注
router.post('/deleteArtistFollow',follow.deleteArtistFollow)
//参数：用户ID userId:number  , 歌手ID followId:number
//注释：用于删除对一个歌手的关注
//返回值：无

//获取一个用户的关注列表，包括用户和歌手
router.post('/getUserFollows',follow.getUserFollows)
//参数：用户ID userId:number
//注释：用于获取一个用户的关注列表，包括用户和歌手
//返回值：包括用户列表和歌手列表，每一个元素都包含了前端用于显示的一些基本信息


// 上传api
router.post('/uploads', upload.single('file'), async (ctx, next) => {
  const file = ctx.request.file
  
  // 构造完整的图片访问URL
  const baseUrl = `http://${ctx.request.header.host}`;
  const fullUrl = `${baseUrl}/uploads/${file.filename}`;
  
  ctx.body = {
    code: 200,
    message: '上传成功',
    data: {
      fileName: file.filename,
      url: fullUrl  // 返回完整URL
    }
  }
})

module.exports = router
