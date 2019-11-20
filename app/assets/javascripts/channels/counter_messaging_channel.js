//import consumer from "./consumer"

this.App.room = this.App.cable.subscriptions.create('CounterMessagingChannel', {
  received(data) {
  }
});
