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
    document.getElementById("messages").innerHTML+="<div class=\"message\"><p>"+data.content+"</p></div>";
    var m=document.getElementsByClassName("message");
    m[m.length-1].scrollIntoView(false);
  }
});
