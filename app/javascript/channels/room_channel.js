import consumer from "./consumer"

function $(e){return document.getElementById(e)}
document.onload=function(){var mt=document.getElementsByClassName("message");
    mt[mt.length-1].scrollIntoView(false);}

consumer.subscriptions.create("RoomChannel", {
  connected() {
    console.log("LIVE")
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    var jdata=JSON.parse(data.content);
    if(jdata["chat"]==$("roomno").value){
      if(jdata["type"]=="message"){
        var classtext=""
        if($("nickname").value==jdata["author"]){
          $("new_message").reset()
          classtext=" class=\"self\""
        }
        if(jdata["author"]==$("admin").content){
          classtext=" class=\"admin\""
        }
        $("messages").innerHTML+="<div class=\"message\"><p"+classtext+">"+jdata["author"]+"</p><p>"+jdata["message"]+"</p></div>";

      }
      else if(jdata["type"]=="whisper"){
        if($("nickname").value==jdata["author"] || $("nickname").value==jdata["recipient"]){
          var classtext=""
          if($("nickname").value==jdata["author"]){
            $("new_message").reset()
            classtext=" class=\"self\""
          } 
          $("messages").innerHTML+="<div class=\"message\"><p"+classtext+">(Whisper)"+jdata["author"]+"</p><p class=\"whisper\">"+jdata["message"]+"</p></div>";
        }
        else{
          $("messages").innerHTML+="<div class=\"hint\"><p>You hear a quiet whisper.</p></div>";
        }
      }
      var m=document.getElementsByClassName("message");
      m[m.length-1].scrollIntoView(false);
    }
  }
});
