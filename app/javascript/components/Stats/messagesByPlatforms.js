import React, { useState, useEffect } from 'react';
import { DateRangePicker } from 'rsuite';
import moment from 'moment';

import {
  Chart as ChartJS,
  ArcElement,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js';

ChartJS.register(
  ArcElement,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const options = {
  responsive: true,
  plugins: {
    legend: {
      position: 'top'
    },
    title: {
      display: true,
      text: 'Chart.js Line Chart'
    }
  }
};

const buildMessagesByPlatformChart = (startDate, endDate) => {
  const dates = getDaysBetweenDates(moment(startDate), moment(endDate));
  const allDates = [];

  forEach(dates, (date) => {
    allDates.push(moment(date).format('D MMM'));
  });

  setDataMessageByPlatform({
    labels: allDates,
    datasets: [
      {
        label: 'Whatsapp',
        data: labels.map(() => faker.datatype.number({ min: -1000, max: 1000 })),
        borderColor: '#20B038',
        backgroundColor: '#20B038'
      },
      {
        label: 'Messenger',
        data: labels.map(() => faker.datatype.number({ min: -1000, max: 1000 })),
        borderColor: '#625BFF',
        backgroundColor: '#625BFF'
      },
      {
        label: 'Instagram',
        data: labels.map(() => faker.datatype.number({ min: -1000, max: 1000 })),
        borderColor: '#F95D0E',
        backgroundColor: '#F95D0E'
      },
      {
        label: 'Mercado Libre',
        data: labels.map(() => faker.datatype.number({ min: -1000, max: 1000 })),
        borderColor: '#FFE800',
        backgroundColor: '#FFE800'
      }
    ]
  });
};

const MessagesByPlatform = () => {
  const [dataMessageByPlatform, setDataMessageByPlatform] = useState({ labels: [], datasets: [] });

  const manageRangeDate = (value) => {
    setStartDate(moment(value[0]).format('YYYY-MM-DD'));
    setEndDate(moment(value[1]).format('YYYY-MM-DD'));
  };

  return (
    <div className="row box-container mt-30">
      <div className="row mt-30 mr-30 mb-30 ml-30">
        <div className="d-flex justify-content-between col-md-12">
          <h5 className="form-container_sub-title ml-0">Mensajes por plataforma</h5>

          <DateRangePicker
            onChange={manageRangeDate}
          />
        </div>

        <div className="row col-md-12 mt-20">
          <div className="col-lg-4 col-md-4">
            <h4>Mensajes en total</h4>
            <p>{(statsData.total_inbound + statsData.total_outbound)}</p>
            <div>
              Recibidos
              {statsData.total_inbound}
            </div>
            <div>
              Enviados
              {statsData.total_outbound}
            </div>
          </div>
          <div className="col-lg-8 col-md-8">
            <Line options={options} data={dataMessageByPlatform} />
          </div>
        </div>

        <div className="row col-md-12 mt-30">
          <div className="col-md-3 col-sm-6">
            <img className="mr-4" src={waIcon} alt="fast answers icon" />
            <div>
              {' '}
              Recibidos
              {statsData.total_inbound_ws}
            </div>
            <div>
              Enviados
              {statsData.total_outbound_ws}
            </div>
          </div>

          <div className="col-md-3 col-sm-6">
            <img className="mr-4" src={msmIcon} alt="fast answers icon" />
            <div>
              {' '}
              Recibidos
              {statsData.total_inbound_msn}
            </div>
            <div>
              Enviados
              {statsData.total_outbound_msn}
            </div>
          </div>

          <div className="col-md-3 col-sm-6">
            <img className="mr-4" src={igIcon} alt="fast answers icon" />
            <div>
              {' '}
              Recibidos
              {statsData.total_inbound_ig}
            </div>
            <div>
              Enviados
              {statsData.total_outbound_ig}
            </div>
          </div>

          <div className="col-md-3 col-sm-6">
            <img className="mr-4" src={mlIcon} alt="fast answers icon" />
            <div>
              {' '}
              Recibidos
              {statsData.total_inbound_ml}
            </div>
            <div>
              Enviados
              {statsData.total_outbound_ml}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default MessagesByPlatform;
