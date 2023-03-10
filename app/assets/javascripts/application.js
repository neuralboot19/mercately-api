// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require activestorage
//= require cocoon
//= require select2
//= require select2_es
//= require validations
//= require chartkick
//= require Chart.bundle
//= require moment
//= require moment/es.js
//= require daterangepicker
//= require emojionearea.min
//= require readMoreJS.min
//= require fullcalendar/main.min

$(document).ready(function () {
  $( "select" ).select2({
    placeholder: "Selecciona una opción",
    language: "es"
  });

  $(".no-select2").select2('destroy');

  $('.fieldset, .cocoon-load').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
    $(insertedItem).find("select").select2({
      placeholder: "Selecciona una opción",
      language: "es"
    });
  });
});

function ToastBuilder(options) {
  // options are optional
  var opts = options || {};

  // setup some defaults
  opts.defaultText = opts.defaultText || 'default text';
  opts.displayTime = opts.displayTime || 7000;
  opts.target = opts.target || 'body';

  return function (text) {
    $('<div/>')
      .addClass('toast')
      .prependTo($(opts.target))
      .text(text || opts.defaultText)
      .queue(function(next) {
        $(this).css({
          'opacity': 1
        });
        var topOffset = 100;
        $('.toast').each(function() {
          var $this = $(this);
          var height = $this.outerHeight();
          var offset = 10;
          $this.css('top', topOffset + 'px');
          $this.css('z-index', '99');

          topOffset += height + offset;
        });
        next();
      })
      .delay(opts.displayTime)
      .queue(function(next) {
        var $this = $(this);
        var width = $this.outerWidth() + 20;
        $this.css({
          'right': '-' + width + 'px',
          'opacity': 0
        });
        next();
      })
      .delay(600)
      .queue(function(next) {
        $(this).remove();
        next();
      });
  };
}
var showtoast = new ToastBuilder();

function getAjax(url, success) {
  var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
  xhr.open('GET', url);
  xhr.onreadystatechange = function() {
    if (xhr.readyState>3 && xhr.status == 200) success(xhr.responseText);
  };
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
  xhr.send();
  return xhr;
}
var getAjax = getAjax;

function convertDateToUTC(date) {
  return new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds());
}

$(document).ready(function () {
  $readMoreJS.init({
    target: '.truncate-js',
    moreLink: 'Ver más',
    lessLink: 'Ver menos',
    linkClass: 'c-secondary'
  });
});
