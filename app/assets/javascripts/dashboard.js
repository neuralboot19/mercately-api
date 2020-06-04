//= require notifications

$(document).ready(function(){
  $('#modal--toggle').attr('checked', false);

  // This will check for opt in permissions wherever
  // the Whatsapp button is located in the dashboard,
  // but the chat.
  $('.ws-contact').click(function(){
    if ($(this).data('whatsapp_opt_in') || ENV['INTEGRATION'] == '0')
      return true;

    if (confirm('Tengo el permiso explicito de enviar mensajes a este número (opt-in)')) {

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
          200: function() {
            $('.ws-contact').data('whatsapp_opt_in', true);
            $('#modal--toggle').attr('checked', true);
            return true;
          },
          400: function(e) {
            $('#modal--toggle').attr('checked', false);
            alert(e.responseJSON['error']);
            return false;
          }
        }
      });
    } else {
      return false;
    }
  })
})
