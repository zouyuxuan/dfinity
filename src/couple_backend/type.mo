import Text "mo:base/Text";
import Int32 "mo:base/Int32";
import Map "mo:base/HashMap";
import Bool "mo:base/Bool";
import List "mo:base/List";
import Array "mo:base/Array";

module {
   
    public type Message ={
        send_time :Int;
        content:Text;
        sender:Text;
    };
     public type SharedMessage = {
        shared_time : Int;
        content : Text;
        target : Text;
        comment:[Message];
    };
    public type OptionState ={
        #Ok:Text;
        #Err:Text;
    };
    public type User = {
        create_time : Int;
        user_name : Text;
        is_single : Bool;
        description : Text;
        var state : Text;
        var follower : List.List<Text>;
        var followering : [Text];
        var collections : [Text];
        var shared_message : SharedMessage;
        var couple:Text;
        message:Map.HashMap<(Text,Text),[Message]>;
    };
};
