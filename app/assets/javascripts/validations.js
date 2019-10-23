// Setea el input como valido y pone un espacio como mensaje
function setInputValid(el) {
  var $result = $(el).siblings('.validation-msg')

  el.classList.remove('input--invalid');
  $result.html('&nbsp;');
}

function onlyNumber(e) {
  var keyCode = (e.which) ? e.which : e.keyCode
  if (keyCode != 46 && keyCode > 31 && (keyCode < 48 || keyCode > 57)) {
    e.preventDefault();
    return false;
  }
  return true;
}

function inputRequired(el) {
  var $result = $(el).siblings('.validation-msg')

  if (!!el.value) {
    return true;
  } else {
    el.classList.add('input--invalid');
    $result.text('Campo requerido');
    return false;
  }
}

function validateEmailValue(email) {
  var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(String(email).toLowerCase());
}

function validateEmail(el) {
  var $result = $(el).siblings('.validation-msg')
  var email = el.value;

  if (validateEmailValue(email) || email == '') {
    return true;
  } else {
    el.classList.add('input--invalid');
    $result.text('Debe ser un email valido');
    return false;
  }
}

// Valida si son necesarias las imagenes en el form de producto
function validateImages(form) {
  if (form.id !== 'new_product' && form.id.indexOf('edit_product') === -1) {
    return true;
  }

  productId = document.getElementById('product_id');
  meliStatus = document.getElementById('product_meli_status');
  uploadProduct = document.getElementById('product_upload_product');
  uploadImages = document.getElementById('uploadedImages');
  message = document.getElementById('product_images_error');

  if (!productId.value && (meliStatus || (uploadProduct && uploadProduct.checked)) && !uploadImages.value) {
    $(message).text('Imágenes requeridas');
    return false;
  }

  $(message).html('&nbsp;');
  return true;
}

// Subscripcion del formulario a validaciones
function validateForm(e, form) {
  e.preventDefault();

  // checks es un arreglo de booleans que vigila si todas las validaciones pasaron
  checks = [];

  document.querySelectorAll(`#${form.id} input, #${form.id} textarea`).forEach(function(input) {
    // inputChecks es un arreglo de booleans que vigila si todas las validaciones del input pasaron
    inputChecks = [];

    if (!input.disabled) {
      // Para agregar una validacion nueva debes chequear si el input tiene la clase 'validate-${nombre de la validacion}'
      // La funcion de validacion debe retornar true o false segun sea el caso (false si falla, true si tuvo exito)
      // El valor de la funcion de validacion debe empujarse a los arreglos checks e inputChecks

      if (input.classList.contains('validate-required')){
        checks.push(inputRequired(input));
        inputChecks.push(inputRequired(input));
      }
      if (input.classList.contains('validate-email')) {
        checks.push(validateEmail(input));
        inputChecks.push(validateEmail(input));
      }

      if (!inputChecks.includes(false)) setInputValid(input);
    }
  });

  document.querySelectorAll(`#${form.id} .validate-association-presence`).forEach(function(association) {
    var $result = $(association).siblings('.validation-msg');
    $result.html('&nbsp;');

    if ($(association).find('.association-item').length < 1) {
      $result.html('Debe agregar al menos uno');
      checks.push(false);
    }
  });

  checks.push(validateImages(form));

  if (!checks.includes(false)) form.submit();
}

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll('.validate-form').forEach(function(el) {
    el.onsubmit = function(e) { validateForm(e, el) }
  });
});
