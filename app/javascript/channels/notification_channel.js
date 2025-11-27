// app/javascript/channels/notifications_channel.js
import consumer from "./consumer"

consumer.subscriptions.create(
  { channel: "NotificationsChannel", user_id: currentUserId },
  {
    connected() {
      console.log("Connected to NotificationsChannel")
    },

    received(data) {
      const container = document.getElementById("notification-container")
      if (container) {
        const div = document.createElement("div")
        div.className = "alert alert-info"
        div.innerText = data.message
        container.prepend(div)
        setTimeout(() => div.remove(), 5000)
      }
    }
  }
)
