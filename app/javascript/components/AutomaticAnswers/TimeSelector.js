import React from 'react';
import Select from 'react-select';

import customStyles from '../../util/selectStyles';
import { HOURS_OPTIONS } from '../../constants/AppConstants';

const TimeSelector = ({
  day,
  handleStartTime,
  handleEndTime
}) => {
  return(
    <div className="row col-md-12 mb-5">
      <div className="col-md-6 pr-20">
        <span className="c-secondary fz-11 pl-10">Empieza</span>
        <Select
          name="startTime"
          menuPortalTarget={document.body}
          components={{
            IndicatorSeparator: () => null
          }}
          className="filter-funnel-input"
          styles={customStyles}
          value={day.startTime}
          options={HOURS_OPTIONS}
          onChange={(option) => handleStartTime(option, day, 'startTime')}
        />
      </div>
      <div className="col-md-6 pl-20">
        <span className="c-secondary fz-11 pl-10">Termina</span>
        <Select
          name="endTime"
          menuPortalTarget={document.body}
          components={{
            IndicatorSeparator: () => null
          }}
          className="filter-funnel-input"
          styles={customStyles}
          value={day.endTime}
          options={HOURS_OPTIONS}
          onChange={(option) => handleEndTime(option, day, 'endTime')}
        />
      </div>
    </div>
  )
}

export default TimeSelector;