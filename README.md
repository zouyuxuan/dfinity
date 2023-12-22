# file share

## 项目简介
### file share 项目是一个基于`ipfs`和`dfinity`结合的去中心化视频，图片分享项目
## 功能描述
### 1、存储
用户分享的图片和视频内容通过调用前端接口存储在ipfs上，并把ipfs返回的凭证内容存储在dfinity合约上面
### 2、社交
用户分享自己的视频，图片，其他用户能够在分享的内容下面评论，也可以给用户发私信，在看到喜欢的内容时，可以通过dfinity钱包进行打赏
## 项目计划
1、dfinity合约开发  
2、前端调用ipfs  
3、测试联调
## 项目运行
```
# 启动环境
dfx start --clean --background  
dfx deploy 
#创建用户
dfx canister file_share call create_user '{"zyx",""}'
# 发送消息
dfx canister call file_share send_message '("tll",record{send_time = 123; content = "test send message"; sender = "zyx";id=1 })'
# 查看跟tll的消息记录
dfx canister call file_share  get_messages '("tll")'
# 删除跟tll的消息记录
dfx canister call file_share  delete_message_with_user  '("tll")'
# 发布分享
dfx canister call file_share share_message '(record{shared_time=123;content="share message";vedio_cid="www.baidu.com";image _cid="";is_private=false})'
# 删除分享
dfx canister call file_share delete_message '(1)'

```
