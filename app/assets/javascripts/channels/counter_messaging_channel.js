this.App.counter = this.App.cable.subscriptions.create('CounterMessagingChannel', {
  received(data) {
    $(`#sidebar #sidebar__menu ${data['identifier']}`).html(data['total']);
    var currentTotal = $('#sidebar #sidebar__menu #item__cookie_total').html();

    if (data['action'] === 'add') {
      currentTotal = parseInt(currentTotal) + 1;
    } else {
      currentTotal = parseInt(currentTotal) - parseInt(data['q']);
    }

    $('#sidebar #sidebar__menu #item__cookie_total').html(currentTotal);
  }
});
