App.ksp = App.cable.subscriptions.create("KspChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(data) {
    // Called when there's incoming data on the websocket for this channel
  },

  hover: function() {
    return this.perform('hover');
  },

  orbit: function() {
    return this.perform('orbit');
  },

  crash: function() {
    return this.perform('crash');
  }
});
