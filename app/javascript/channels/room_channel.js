import consumer from "./consumer"
function $(e){return document.getElementById(e)}

consumer.subscriptions.create("RoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    $("err").innerHTML="Connection Lost. Try reloading the page to restore connection.";
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    var jdata=JSON.parse(data.content);
    console.log()
    console.log(jdata["type"]);
    if(jdata["chat"]==$("roomno").value){
      if(jdata["type"]=="perm"){
        if(!($("nickname").value in jdata["perm"])){
          alert("You no longer have access to this chat.")
          location.reload();
        }
      }
      else if(jdata["type"]=="mute"){
        console.log("testing")
        console.log(jdata)
        if(($("nickname").value in jdata["perm"])){
          console.log("isin")
          $("message_content").disabled=true;
          $("submitbutton").disabled=true;
        }
        else{
          console.log("isntin")
          $("message_content").removeAttribute('disabled');
          $("submitbutton").removeAttribute('disabled');
        }
      }
      else if(jdata["type"]=="message"){
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
        if("true"==$("canwhisper").content || $("nickname").value==jdata["author"] || $("nickname").value==jdata["recipient"]){
          var classtext=""
          if($("nickname").value==jdata["author"]){
            $("new_message").reset()
            classtext=" class=\"self\""
          } 
          $("messages").innerHTML+="<div class=\"message\"><p"+classtext+">(whisper to "+jdata["recipient"]+") "+jdata["author"]+"</p><p class=\"whisper\">"+jdata["message"]+"</p></div>";
        }
        else{
          $("messages").innerHTML+="<div class=\"hint\"><p>"+jdata["author"]+" whispered to "+jdata["recipient"]+"</p></div>";
        }
      }
      var m=document.getElementsByClassName("message");
      m[m.length-1].scrollIntoView(false);
    }
  }
});
