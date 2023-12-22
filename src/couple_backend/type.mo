import Text "mo:base/Text";
import Int32 "mo:base/Int32";
import Map "mo:base/HashMap";
import Array "mo:base/Array";

module {
   
    public type Message ={
        id :Int32;
        send_time :Int;
        content:Text;
        sender:Text;
    };
     public type SharedMessage = {
        shared_time : Int;
        content : Text;
        video_cid :Text;
        image_cid :Text;
        var comment: [Message];
    };
    public type OptionError ={
        #NotExistsErr:Text;
    };
    public type User = {
        create_time : Int;
        user_name : Text;
        description : Text;
        var shaerd_message_number : Nat;
        var  follower : [Text];
        var followering : [Text];
        var collections : [(Text,Nat)];
        var shared_message : Map.HashMap<Nat,SharedMessage>;
        var message:Map.HashMap<(Text,Text),[Message]>;
    };
    public type Replay = {
        shared_message_id :Nat;
        comment_id :Int32;
    };
};
