//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require notifications
//= require select2-full
//= require full_calendar
//= require agent_notifications

$(document).ready(function(){
  $('#modal--toggle-index').attr('checked', false);

  // This will check for opt in permissions wherever
  // the Whatsapp button is located in the dashboard,
  // but the chat.
  $('.ws-contact').click(function(){
    let noBalance = false;
    if (ENV['INTEGRATION'] == '0' && !$(this).data('open_chat') && parseFloat($(this).data('ws_balance')) <= 1) {
      noBalance = true;
    } else if (ENV['INTEGRATION'] == '1' && parseFloat($(this).data('ws_balance')) <= -10) {
      noBalance = true;
    }

    if (noBalance) {
      if (confirm('Saldo insuficiente, ¿deseas hacer una recarga?')) {
        window.location.pathname = `/retailers/${ENV.SLUG}/pricing`;
      }
      return false;
    }

    if ($(this).data('whatsapp_opt_in') || ENV['INTEGRATION'] == '0') return true;

    if (confirm('Tengo el permiso explícito de enviar mensajes a este número (opt-in)')) {
      var id = $(this).data('customer_id');
      var token =  $('meta[name="csrf-token"]').attr('content');

      // Send the request to activate opt-in
      $.ajax({
        url: '/api/v1/accept_optin_for_whatsapp/' + id,
        type: 'PATCH',
        beforeSend: function(xhr) {
          xhr.setRequestHeader('X-CSRF-Token', token)
        },
        statusCode: {
          200: function(data) {
            $(`[data-customer_id="${data.customer_id}"]`).data('whatsapp_opt_in', true)
            $('#modal--toggle-index').attr('checked', true);
            return true;
          },
          400: function(e) {
            $('#modal--toggle-index').attr('checked', false);
            alert(e.responseJSON['error']);
            return false;
          }
        }
      });
    } else {
      return false;
    }
  })

  $('.calendar-button').click(function(){
    document.querySelector('#dropdown__menu--header').checked = false;
    fullCalendarSidebar.refetchEvents();
    $('#calendar-container').toggle();
  })

  document.getElementById('calendar-background').onclick = function() {
    $('#calendar-container').toggle();
  }
})
