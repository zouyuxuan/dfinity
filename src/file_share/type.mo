import Text "mo:base/Text";
import Int32 "mo:base/Int32";
import Map "mo:base/HashMap";
import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";

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
        var comment: Buffer.Buffer<Message>;
    };
    public type OptionError ={
        #PrivateErr:Text;
        #NotExistsErr:Text;
    };
    public type UserInfo = {
        chat_limit_number:Int32;
        storage_cast:Int32;
        storage_last:Int32;
        storage_total:Int32;
        create_time : Int;
        user_name : Text;
        description : Text;
        like_list:[(Text,Nat)];
        liked_total:Nat32;
        shared_message_number : Nat;
        follower : [Text];
        followering : [Text];
        shared_message : [Nat]
    };
    public type Update_Level = {
        #Silver;
        #Gold;
        #Diamond
    };
    public type User = {
        create_time : Int;
        user_name : Text;
        description : Text;
        var chat_limit_number:Int32;
        var storage_cast: Int32;
        var storage_total:Int32;
        var level:Update_Level;
        var update_time : Int;
        var like_list:Buffer.Buffer<(Text,Nat)>;
        var liked_total:Nat32;
        var shared_message_number : Nat;
        var follower : Buffer.Buffer<Text>;
        var followering : [Text];
        var shared_message : Map.HashMap<Nat,SharedMessage>;
        var message:Map.HashMap<(Text,Text),Buffer.Buffer<Message>>;
    };
    public type Replay = {
        shared_message_id :Nat;
        comment_id :Int32;
    };
};
