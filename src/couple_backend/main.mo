import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import Type "type";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import List "mo:base/List";
actor {
  var UserPool = HashMap.HashMap<Principal, Type.User>(0, Principal.equal, Principal.hash);
  public shared (msg) func create_user(user_name : Text, description : Text) : async Bool {
    switch (UserPool.get(msg.caller)) {
      case (?user) {
        Debug.print("user exists");
        return false;
      };
      case (null) {
        let m = HashMap.HashMap<(Text, Text), [Type.Message]>(
          0,
          func(to : (Text, Text), from : (Text, Text)) {
            Text.equal(to.0, from.0) and Text.equal(to.1, from.1)
          },
          func(k : (Text, Text)) {
            Text.hash(Text.concat(k.0, k.1));
          },
        );
        UserPool.put(
          msg.caller,
          {
            user_name = user_name;
            description = description;
            create_time = Time.now();
            var state = "";
            is_single = true;
            var follower = List.nil<Text>();
            var followering = [""];
            var collections = [""];
            var couple = "";
            var shared_message = {
              shared_time = 0;
              content = "";
              target = "";
              comment = [{
                send_time = 0;
                content = "";
                sender = "";
              }];
            };
            message = m;
          },
        );

      };
    };
    Debug.print("create user success user name = "#user_name);
    true

  };

  public shared(msg) func get_user():async Text{
    switch(UserPool.get(msg.caller)){
    case (?user){
      Debug.print("user name = "#user.user_name);
      user.user_name;
    };
    case null {
       Debug.print("user not exist ");
     ""
    };
    };
  };
  public shared(msg) func set_status(state:Text):async Bool{
    switch(UserPool.get(msg.caller)){
      case(?user){
        user.state := state;
        UserPool.put(
          msg.caller,
          user
        );
      };
      case null{
      return  false;
      }
    };
    true
  };
  public shared(msg)func  get_state():async Text{
    switch(UserPool.get(msg.caller)){
      case(?user){
        user.state;
      };
      case null "";
    }
  };
  public shared(msg)func  follow_user(user_name :Text):async Bool{
    switch(UserPool.get(msg.caller)){
      case(?user){
        let  follower = List.push(user_name,user.follower);
        user.follower := follower;
        UserPool.put(
          msg.caller,user);
          return true
      };
      case _ false;
    };
  };
};



/*
创建用户
func create_user
设置状态
func set_status
修改描述
func set_description
关注用户
func follow_user
查看关注列表
func check_follower
转账
func transfer
发送消息
func send_message
查看消息列表
func check_messages
成为情侣
func be_couple
收藏
func collect_moment
分享内容
func share_statements
提醒
成为情侣之后分享的状态会提醒另一个人
func remind
从会话列表中删除
func remove_messager
解除关系
func remove_relationship

*/
