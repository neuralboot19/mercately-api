let auxReminder = [];
let reminderTemplateSelected = '';
let reminderTemplateType, reminderGupshupReminderId, reminderTemplateParams = {};

function setReminderTemplate(index) {
  reminderTemplateType = $(`#reminder-template-type-${index}`).html();
  reminderGupshupReminderId = $(`#reminder-gupshup-template-id-${index}`).html();

  if (reminderTemplateType === 'text') {
    $('#reminder-template-file').hide();
  } else {
    $('#reminder-template-file').show();
    $('#reminder-template_file').attr('accept', acceptedFiles());
  }

  $('#reminder-karix-templates-list').hide();
  $('#reminder-karix-template-edition').show();
  reminderTemplateSelected = $(`#reminder-original-template-${index}`).html();

  auxReminder = reminderTemplateSelected.split('');

  let new_array = reminderTemplateSelected.split('');
  let container = $('#reminder-karix-template-text').html('');
  container.append(`[${setReminderType()}] `);

  new_array.map((key, index) => {
    if (key === '*') {
      if (index === 0 || new_array[index - 1] !== '\\') {
        reminderTemplateParams[index] = '*';
        container.append(`<input value="" onChange="changeReminder(this, ${index})" />`);
      } else {
        container.append(`${key}`);
      }
    } else if (key === '\\') {
      if (index === (new_array.length - 1) || new_array[index + 1] !== '*') {
        container.append(`${key}`);
      } else {
        container.append('');
      }
    } else {
      container.append(`${key}`);
    }
  });
}

function changeReminder(e, id) {
  reminderTemplateSelected.split('').map((key, index) => {
    if (key == '*') {
      if (index == id && e.value && e.value !== '') {
        auxReminder[index] = reminderTemplateParams[index] = e.value;
      } else if (index == id && (!e.value || e.value === '')) {
        auxReminder[index] = reminderTemplateParams[index] = '*';
      }
    }
  })
}

function cancelReminder() {
  $('#reminder-karix-templates-list').show();
  $('#reminder-karix-template-edition').hide();
  auxReminder = [];
  reminderTemplateParams = {};
  reminderTemplateSelected = '';
  $('#reminder-modal--toggle').attr('checked', false);
  $('#reminder-modal--toggle-index').attr('checked', false);
  $('#reminder-template_file').val(null);
  $('body').toggleClass('o-hidden');
}

function sendReminder() {
  let allFilled = true;
  let file = null;

  auxReminder.map((key, index) => {
    if (key === '*' && (index === 0 || auxReminder[index - 1] !== '\\')) {
      allFilled = false;
    }
  })

  if (reminderTemplateType !== 'text') file = document.getElementById('template_file').files[0];

  fileSelected = reminderTemplateType === 'text' || file;

  if (allFilled && fileSelected) {
    let data = new FormData();
    data.append('reminder[customer_id]', $('#reminder-karix-customer-id').val() || $('#reminder-customer_id_index').val());
    let url;

    if (file) {
      if (reminderTemplateType === 'image' && validImage(file) === false) return;
      if (reminderTemplateType === 'file' && validFile(file) === false) return;

      data.append('reminder[file]', file);
      url = `/api/v1/karix_whatsapp_send_file/${$('#reminder-karix-customer-id').val() || $('#reminder-customer_id_index').val()}`;
    } else {
      url = '/api/v1/reminders';
    }
    params = Object.values(reminderTemplateParams);
    for (x in params) {
      data.append('reminder[content_params][]', params[x]);
    }

    data.append('reminder[whatsapp_template_id]', reminderGupshupReminderId);
    data.append('reminder[send_at]', $('#reminder-send_template_at').val());
    let timezone = new Date().toString().match(/([-\+][0-9]+)\s/)[1];
    data.append('reminder[timezone]', timezone);

    $.ajax({
      url: url,
      type: 'POST',
      processData: false,
      contentType: false,
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      data: data
    });

    cancelReminder();
  } else {
    message = allFilled ? 'Debe seleccionar una Imagen o archivo PDF' : 'Debe llenar todos los campos editables';
    alert(message);
  }
}

function validImage(file) {
  if (!['image/jpg', 'image/jpeg', 'image/png'].includes(file.type) || file.size > 5*1024*1024) {
    alert('La imagen debe ser JPG/JPEG o PNG, de máximo 5MB');
    return false;
  }

  return true;
}

function validFile(file) {
  if (file.type !== 'application/pdf' || file.size > 20*1024*1024) {
    alert('El archivo debe ser PDF, de máximo 20MB');
    return false;
  }

  return true;
}

function setReminderType() {
  if (reminderTemplateType === 'text') {
    return 'Texto';
  } else if (reminderTemplateType === 'image') {
    return 'Imagen';
  } else {
    return 'PDF';
  }
}

function acceptedFiles() {
  if (reminderTemplateType === 'image') {
    return 'image/jpg, image/jpeg, image/png';
  } else {
    return 'application/pdf';
  }
}

function showSelectingTags(input) {
  $('#reminder-add-customer-tags-container').show();
  $(input).hide();

  $('#reminder-customer_tag_ids').select2({
    placeholder: "Crea, selecciona o elimina etiquetas",
    language: "es",
    tags: true,
    maximumInputLength: 20
  });
}

$(document).ready(function() {
  $('#reminder-q_customer_tags_tag_id_in').select2({
    placeholder: "Selecciona una o más opciones",
    language: "es"
  });

  $('#reminder-customer_tag_ids').select2({
    placeholder: "Crea, selecciona o elimina etiquetas",
    language: "es",
    tags: true,
    maximumInputLength: 20
  });

  $('#reminder-show-custom-fields').on('change', function() {
    if (this.checked) {
      $('#reminder-show-custom-fields-label').text('Ocultar campos personalizados');
    } else {
      $('#reminder-show-custom-fields-label').text('Mostrar campos personalizados');
    }
  })
})
