this.App.counter = this.App.cable.subscriptions.create('CounterMessagingChannel', {
  received(data) {
    $(`#sidebar ${data['identifier']}, #sidebar--pc ${data['identifier']}`).html(data['total']);
    var currentTotal = $('#sidebar #item__cookie_total, #sidebar--pc #item__cookie_total').html();

    if (data['action'] === 'add') {
      currentTotal = parseInt(currentTotal) + 1;
    } else {
      currentTotal = parseInt(currentTotal) - parseInt(data['q']);
    }

    $('#sidebar .item__cookie_total, #sidebar--pc .item__cookie_total').html(currentTotal);
  }
});
