const jwt = require('jsonwebtoken');
// token 加密(生成)-jwt.sign()
exports.generateToken = async (user,expiresIn=24*60*60) => {
    // 1. 用户对象信息， 2. 加密字符串'secret'， 3. 过期时间
    const token = await jwt.sign(user,'secret',{expiresIn})
    return token
}
// token 解密(中间件)-jwt.verify()
exports.verifyToken = (required=true) => {
    return async (ctx,next)=>{
        // 1. header 获取 token (前端用Authorization传回token)
        const token = ctx.header.authorization;
        //console.log(token,'==================')
        if(token){
            // 有token
            try{
                // 2. 解密 token
                const user = await jwt.verify(token,'secret');
                //console.log(user) // {username:'13812323234345',id:1}
                // 3. 把用户信息挂载到 ctx 上(全局属性 重要)
                ctx.user = user;
                await next();
            }catch(err){
                ctx.body = {code:801,message:'token过期或不正确'};
            }
        }else if(required){
             // 没token
             ctx.body = {code:802,message:'token不存在'};
        }
    }
}

// 用于登录的解密中间件
exports.loginVerifyToken = async (ctx, next) => {
  const token = ctx.header.authorization;
  console.log(token);
  if (token) {
    try {
      // 验证令牌
      ctx.user = await jwt.verify(token, 'secret');
      ctx.hasValidToken = true; // 添加标志位
    } catch (err) {
      // 验证失败但不阻止流程继续
      ctx.hasValidToken = false;
    }
  } else {
    ctx.hasValidToken = false;
  }
  
  await next();
};
