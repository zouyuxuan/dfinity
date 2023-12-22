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

  public shared (msg) func get_user_name() : async Text {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        Debug.print("user name = " #user.user_name);
        user.user_name;
      };
      case null {
        Debug.print("user not exist ");
        "";
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
  public shared (msg) func get_follow_user() : async ?[Text] {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        ?user.follower;
      };
      case _ null;
    };
  };
  public shared ({ caller }) func send_message(to : Text, message : Type.Message) : async Bool {
    switch (user_pool.get(caller)) {

      case (?user) {
        switch (user.message.get((user.user_name, to))) {
          case (?messages) {
            user.message.put((user.user_name, to), Array.append<Type.Message>(messages, Array.make<Type.Message>(message)));
          };
          case null {
            user.message.put((user.user_name, to), Array.make<Type.Message>(message));
          };
        };
        user_pool.put(caller, user);
        true;
      };
      case null false;
    };
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

  public shared (msg) func share_message(content : Text, video_cid : Text, image_cid : Text) : async ?Nat {
    var id : Nat = 0;
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.shaerd_message_number += 1;
        id := user.shaerd_message_number;
        let message : Type.SharedMessage = {
          content = content;
          video_cid = video_cid;
          image_cid = image_cid;
          shared_time = Time.now();
          var comment = [];
        };
        user.shared_message.put(user.shaerd_message_number, message);
        user_pool.put(msg.caller, user);
      };
      case null return null;
    };
    ?id;
  };
  public func get_shared_message_by_id(user_name : Text, message_id : Nat) : async ?(Text, Text, Text) {
    switch (users.get(user_name)) {
      case (?id) {
        switch (user_pool.get(id)) {
          case (?user) {
            switch (user.shared_message.get(message_id)) {
              case (?message) {
                ?(message.content, message.video_cid, message.image_cid);
              };
              case null {Debug.print("message id not exists any message ");return null};
            };
          };
          case _ null;
        };
      };
      
      case null {Debug.print("user not exists");return null} 

    };

  };

  public shared (msg) func get_shared_message_number() : async Nat {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.shared_message.size();
      };
      case _ 0;
    };
  };
  public shared (msg) func comment(message_id : Nat, content : Type.Message) : async Result.Result<?Type.Replay, Type.OptionError> {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        switch (user.shared_message.get(message_id)) {
          case (?c) {
            c.comment := Array.append(c.comment, Array.make(content));
            user.shared_message.put(message_id, c);
            var replay : Type.Replay = {
              shared_message_id = message_id;
              comment_id = content.id;
            };
            return #ok(?replay);
          };
          case null return #err(#NotExistsErr("message not exists "));
        };

      };
      case _ return #err(#NotExistsErr("message not exists"));
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
};
