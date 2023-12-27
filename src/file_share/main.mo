import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Type "type";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Int32 "mo:base/Int32";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Nat32 "mo:base/Nat32";
actor {
  var users = HashMap.HashMap<Text, Principal>(0, Text.equal, Text.hash);
  var user_pool = HashMap.HashMap<Principal, Type.User>(0, Principal.equal, Principal.hash);
  public shared (msg) func create_user(user_name : Text, description : Text) : async Bool {
    switch (user_pool.get(msg.caller)) {
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
        users.put(user_name, msg.caller);
        user_pool.put(
          msg.caller,
          {
            user_name = user_name;
            description = description;
            create_time = Time.now();
            var shaerd_message_number = 0;
            var follower = [];
            var liked_total = 0;
            var like_list = [];
            var followering = [];
            var collections = [];
            var shared_message = HashMap.HashMap<Nat, Type.SharedMessage>(0, Nat.equal, Hash.hash);
            var message = m;
          },
        );

      };
    };
    Debug.print("create user success user name = " #user_name);
    true

  };
  public shared(msg) func get_user_info():async ?Type.UserInfo{
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        var share_messages:[Nat] = [];
        for(s in user.shared_message.keys()){
         share_messages :=  Array.append(share_messages,Array.make<Nat>(s));
        };
        Debug.print("user name = " #user.user_name);
        let user_info  : Type.UserInfo ={
        create_time = user.create_time;
        user_name = user.user_name;
        description = user.description;
        like_list = user.like_list;
        liked_total=user.liked_total;
        shaerd_message_number = user.shared_message.size();
        follower = user.follower;
        followering = user.followering;
        collections = user.collections;
        shared_message = share_messages;
        };
        ?user_info
      };
      case null {
        Debug.print("user not exist ");
        null
      };
    };
  };

  public shared (msg) func follow_user(user_name : Text) : async Bool {
    label check for (u in users.keys()) {
      if (u == user_name) {
        break check;
      } else {
        Debug.print("user name not exists ,follow failed");
        return false;
      };

    };
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        if (user.user_name == user_name) {
          Debug.print("Can't follow yourself");
          return false;
        };
        user.follower := Array.append<Text>(user.follower, Array.make<Text>(user_name));
        user_pool.put(
          msg.caller,
          user,
        );
        return true;
      };
      case _ false;
    };
  };
  public shared (msg) func get_follow_user(user_name : Text) : async ?[Text] {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        ?user.follower;
      };
      case _ null;
    };
  };
  public func get_follow_number(user_name : Text) : async Nat {
    0;
  };
  public shared ({ caller }) func send_message(to : Text, message : Type.Message) : async Bool {
   var  p = "";
    switch (users.get(to)) {
      case (?recv) {
          p := Principal.toText(recv);
        };
        case null { Debug.print("user" # to # " not created "); return false }; 
      };
      
    switch (user_pool.get(caller) ,user_pool.get(Principal.fromText(p))) {

      case (?user,?receiver) {
        switch (user.message.get((user.user_name, to)),receiver.message.get((to,user.user_name))) {
          case (?messages_from,?message_to) {
           receiver.message.put((to,user.user_name), Array.append<Type.Message>(message_to, Array.make<Type.Message>(message)));
            user.message.put((user.user_name, to), Array.append<Type.Message>(messages_from, Array.make<Type.Message>(message)));
          };
          case (null,null) {
            receiver.message.put((to,user.user_name), Array.make<Type.Message>(message));
            user.message.put((user.user_name, to), Array.make<Type.Message>(message));
          };
          case (_,_){};
        };
        user_pool.put(caller, user);
        true;
      };
      case (null,null)  false;
      case(_,_) false;
    };
  };

  public shared(msg) func get_chat_list():async ?[Text]{
    switch (user_pool.get(msg.caller)) {
      case(?user){
        var chat_list :[Text] = [];
        for(chat in user.message.keys()){
          chat_list := Array.append(chat_list,Array.make(chat.1))
        };
        return ?chat_list;
      };
      case null return null
    };
    null
  };
  public shared (msg) func get_messages(to : Text) : async ?[Type.Message] {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        Debug.print("get message from to =  " #to);
        user.message.get((user.user_name, to));
      };
      case null null;
    };

  };
  public shared (msg) func delete_message_with_user(to : Text) : async Result.Result<(), Type.OptionError> {
    switch (user_pool.get(msg.caller)) {
      case (?u) {
        switch (u.message.get((u.user_name, to))) {
          case (?messages) {
            u.message.delete((u.user_name, to));
            user_pool.put(msg.caller, u);
          };
          case null return #err(#NotExistsErr("to not exists "));
        };
      };
      case null return #err(#NotExistsErr("sender not exists "));
    };
    #ok;
  };

  public shared (msg) func share_message(content : Text, video_cid : Text, image_cid : Text, is_private : Bool) : async ?Nat {
    var id : Nat = 0;
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.shaerd_message_number += 1;
        id := user.shaerd_message_number;
        let message : Type.SharedMessage = {
          content = content;
          var is_private = is_private;
          video_cid = video_cid;
          image_cid = image_cid;
          shared_time = Time.now();
          var liked = 0;
          var comment = [];
        };
        user.shared_message.put(user.shaerd_message_number, message);
        user_pool.put(msg.caller, user);
      };
      case null return null;
    };
    ?id;
  };

  public shared (msg) func set_shared_message_state(message_id : Nat, state : Bool) : async Bool {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        switch (user.shared_message.get(message_id)) {
          case (?message) {
            message.is_private := state;
            user.shared_message.put(message_id, message);
            user_pool.put(msg.caller, user);
          };
          case null {
            Debug.print("message id not exists any message ");
            return false;
          };
        };
      };
      case null return false;
    };
    true;
  };
  public shared (msg) func get_shared_message_by_id(user_name : Text, message_id : Nat) : async ?(Text, Text, Text, Int32) {
    switch (users.get(user_name)) {
      case (?id) {
        switch (user_pool.get(id)) {
          case (?user) {
            switch (user.shared_message.get(message_id)) {
              case (?message) {
                if (id == msg.caller or message.is_private == false) {
                  return ?(message.content, message.video_cid, message.image_cid, message.liked);
                } else {
                  Debug.print("message id " # Nat.toText(message_id) # "is private");
                  null;
                };
              };
              case null {
                Debug.print("message id not exists any message ");
                return null;
              };
            };
          };
          case _ null;
        };
      };

      case null { Debug.print("user not exists"); return null }

    };

  };

  public shared (msg) func like_shared_message(user_name : Text, message_id : Nat) : async Bool {
    let user_principal = await get_user_principal(user_name);
    switch (user_principal) {
      case null return false;
      case (?p) {
        switch (user_pool.get(p)) {
          case (?u) {
            switch (u.shared_message.get(message_id)) {
              case (?n) {
                // 判断caller 是否存在
                switch (user_pool.get(msg.caller)) {
                  case (?caller) {
                    // 是否已喜欢
                    let index = Array.indexOf<(Text, Nat)>((user_name, message_id), caller.like_list, func(to : ((Text, Nat), (Text, Nat))) { return to.0.0 == to.1.0 and to.0.1 == to.1.1 });
                    switch (index) {
                      case (?exists) {
                        Debug.print("caller has liked this message ");
                        return false;
                      };
                      case null {
                        caller.like_list := Array.append(caller.like_list, Array.make((user_name, message_id)));
                        user_pool.put(msg.caller, caller);
                      };

                    };
                  };
                  case null return false;
                };
                u.liked_total += 1;
                n.liked += 1;
                u.shared_message.put(message_id, n);
                user_pool.put(p, u);
                return true;
              };
              case null { Debug.print("message id not exists"); return false };
            };

          };
          case null {
            Debug.print("user_name = " #user_name # "not exists");
            return false;
          };
        };
      };
    };

    return true;
  };
  public shared(msg) func collect_shared_message(user_name:Text,message_id:Nat):async Bool{
    true
  };
  public shared(msg) func cancel_collect_shared_message(user_name:Text,message_id:Nat):async Bool{
    true
  };
  public shared(msg) func get_like_number():async Nat32{
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        return user.liked_total
      };
      case null return 0;
    };
     return 0
  };
  public shared (msg) func get_like_list() : async ?[(Text, Nat)] {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        return ?user.like_list
      };
      case null return null;
    };
     return null;
  };
  public shared (msg) func get_shared_message_number() : async Nat {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.shared_message.size();
      };
      case _ 0;
    };
  };

  public shared (msg) func delete_shared_message(message_id : Nat) : async Bool {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.shared_message.delete(message_id);
        return true;
      };
      case _ return false;
    };
    true;
  };
  public shared (msg) func delete_all_shared_message() : async Bool {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.shaerd_message_number := 0;
        user.shared_message := HashMap.HashMap<Nat, Type.SharedMessage>(0, Nat.equal, Hash.hash);
        return true;
      };
      case _ return false;
    };
    true;
  };

  public shared (msg) func comment(commenter : Text, message_id : Nat, content : Type.Message) : async Result.Result<?Type.Replay, Type.OptionError> {
    switch (users.get(commenter)) {
      case (?m) {
        switch (user_pool.get(msg.caller)) {
          case (?user) {
            switch (user.shared_message.get(message_id)) {
              case (?c) {
                if (c.is_private and m != msg.caller) {
                  return #err(#PrivateErr("message is private "));
                } else {
                  c.comment := Array.append(c.comment, Array.make(content));
                  user.shared_message.put(message_id, c);
                  var replay : Type.Replay = {
                    shared_message_id = message_id;
                    comment_id = content.id;
                  };
                  return #ok(?replay);
                };
              };
              case null return #err(#NotExistsErr("message not exists "));
            };

          };
          case _ return #err(#NotExistsErr("message not exists"));
        };
      };
      case null return #err(#NotExistsErr("user not exists"));
    };

    #ok(null);
  };

  public shared (msg) func get_comment(message_id : Nat) : async ?[Type.Message] {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        switch (user.shared_message.get(message_id)) {
          case (?message) {
            ?message.comment;
          };
          case null null;
        };
      };
      case null null;
    };
  };
  private func get_user_principal(user_name : Text) : async ?Principal {
    switch (users.get(user_name)) {
      case (?user) ?user;
      case null null;
    };
  };
};
