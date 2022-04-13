import React, {
  forwardRef,
  useImperativeHandle,
  useState,
  useEffect
} from 'react';
import Select from 'react-select';
import { find, forEach, cloneDeep, isEmpty } from 'lodash';

import TimeSelector from './TimeSelector';
import wsIcon from 'images/dashboard/wa_icon.png';
import msnIcon from 'images/dashboard/msg_icon.png';
import igIcon from 'images/dashboard/ig_icon.png';
import blueCheckIcon from 'images/new_design/blue-check.png';
import { HOURS_OPTIONS, INTERVALS } from '../../constants/AppConstants';
import customStyles from '../../util/selectStyles';

const AutomaticAnswerFields = forwardRef((
  { currentAutomaticAnswer, retailerInfo },
  automaticAnswerRef
) => {
  const automaticAnswerErrors = {
    invalidSchedule: '',
    platformSelected: '',
    message: ''
  };

  const [automaticAnswerDays, setAutomaticAnswerDays] = useState([
    {day: 1, name: 'Lunes', startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 2, name: 'Martes', startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 3, name: 'Miércoles', startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 4, name: 'Jueves', startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 5, name: 'Viernes', startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 6, name: 'Sábado', startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 0, name: 'Domingo', startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false}
  ]);

  const parseAutomaticAnswerDays = () => {
    if (currentAutomaticAnswer && currentAutomaticAnswer.automatic_answer_days) {
      
      let currentDay;
      let _automaticAnswerDays = cloneDeep(automaticAnswerDays);

      forEach(currentAutomaticAnswer.automatic_answer_days, (day) => {
        currentDay = find(_automaticAnswerDays, {day: day.day});

        if (currentDay) {
          currentDay.id = day.id;
          currentDay.startTime = find(HOURS_OPTIONS, {value: day.start_time});
          currentDay.endTime = find(HOURS_OPTIONS, {value: day.end_time});
          currentDay.allDay = day.all_day;
          currentDay.enabled = true;
        }
      });

      setAutomaticAnswerDays(_automaticAnswerDays);
    }

    return []
  }

  const [automaticAnswer, setAutomaticAnswer] = useState({
    id: !isEmpty(currentAutomaticAnswer)? currentAutomaticAnswer.id : null,
    message_type: !isEmpty(currentAutomaticAnswer)? currentAutomaticAnswer.message_type : 'new_customer',
    whatsapp: !isEmpty(currentAutomaticAnswer)? currentAutomaticAnswer.whatsapp : false,
    messenger: !isEmpty(currentAutomaticAnswer)? currentAutomaticAnswer.messenger : false,
    instagram: !isEmpty(currentAutomaticAnswer)? currentAutomaticAnswer.instagram : false,
    message: !isEmpty(currentAutomaticAnswer)? currentAutomaticAnswer.message : '',
    interval: !isEmpty(currentAutomaticAnswer)? (currentAutomaticAnswer.interval? find(INTERVALS, {value: currentAutomaticAnswer.interval}) : INTERVALS[0]) : INTERVALS[0],
    always_active: !isEmpty(currentAutomaticAnswer)? currentAutomaticAnswer.always_active : false,
    automatic_answer_days_attributes: []
  });

  const [isValid, setIsValid] = useState(false);
  const [enableIntervals, setEnableIntervals] = useState(false);
  const [errors, setErrors] = useState(automaticAnswerErrors);

  useEffect(() => {
    if (automaticAnswer.message_type == 'new_customer') {
      setEnableIntervals(false);
    }
    else {
      setEnableIntervals(true);
    }
  }, [automaticAnswer.message_type]);

  useEffect(() => {
    setAutomaticAnswer({
      ...automaticAnswer
    });
    parseAutomaticAnswerDays();
  }, [])

  const handleValidation = () => {
    let formIsValid = true;
    let formErrors = { ...automaticAnswerErrors };
    if (!automaticAnswer.message) {
      formIsValid = false;
      formErrors.message = "Mensaje no puede estar vacio";
    }

    if (!automaticAnswer.always_active) {
      forEach(automaticAnswerDays, (day) => {
        if (day.startTime.value > day.endTime.value) {
          formIsValid = false;
          day.invalidSelectTime = 'Hora de inicio no puede ser mayor a hora de fin';
        }
      });
    }

    if (!automaticAnswer.whatsapp && !automaticAnswer.messenger && !automaticAnswer.instagram) {
      formIsValid = false;
      formErrors.platformSelected = "Seleccione una plataforma";
    }

    setErrors(formErrors);
    setIsValid(formIsValid);
    return formIsValid;
  };

  const formatBody = () => {
    let currentAutomaticAnswer = cloneDeep(automaticAnswer);

    if (automaticAnswer.message_type == 'new_customer') {
      currentAutomaticAnswer.interval = null;
    }
    else {
      currentAutomaticAnswer.interval = automaticAnswer.interval.value;
    }

    forEach(automaticAnswerDays, (day) => {
      currentAutomaticAnswer.automatic_answer_days_attributes.push({
        id: day.id || null,
        all_day: day.allDay,
        day: day.day,
        start_time: day.allDay ? 0 : day.startTime.value,
        end_time: day.allDay ? 24 : day.endTime.value,
        _destroy: automaticAnswer.always_active ? true : !day.enabled
      });
    });
    
    return currentAutomaticAnswer;
  }

  useImperativeHandle(automaticAnswerRef, () => ({
    isValid,
    handleValidation,
    body: formatBody()
  }));

  const handleInputChange = (e) => {
    const target = e.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;

    setAutomaticAnswer({
      ...automaticAnswer,
      [name]: value
    })
  }

  const handleSchedule = (e, day, name) => {
    const currentAutomaticAnswerDays = cloneDeep(automaticAnswerDays);
    let dayIn = find(currentAutomaticAnswerDays, {day: day.day});

    if (!dayIn) {
      return;
    }

    dayIn[name] = e.target.checked;

    if (!e.target.checked) {
      dayIn.allDay = false;
    }

    if (name == 'allDay' && e.target.checked) {
      dayIn.enabled = true;
    }

    setAutomaticAnswerDays(currentAutomaticAnswerDays);
  }

  const handleSelectTime = (option, day, name) => {
    const currentAutomaticAnswerDays = cloneDeep(automaticAnswerDays);
    let dayIn = find(currentAutomaticAnswerDays, {day: day.day});

    if (!dayIn) {
      return;
    }

    dayIn[name] = option;

    setAutomaticAnswerDays(currentAutomaticAnswerDays);
  }

  const handleInterval = (option) => {
    setAutomaticAnswer({
      ...automaticAnswer,
      interval: option
    })
  }

  return (
    <div className="container-fluid-no-padding pl-15 pr-15">
      <div className="row col-md-12 mt-15 px-0">
        <div className="col-md-12">
          <label className="col-form-label fz-16">Este mensaje es para</label>
        </div>

        <div className="col-md-12 mt-10 d-flex justify-content-between">
          <div className="row col-md-4 px-0">
            <label className="checkcontainer">
              <input id="message_type_new_customer"
                    type="radio"
                    name='message_type'
                    value={'new_customer'}
                    checked={automaticAnswer.message_type == 'new_customer'}
                    onChange={handleInputChange} />
              <span className="radiobtn"></span>
            </label>
            <label htmlFor="message_type_new_customer" className="fz-14 ml-30">Usuarios nuevos</label>
          </div>

          <div className="col-md-5 px-0">
            <label className="checkcontainer">
              <input id="message_type_inactive_customer"
                    type="radio"
                    name="message_type"
                    value={'inactive_customer'}
                    checked={automaticAnswer.message_type == 'inactive_customer'}
                    onChange={handleInputChange} />
             <span className="radiobtn"></span>
            </label>
            <label htmlFor="message_type_inactive_customer" className="fz-14 ml-30">Usuarios recurrentes</label>
          </div>

          <div className="col-md-3 px-0">
            <label className="checkcontainer">
              <input id="message_type_all_customer"
                    type="radio"
                    name='message_type'
                    value={'all_customer'}
                    checked={automaticAnswer.message_type == 'all_customer'}
                    onChange={handleInputChange} />
             <span className="radiobtn"></span>
            </label>
            <label htmlFor="message_type_all_customer" className="fz-14 ml-30">Todos</label>
          </div>
        </div>

        { enableIntervals && (
          <div className='row col-md-12 mt-20'>
            <div className="row col-12">
              <label className="col-form-label fz-16">Elige intervalo de inactividad</label>
            </div>

            <div className='row col-md-12'>
              <div className="col-md-4">
                <Select
                  name="interval"
                  menuPortalTarget={document.body}
                  components={{
                    IndicatorSeparator: () => null
                  }}
                  className="filter-funnel-input"
                  styles={customStyles}
                  value={automaticAnswer.interval}
                  options={INTERVALS}
                  onChange={handleInterval}
                />
              </div>
            </div>

            <div className="row col-12 mt-20">
              <label className="all-day-text fz-12">El tiempo de inactividad representa el periodo de tiempo desde el último mensaje del cliente</label>
            </div>
          </div>
        )}

        <div className='row col-md-12 mt-5'>
          <div className="col-12 d-flex justify-content-between">
            <label className="col-form-label fz-16">Elige los días y el horario</label>
            <div className='pt-10'>
              <label className='switch'>
                <input type="checkbox"
                      id="always_active"
                      name="always_active"
                      checked={automaticAnswer.always_active}
                      onChange={handleInputChange} />
                <span className="slider round" />
              </label>
              <label className="all-day-text fz-14" htmlFor="always_active">Siempre activo</label>
            </div>
          </div>

          { !automaticAnswer.always_active && automaticAnswerDays.map((day) => (
            <div key={day.day} className='col-md-12 mt-10'>
              <div className="col-md-12 d-flex justify-content-between px-0">
                <div>
                  <label className="checkcontainer">
                    <input type="checkbox"
                        id={`handle_weekday_${day.day}`}
                        checked={day.enabled}
                        onChange={(e) => handleSchedule(e, day, 'enabled')} />
                    <span className="checkmark"></span>
                  </label>
                  <label className='ml-30 weekday fz-14' htmlFor={`handle_weekday_${day.day}`}>{day.name}</label>
                </div>
                <div>
                  <label className='switch'>
                    <input type="checkbox"
                          id={`all_day_${day.day}`}
                          checked={day.allDay}
                          onChange={(e) => handleSchedule(e, day, 'allDay')} />
                    <span className="slider round" />
                  </label>
                  <label className='all-day-text fz-14' htmlFor={`all_day_${day.day}`}>Activar todo el día</label>
                </div>
              </div>
              { day.enabled && !day.allDay && (
                <div className='row col-md-12 pl-30 pr-0'>
                  <TimeSelector
                    day={day}
                    handleStartTime={handleSelectTime}
                    handleEndTime={handleSelectTime} />
                </div>
              )}

              <span className="funnel-input-error">{day.invalidSelectTime}</span>
            </div>
          ))}
        </div>

        <div className='row col-md-12 mt-5'>
          <label className='col-form-label fz-16'>Elige las plataformas</label>
        </div>

        <div className='row col-md-12 mt-15'>
          {retailerInfo.whatsapp_integrated && (
            <div className='col-md-4 text-center'>
              <label>
                <input name="whatsapp"
                      type="checkbox"
                      className='validate-any-required d-none'
                      checked={automaticAnswer.whatsapp}
                      onChange={handleInputChange} />
                <div className="selected-platform t-center">
                  <img src={blueCheckIcon} className="selected-platform-check" />
                  <img src={wsIcon} title="whatsapp" />
                  <br />
                  <label className="fz-14 mt-5">WhatsApp</label>
                </div>
              </label>
            </div>
          )}
          {retailerInfo.messenger_integrated && (
            <div className='col-md-4 text-center'>
              <label>
                <input name="messenger"
                      type="checkbox"
                      className='validate-any-required d-none'
                      checked={automaticAnswer.messenger}
                      onChange={handleInputChange} />
                <div className="selected-platform t-center">
                  <img src={blueCheckIcon} className="selected-platform-check" />
                  <img src={msnIcon} title="Messenger" />
                  <br />
                  <label className="fz-14 mt-5">Messenger</label>
                </div>
              </label>
            </div>
          )}
          {retailerInfo.instagram_integrated && (
            <div className='col-md-4 text-center'>
              <label>
                <input name="instagram"
                      type="checkbox"
                      className='validate-any-required d-none'
                      checked={automaticAnswer.instagram}
                      onChange={handleInputChange} />
                <div className="selected-platform t-center">
                  <img src={blueCheckIcon} className="selected-platform-check" />
                  <img src={igIcon} title="Instagram" />
                  <br />
                  <label className="fz-14 mt-5">Instagram</label>
                </div>
              </label>
            </div>
          )}
          <span className="funnel-input-error">{errors.platformSelected}</span>
        </div>

        <div className='row col-md-12 mt-15'>
          <textarea value={automaticAnswer.message}
                    name="message"
                    className="mercately-input mercately-textarea"
                    placeholder='Mensaje de bienvenida'
                    onChange={handleInputChange} />
          <span className="funnel-input-error">{errors.message}</span>
        </div>
      </div>
    </div>
  );
});

export default AutomaticAnswerFields;
