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

function validateForm(e, form) {
  e.preventDefault();
  checks = [];
  document.querySelectorAll(`#${form.id} input`).forEach(function(input) {
    inputChecks = [];
    if (!input.disabled) {
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

  if (!checks.includes(false)) form.submit();
}

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll('.validate-form').forEach(function(el) {
    el.onsubmit = function(e) { validateForm(e, el) }
  });
});
