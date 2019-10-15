function validateEmailValue(email) {
  var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(String(email).toLowerCase());
}

function validateEmail(el) {
  var $result = $(el).next('.validation-msg');
  var email = el.value;

  if (validateEmailValue(email)) {
    el.classList.remove('input--invalid');
    $result.text('');
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
    if (input.classList.contains('validate-email')) checks.push(validateEmail(input));
  });

  if (!checks.includes(false)) form.submit();
}

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll('.validate-form').forEach(function(el) {
    el.onsubmit = function(e) { validateForm(e, el) }
  });
});
