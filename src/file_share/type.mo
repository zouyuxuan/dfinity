import Text "mo:base/Text";
import Int32 "mo:base/Int32";
import Map "mo:base/HashMap";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";

module {
   
    public type Message ={
        id :Int32;
        send_time :Int;
        content:Text;
        sender:Text;
    };
     public type SharedMessage = {
        var is_private:Bool;
        shared_time : Int;
        content : Text;
        video_cid :Text;
        image_cid :Text;
        var liked:Int32;
        var comment: [Message];
    };
    public type OptionError ={
        #PrivateErr:Text;
        #NotExistsErr:Text;
    };
    
    public type User = {
        create_time : Int;
        user_name : Text;
        description : Text;
        var like_list:[(Text,Nat)];
        var liked_total:Nat32;
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
