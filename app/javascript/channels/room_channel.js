import consumer from "./consumer"

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
    if(jdata["type"]=="message" && jdata["chat"]==document.getElementById("roomno").value){
      document.getElementById("messages").innerHTML+="<div class=\"message\"><p>"+jdata["author"]+"</p><p>"+jdata["message"]+"</p></div>";
      if(document.getElementById("nickname").value==jdata["author"]){
        document.getElementById("new_message").reset()
      }
    }
    var m=document.getElementsByClassName("message");
    m[m.length-1].scrollIntoView(false);
  }
});
