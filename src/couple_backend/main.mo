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
  stable var users : [Text] = [];
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
        users := Array.append(users, Array.make(user_name));
        user_pool.put(
          msg.caller,
          {
            user_name = user_name;
            description = description;
            create_time = Time.now();
            var shaerd_message_number = 0;
            var state = "";
            var follower = [];
            var followering = [];
            var collections = [];
            var couple = "";
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
  public shared (msg) func set_status(state : Text) : async Bool {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.state := state;
        user_pool.put(
          msg.caller,
          user,
        );
      };
      case null {
        return false;
      };
    };
    true;
  };
  public shared (msg) func get_state() : async Text {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.state;
      };
      case null "";
    };
  };
  public shared (msg) func follow_user(user_name : Text) : async Bool {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
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

  public shared (msg) func share_message(content:Text,vedio_url:Text) : async ?Nat {
    var id:Nat = 0;
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        user.shaerd_message_number += 1;
        id :=user.shaerd_message_number;
        let message:Type.SharedMessage={
          content = content;
          vedio_url = vedio_url;
          shared_time = Time.now();
          var comment = [];
        };
        user.shared_message.put(user.shaerd_message_number, message);
        user_pool.put(msg.caller, user);
      };
      case null return null;
    };
    ?id ;
  };
  public shared (msg) func get_shared_message(message_id : Nat) : async ?(Text,Text){
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        switch(user.shared_message.get(message_id)){
          case(?message){
             ?(message.content,message.vedio_url);
          };
          case null null;
        };
      };
      case _ null;
    };
  };
  public shared (msg) func comment(message_id : Nat, content : Type.Message) : async Result.Result<(), Type.OptionError> {
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        switch (user.shared_message.get(message_id)) {
          case (?c) {
            c.comment := Array.append(c.comment,Array.make(content));
            user.shared_message.put(message_id, c);
            return #ok;
          };
          case null return #err(#NotExistsErr("message not exists "));
        };

      };
      case _ return #err(#NotExistsErr("message not exists"));
    };
    #ok;
  };

  public shared(msg) func get_comment(message_id:Nat):async ?[Type.Message]{
    switch (user_pool.get(msg.caller)) {
      case (?user) {
        switch (user.shared_message.get(message_id)) {
          case(?message){
            ?message.comment;
          };
          case null null;
        };
      };
      case null null
     };
  }
};
