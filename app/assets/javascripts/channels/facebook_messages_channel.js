this.App.asd = this.App.cable.subscriptions.create({ channel: 'FacebookMessagesChannel', id: 45 }, {
  received: function(data) {
    console.log('FacebookMessagesChannel');
    console.log(data);
  }
});
