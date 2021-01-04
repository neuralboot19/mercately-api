var fullCalendarSidebar;
document.addEventListener('DOMContentLoaded', function() {
  var calendarEl = document.getElementById('calendar');

  var titleInput = document.getElementById('title');
  var startsInputYear = document.getElementById('starts_at_year');
  var startsInputMonth = document.getElementById('starts_at_month');
  var startsInputDay = document.getElementById('starts_at_day');
  var startsInputHour = document.getElementById('starts_at_hour');
  var startsInputMinute = document.getElementById('starts_at_minute');
  var endsInputYear = document.getElementById('ends_at_year');
  var endsInputMonth = document.getElementById('ends_at_month');
  var endsInputDay = document.getElementById('ends_at_day');
  var endsInputHour = document.getElementById('ends_at_hour');
  var endsInputMinute = document.getElementById('ends_at_minute');

  const timezone = new Date().toString().match(/([-\+][0-9]+)\s/)[1];
  const timezoneInput = document.getElementById('timezone');
  const timezoneInputEdit = document.getElementById('timezone_edit');
  timezoneInput.value = timezone;
  timezoneInputEdit.value = timezone;

  var titleInputEdit = document.getElementById('title_edit');
  var startsInputYearEdit = document.getElementById('starts_at_year_edit');
  var startsInputMonthEdit = document.getElementById('starts_at_month_edit');
  var startsInputDayEdit = document.getElementById('starts_at_day_edit');
  var startsInputHourEdit = document.getElementById('starts_at_hour_edit');
  var startsInputMinuteEdit = document.getElementById('starts_at_minute_edit');
  var endsInputYearEdit = document.getElementById('ends_at_year_edit');
  var endsInputMonthEdit = document.getElementById('ends_at_month_edit');
  var endsInputDayEdit = document.getElementById('ends_at_day_edit');
  var endsInputHourEdit = document.getElementById('ends_at_hour_edit');
  var endsInputMinuteEdit = document.getElementById('ends_at_minute_edit');
  var rememberInputEdit = document.getElementById('remember_edit');

  fullCalendarSidebar = new FullCalendar.Calendar(calendarEl, {
    //themeSystem: 'bootstrap',
    allDaySlot: false,
    timeZone: 'UTC',
    customButtons: {
      showCalendar: {
        text: 'Ver agenda',
        click: function() {
          window.location.href = `/retailers/${window.location.pathname.split('/')[2]}/calendar_events`
        }
      }
    },
    headerToolbar: {
      start: 'showCalendar',
      center: 'title',
      end: 'prev,next'
    },
    titleFormat: { year: 'numeric', month: 'short', day: 'numeric' },
    initialView: 'timeGridDay',
    buttonText: {
      today: 'Hoy'
    },
    height: '100%',
    contentHeight: '100%',
    locale: 'es',
    slotLabelInterval: '00:30',
    slotLabelFormat: {
      hour: '2-digit',
      minute: '2-digit',
      omitZeroMinute: false,
      meridiem: 'short'
    },
    selectable: true,
    eventClick: function(e) {
      document.getElementById('event-modal--edit').checked = true;
      form = document.getElementById('edit_event');
      newUrl = form.action.replace(/:id/, e.event._def.publicId);
      form.dataset.action = newUrl;
      document.getElementById('delete_event').dataset.action = newUrl;
      start = convertDateToUTC(e.event.start);
      end = convertDateToUTC(e.event.end);

      titleInputEdit.value = e.event.title;
      startsInputYearEdit.value = start.getFullYear();
      startsInputMonthEdit.value = start.getMonth() + 1;
      startsInputDayEdit.value = start.getDate();
      startsInputHourEdit.value = start.getHours().toString().length === 1 ? '0' + start.getHours() : start.getHours();
      startsInputMinuteEdit.value = start.getMinutes() === 0 ? '00' : start.getMinutes();
      endsInputYearEdit.value = end.getFullYear();
      endsInputMonthEdit.value = end.getMonth() + 1;
      endsInputDayEdit.value = end.getDate();
      endsInputHourEdit.value = end.getHours().toString().length === 1 ? '0' + end.getHours() : end.getHours();
      endsInputMinuteEdit.value = end.getMinutes() === 0 ? '00' : end.getMinutes();
      rememberInputEdit.value = e.event.extendedProps.remember;
    },
    select: function(info) {
      start = convertDateToUTC(info.start);
      end = convertDateToUTC(info.end);

      startsInputYear.value = start.getFullYear();
      startsInputMonth.value = start.getMonth() + 1;
      startsInputDay.value = start.getDate();
      startsInputHour.value = start.getHours().toString().length === 1 ? '0' + start.getHours() : start.getHours();
      startsInputMinute.value = start.getMinutes() === 0 ? '00' : start.getMinutes();
      endsInputYear.value = end.getFullYear();
      endsInputMonth.value = end.getMonth() + 1;
      endsInputDay.value = end.getDate();
      endsInputHour.value = end.getHours().toString().length === 1 ? '0' + end.getHours() : end.getHours();
      endsInputMinute.value = end.getMinutes() === 0 ? '00' : end.getMinutes();
      document.getElementById('event-modal').checked = true;
      document.querySelector('#new_event input').focus();
    },
    events: `/retailers/${window.location.pathname.split('/')[2]}/calendar_events.json`,
  });
  fullCalendarSidebar.render();

  document.getElementById('new_event').onsubmit = function(e) {
    e.preventDefault();
    let el = e.target;
    var fields = { calendar_event: {} };
    var formData = new FormData(el);
    for (var key of formData.keys()) {
      if (key === 'authenticity_token')
        fields[key] = formData.get(key);
      else {
        fields['calendar_event'][key] = formData.get(key);
      }
    }
    fetch(el.action, {
      method: 'POST',
      body: JSON.stringify(fields),
      headers: {
        'Content-type': 'application/json; charset=UTF-8'
      }
    }).then(function (response) {
      if (response.ok) return response;

      return Promise.reject(response);
    }).then(function () {
      fullCalendarSidebar.refetchEvents();
      document.getElementById('event-modal').checked = false;
      titleInput.value = '';
    }).catch(function (error) {
      console.warn('error');
      console.warn(error);
    });
  }

  document.getElementById('edit_event').onsubmit = function(e) {
    e.preventDefault();
    let el = e.target;
    var fields = { calendar_event: {} };
    var formData = new FormData(el);
    for (var key of formData.keys()) {
      if (key == 'authenticity_token')
        fields[key] = formData.get(key);
      else {
        fields['calendar_event'][key] = formData.get(key);
      }
    }
    fetch(el.dataset.action, {
      method: 'PUT',
      body: JSON.stringify(fields),
      headers: {
        'Content-type': 'application/json; charset=UTF-8'
      }
    }).then(function (response) {
      if (response.ok) return response.json();

      return Promise.reject(response);
    }).then(function () {
      fullCalendarSidebar.refetchEvents();
      document.getElementById('event-modal--edit').checked = false;
    }).catch(function (error) {
      console.warn(error);
    });
  }

  document.getElementById('delete_event').onclick = function(e) {
    e.preventDefault();
    let el = e.target;
    let destroy = confirm('Estas seguro? esta accion no es reversible');
    if (destroy) {
      fetch(el.dataset.action, {
        method: 'DELETE',
        headers: {
          'Content-type': 'application/json; charset=UTF-8'
        }
      }).then(function (response) {
        if (response.ok) return response.json();

        return Promise.reject(response);
      }).then(function () {
        fullCalendarSidebar.refetchEvents();
        document.getElementById('event-modal--edit').checked = false;
      }).catch(function (error) {
        console.warn(error);
      });
    }
  }
});
