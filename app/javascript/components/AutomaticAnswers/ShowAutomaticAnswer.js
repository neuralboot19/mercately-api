import React, {
  useState,
  useEffect
} from 'react';
import Select from 'react-select';
import { find, forEach, cloneDeep } from 'lodash';

import TimeSelector from './TimeSelector';
import wsIcon from 'images/dashboard/wa_icon.png';
import msnIcon from 'images/dashboard/msg_icon.png';
import igIcon from 'images/dashboard/ig_icon.png';
import blueCheckIcon from 'images/new_design/blue-check.png';
import { HOURS_OPTIONS, INTERVALS } from '../../constants/AppConstants';
import customStyles from '../../util/selectStyles';

const ShowAutomaticAnswer = ({ currentAutomaticAnswer, toggleModal }) => {
  const [automaticAnswerDays, setAutomaticAnswerDays] = useState([
    {day: 1, name: 'Lunes', startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 2, name: 'Martes',  startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 3, name: 'Miercoles',  startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 4, name: 'Jueves',  startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 5, name: 'Viernes',  startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 6, name: 'Sabado',  startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false},
    {day: 0, name: 'Domingo',  startTime: HOURS_OPTIONS[8], endTime: HOURS_OPTIONS[17], allDay: false, enabled: false}
  ]);

  const parseAutomaticAnswerDays = () => {
    if (currentAutomaticAnswer && currentAutomaticAnswer.automatic_answer_days) {
      
      let currentDay;
      let _automaticAnswerDays = cloneDeep(automaticAnswerDays);

      forEach(currentAutomaticAnswer.automatic_answer_days, (day) => {
        currentDay = find(_automaticAnswerDays, {day: day.day});

        if (currentDay) {
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
    id: currentAutomaticAnswer.id,
    message_type: currentAutomaticAnswer.message_type,
    whatsapp: currentAutomaticAnswer.whatsapp,
    messenger: currentAutomaticAnswer.messenger,
    instagram: currentAutomaticAnswer.instagram,
    message: currentAutomaticAnswer.message,
    interval: find(INTERVALS, {value: currentAutomaticAnswer.interval}),
    always_active: currentAutomaticAnswer.always_active,
    automatic_answer_days_attributes: []
  });

  const [enableIntervals, setEnableIntervals] = useState(false);

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
  }, []);
  
  const handleCloseModal = (e) => {
    e.preventDefault();
    toggleModal();
  };

  return (
    <form onSubmit={handleCloseModal}>
      <div className="container-fluid-no-padding pl-15 pr-15 disable-container">
        <div className="row col-md-12 mt-15 px-0">
          <div className="col-md-12">
            <label className="col-form-label fz-16">Este mensaje es para</label>
          </div>

          <div className="col-md-12 mt-10 d-flex justify-content-between">
            <div className="row col-md-4 px-0">
              <label className="checkcontainer">
                <input type="radio"
                      name='message_type'
                      value={'new_customer'}
                      defaultChecked={automaticAnswer.message_type == 'new_customer'} />
                <span className="radiobtn"></span>
              </label>
              <label className="fz-14 ml-30">Usuarios nuevos</label>
            </div>

            <div className="col-md-5 px-0">
              <label className="checkcontainer">
                <input type="radio"
                      name='message_type'
                      value={'inactive_customer'}
                      defaultChecked={automaticAnswer.message_type == 'inactive_customer'} />
                <span className="radiobtn"></span>
              </label>
              <label className="fz-14 ml-30">Usuarios recurrentes</label>
            </div>

            <div className="col-md-3 px-0">
              <label className="checkcontainer">
                <input type="radio"
                      name='message_type'
                      value={'all_customer'}
                      defaultChecked={automaticAnswer.message_type == 'all_customer'} />
                <span className="radiobtn"></span>
              </label>
              <label className="fz-14 ml-30">Todos</label>
            </div>
          </div>

          { enableIntervals && (
            <div className='row col-md-12 mt-20'>
              <div className="row col-12">
                <label className="col-form-label fz-16">Intervalo</label>
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
                  />
                </div>
              </div>
            </div>
          )}

          <div className='row col-md-12 mt-5'>
            <div className="col-12 d-flex justify-content-between">
              <label className="col-form-label fz-16">Días y horario</label>
              <div className='pt-10'>
                <label className='switch'>
                  <input type="checkbox"
                        name="always_active"
                        defaultChecked={automaticAnswer.always_active} />
                  <span className="slider round" />
                </label>
                <label className="all-day-text fz-14">Siempre activo</label>
              </div>
            </div>

            { !automaticAnswer.always_active && automaticAnswerDays.map((day) => (
              <div key={day.day} className='col-md-12'>
                { day.enabled && (
                  <div className='col-md-12 mt-10'>
                    <div className="col-md-12 d-flex justify-content-between px-0">
                      <div>
                        <label className="checkcontainer">
                          <input type="checkbox"
                              checked={day.enabled}
                              onChange={() => false}/>
                          <span className="checkmark"></span>
                        </label>
                        <label className='ml-30 weekday fz-14'>{day.name}</label>
                      </div>

                      <div>
                        <label className='switch'>
                          <input type="checkbox"
                                checked={day.allDay}
                                onChange={() => false} />
                          <span className="slider round" />
                        </label>
                        <label className="all-day-text fz-14">Todo el día</label>
                      </div>
                    </div>
                    { day.enabled && !day.allDay && (
                      <div className='row col-md-12 pl-30 pr-0'>
                        <TimeSelector
                          day={day} />
                      </div>
                    )}
                  </div>
                )}
              </div>
            ))}
          </div>

          <div className='row col-md-12 mt-5'>
            <label className='col-form-label fz-16'>Plataformas</label>
          </div>

          <div className='row col-md-12 mt-15'>
            {automaticAnswer.whatsapp && (
              <div className='col-md-4 text-center'>
                <label>
                  <input name="whatsapp"
                        type="checkbox"
                        className='validate-any-required d-none'
                        defaultChecked={automaticAnswer.whatsapp} />
                  <div className="selected-platform t-center">
                    <img src={blueCheckIcon} className="selected-platform-check" />
                    <img src={wsIcon} title="whatsapp" />
                    <br />
                    <label className="fz-14 mt-5">WhatsApp</label>
                  </div>
                </label>
              </div>
            )}

            {automaticAnswer.messenger && (
              <div className='col-md-4 text-center'>
                <label>
                  <input name="messenger"
                        type="checkbox"
                        className='validate-any-required d-none'
                        defaultChecked={automaticAnswer.messenger} />
                  <div className="selected-platform t-center">
                    <img src={blueCheckIcon} className="selected-platform-check" />
                    <img src={msnIcon} title="Messenger" />
                    <br />
                    <label className="fz-14 mt-5">Messenger</label>
                  </div>
                </label>
              </div>
            )}

            {automaticAnswer.instagram && (
              <div className='col-md-4 text-center'>
                <label>
                  <input name="instagram"
                        type="checkbox"
                        className='validate-any-required d-none'
                        defaultChecked={automaticAnswer.instagram} />
                  <div className="selected-platform t-center">
                    <img src={blueCheckIcon} className="selected-platform-check" />
                    <img src={igIcon} title="Instagram" />
                    <br />
                    <label className="fz-14 mt-5">Instagram</label>
                  </div>
                </label>
              </div>
            )}
          </div>

          <div className='row col-md-12 mt-15'>
            <textarea defaultValue={automaticAnswer.message}
                      name="message"
                      className="mercately-input mercately-textarea"
                      placeholder='Mensaje de bienvenida' />
          </div>
        </div>
      </div>

      <div className="row align-items-center mt-20">
        <div className="col text-center">
          <button type="submit" className="blue-button">Cerrar</button>
        </div>
      </div>
    </form>
  );
};

export default ShowAutomaticAnswer;