# file share

## 项目简介
### file share 项目是一个基于`ipfs`和`dfinity`结合的去中心化视频，图片分享项目

## 功能描述
### 1、存储
用户分享的图片和视频内容通过调用前端接口存储在[ipfs](https://ipfs.tech/)上，并把ipfs返回的凭证内容存储在dfinity合约上面
### 2、社交
用户分享自己的视频，图片，其他用户能够在分享的内容下面评论，私信，在看到喜欢的内容时，可以通过dfinity钱包进行打赏
## 项目计划
### motoko合约开发  
- 定义项目框架，添加用户数据  
- 实现用户状态发布，分享，私信，点赞，评论等业务功能开发  
- 实现icp 代币发送接收功能  
### 前端开发
-  搭建前端框架，添加ipfs接口，实现数据在ipfs上进行存取   
-  实现前端网页和motoko合约进行交互  
### 测试联调
- 调试接口功能，优化前后端代码  
### canister 升级  
- 用户数据转移
## 里程碑
- [x] 2023/12/14-2023/12/25 完成motoko合约用户部分功能开发 
- [ ] 2024/1/2-2024/2/24 完成前端页面开发
- [ ] 2024/2/25-2024/3/10 前端页面和合约联调
- [ ] canister 升级

```
# 启动环境
dfx start --clean --background  
dfx deploy 
#创建用户
dfx canister  call file_share  create_user '("zyx","")'
# 发送消息
dfx canister call file_share send_message '("tll",record{send_time = 123; content = "test send message"; sender = "zyx";id=1 })'
# 查看会话列表
dfx canister call file_share get_chat_list
# 查看跟tll的消息记录
dfx canister call file_share  get_messages '("tll")'
# 删除跟tll的消息记录
dfx canister call file_share  delete_message_with_user  '("tll")'
# 发布分享
dfx canister call file_share share_message '("share message","www.baidu.com","",false)'
# 获取分享
dfx canister call file_share get_shared_message_by_id '("zyx",1)'
# 设置分享状态私密
dfx canister call file_share set_shared_message_state '(1,true)'
# 点赞状态
dfx canister call file_share like_shared_message '("zyx",1)'
# 查看获赞数量
dfx canister call file_share get_like_number 
# 查看点赞列表
dfx canister call file_share get_like_list
# 评论分享
dfx canister call file_share comment '("zyx",1,record{id=1;send_time=123;content="comment";sender="tll"})'
# 查看评论
dfx canister call file_share get_comment '(1)' 
# 删除分享
dfx canister call file_share delete_shared_message '(1)'
# 删除所有分享
dfx canister call file_share delete_all_shared_message 

```
