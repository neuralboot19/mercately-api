import React, { useState, useEffect } from 'react';
import Select from 'react-select';
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
import { Doughnut, Bar } from 'react-chartjs-2';
import { useDispatch, useSelector } from 'react-redux';

import moment from 'moment';
import { forEach, filter, isEmpty } from 'lodash';

import { LineChart } from 'react-chartkick';
import 'chartkick/chart.js';

import waIcon from 'images/new_design/wa.png';
import msmIcon from 'images/new_design/msm.png';
import igIcon from 'images/new_design/ig.png';
import mlIcon from 'images/new_design/ml.png';
import { DateRange } from "react-date-range";
import { es } from 'react-date-range/dist/locale';
import Progressbar from '../shared/ProgressBar';
import {
  fetchMessagesByPlatform,
  fetchUsageByPlatform,
  fetchAverageResponseTimes,
  fetchMostUsedTags,
  fetchNewAndRecurringConversations,
  fetchAgentPerformance,
  fetchSentMessagesBy
} from '../../actions/stats';

import { fetchAgents } from '../../actions/agents';

import PlatformPercentage from "./PlatformPercentage";
import AvatarName from "./AvatarName";
import 'react-date-range/dist/styles.css';
import 'react-date-range/dist/theme/default.css';
import PlatformMessageCounter from "./PlatformMessageCounter";
import timeUtils from '../../util/timeUtils';

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

const rangeStartDate = moment().subtract(1, 'months').toDate();
const rangeEndDate = moment().toDate();

const platforms = [
  { value: null, label: 'Todas las plataformas' },
  { value: 0, label: 'WhatsApp' },
  { value: 1, label: 'Messenger' },
  { value: 2, label: 'Instagram' },
  { value: 3, label: 'Mercado Libre' }
];

const agentPerformancePlatforms = [
  { value: null, label: 'Todas las plataformas' },
  { value: 0, label: 'WhatsApp' },
  { value: 1, label: 'Messenger' },
  { value: 2, label: 'Instagram' }
];

const defaultDoughnutData = {
  datasets: [
    {
      data: [0, 0, 0, 0]
    }
  ]
};

const VBoptions = {
  plugins: {
    legend: {
      display: false
    },
    title: {
      display: false
    }
  },
  scales: {
    x: {
      grid: {
        display: false
      },
      title: {
        display: false
      }
    },
    y: {
      display: false
    }
  },
  maintainAspectRatio: false
};

const StatsComponent = () => {
  const dispatch = useDispatch();
  const {
    messagesByPlatform,
    usageByPlatform,
    averageResponseTimes,
    mostUsedTags,
    newAndRecurringConversationsData,
    agentPerformance,
    setMessagesBy
  } = useSelector((reduxState) => reduxState.statsReducer);

  const { agents } = useSelector((reduxState) => reduxState.agentsReducer);

  const [showDateRange, setShowDateRange] = useState(false);
  const [startDate, setStartDate] = useState(rangeStartDate);
  const [endDate, setEndDate] = useState(rangeEndDate);
  const [dateFilter, setDateFilter] = useState({
    startDate: moment(rangeStartDate).format('YYYY-MM-DD'),
    endDate: moment(rangeEndDate).format('YYYY-MM-DD')
  });
  const [initialStartDate, setInitialStartDate] = useState(rangeStartDate);
  const [initialEndDate, setInitialEndDate] = useState(rangeEndDate);
  const [agentsOptions, setAgentsOptions] = useState([]);
  const [agentSelected1, setAgentSelected1] = useState();
  const [agentSelected2, setAgentSelected2] = useState();
  const [dataMessagesByPlatform, setDataMessagesByPlatform] = useState([]);
  const [averageResponseTimesFormated, setAverageResponseTimesFormated] = useState({ labels: [], datasets: [] });
  const [newAndRecurringConversations, setNewAndRecurringConversations] = useState({
    newConversations: 0,
    percentageNewConversations: 0,
    recurringConversations: 0,
    percentageRecurringConversations: 0
  });
  const [selectedPlatform1, setSelectedPlatform1] = useState(agentPerformancePlatforms[0]);
  const [selectedPlatform2, setSelectedPlatform2] = useState(platforms[0]);
  const [doughnutData, setDoughnutData] = useState(defaultDoughnutData);
  const [averageResponseTimesText, setAverageResponseTimesText] = useState('');

  const formatAgents = () => {
    const data = [{ value: null, label: 'Todos los agentes' }];
    forEach(agents, (row) => {
      data.push({ value: row.id, label: `${row.first_name} ${row.last_name}` });
    });
    setAgentsOptions(data);
    setAgentSelected1(data[0]);
    setAgentSelected2(data[0]);
  };

  const fetchStatistics = (paramStartDate, paramEndDate) => {
    dispatch(fetchMessagesByPlatform(paramStartDate, paramEndDate));
    dispatch(fetchUsageByPlatform(paramStartDate, paramEndDate));
    dispatch(fetchAverageResponseTimes(paramStartDate, paramEndDate, null));
    dispatch(fetchMostUsedTags(paramStartDate, paramEndDate));
    dispatch(fetchNewAndRecurringConversations(paramStartDate, paramEndDate, null));
    dispatch(fetchAgentPerformance(paramStartDate, paramEndDate, null));
    dispatch(fetchSentMessagesBy(paramStartDate, paramEndDate, null));
  }
  const applySearch = () => {
    setStartDate(initialStartDate);
    setEndDate(initialEndDate);
    setDateFilter({
      startDate: moment(initialStartDate).format('YYYY-MM-DD'),
      endDate: moment(initialEndDate).format('YYYY-MM-DD')
    });
    setAgentSelected1(agentsOptions[0]);
    setAgentSelected2(agentsOptions[0]);
    setSelectedPlatform1(agentPerformancePlatforms[0]);
    setSelectedPlatform2(platforms[0]);
    setShowDateRange(false);

    let paramStartDate = moment(initialStartDate).format('YYYY-MM-DD');
    let paramEndDate = moment(initialEndDate).format('YYYY-MM-DD');

    fetchStatistics(paramStartDate, paramEndDate);
  };

  useEffect(() => {
    fetchStatistics(dateFilter.startDate, dateFilter.endDate);
  }, []);

  const cancelSearch = () => {
    setInitialStartDate(startDate);
    setInitialEndDate(endDate);
    setShowDateRange(false);
  };

  useEffect(() => {
    formatAgents();
  }, [agents]);

  const onClickOut = (e) => {
    if (document.getElementById('date-range-stats') && !document.getElementById('date-range-stats').contains(e.target) && showDateRange) {
      cancelSearch();
    }
  };

  useEffect(() => {
    window.addEventListener('click', onClickOut);
    return () => {
      window.removeEventListener('click', onClickOut);
    };
  }, [showDateRange]);

  useEffect(() => {
    dispatch(fetchAgents());
  }, []);

  useEffect(() => {
    if (isEmpty(usageByPlatform)) {
      setDoughnutData(defaultDoughnutData);
    } else {
      setDoughnutData({
        datasets: [
          {
            data: [
              usageByPlatform.percentage_total_ws_messages,
              usageByPlatform.percentage_total_msn_messages,
              usageByPlatform.percentage_total_ig_messages,
              usageByPlatform.percentage_total_ml_messages
            ],
            backgroundColor: [
              '#20B038',
              '#625BFF',
              '#F95D0E',
              '#FFE800'
            ],
            borderColor: [
              '#20B038',
              '#625BFF',
              '#F95D0E',
              '#FFE800'
            ],
            borderWidth: 1
          }
        ]
      });
    }
  }, [usageByPlatform]);

  const fillData = (platformData) => {
    const data = {};
    forEach(platformData, (row) => {
      data[`"${row.date}"`] = row.amount;
    });

    return data;
  };

  const formatMessagesByPlatformData = () => {
    const data = [
      { "name": "Whatsapp", "data": fillData(messagesByPlatform.ws.data) },
      { "name": "Messenger", "data": fillData(messagesByPlatform.msn.data) },
      { "name": "Instagram", "data": fillData(messagesByPlatform.ig.data) },
      { "name": "Mercado Libre", "data": fillData(messagesByPlatform.ml.data) }
    ];

    setDataMessagesByPlatform(data);
  };

  useEffect(() => {
    if (messagesByPlatform) {
      formatMessagesByPlatformData();
    }
  }, [messagesByPlatform]);

  const manageRangeDate = ({ selection }) => {
    setInitialStartDate(selection.startDate);
    setInitialEndDate(selection.endDate);
  };

  const parseAverageResponseTimes = () => {
    const range1 = filter(averageResponseTimes, (row) => Number(row.conversation_time_average) >= 0 && Number(row.conversation_time_average) <= 3600);
    const range2 = filter(averageResponseTimes, (row) => Number(row.conversation_time_average) > 3600 && Number(row.conversation_time_average) <= 28800);
    const range3 = filter(averageResponseTimes, (row) => Number(row.conversation_time_average) > 28800 && Number(row.conversation_time_average) <= 86400);
    const range4 = filter(averageResponseTimes, (row) => Number(row.conversation_time_average) > 86400);

    let totalTime = 0;

    forEach(averageResponseTimes, (row) => {
      totalTime += Number(row.conversation_time_average);
    });

    setAverageResponseTimesFormated({
      labels: ['0 - 1 hr', '1 - 8 hr', '8 - 24 hr', '> 24 hr'],
      datasets: [
        {
          data: [range1.length, range2.length, range3.length, range4.length],
          backgroundColor: '#782F79'
        }
      ]
    });

    setAverageResponseTimesText(timeUtils.secondsToHms(totalTime));
  };

  useEffect(() => {
    parseAverageResponseTimes();
  }, [averageResponseTimes]);

  const getAverageResponseTimes = (data) => {
    setAgentSelected1(data);
    dispatch(fetchAverageResponseTimes(dateFilter.startDate, dateFilter.endDate, data.value));
  };

  const getAgentPerformance = (data) => {
    setSelectedPlatform1(data);
    dispatch(fetchAgentPerformance(dateFilter.startDate, dateFilter.endDate, data.value));
  };

  useEffect(() => {
    const formattedData = {
      newConversations: 0,
      percentageNewConversations: 0,
      recurringConversations: 0,
      percentageRecurringConversations: 0
    };

    forEach(newAndRecurringConversationsData, (row) => {
      formattedData.newConversations += row.new_conversations;
      formattedData.recurringConversations += row.recurring_conversations;
    });

    const total = formattedData.newConversations + formattedData.recurringConversations;

    if (total > 0) {
      formattedData.percentageNewConversations = Math.round((((formattedData.newConversations * 100) / total) + Number.EPSILON) * 100) / 100;
      formattedData.percentageRecurringConversations = Math.round((((formattedData.recurringConversations * 100) / total) + Number.EPSILON) * 100) / 100;
    }

    setNewAndRecurringConversations(formattedData);
  }, [newAndRecurringConversationsData]);

  const getNewAndRecurringConversations = (data) => {
    setAgentSelected2(data);
    dispatch(fetchNewAndRecurringConversations(dateFilter.startDate, dateFilter.endDate, data.value));
  };

  const getSentMessagesBy = (data) => {
    setSelectedPlatform2(data);
    dispatch(fetchSentMessagesBy(dateFilter.startDate, dateFilter.endDate, data.value));
  };

  return (
    <div className="content_width ml-sm-108 mt-25 px-15 no-left-margin-xs">
      <div className="container-fluid-no-padding">
        <div className="row">
          <div className="col-12 col-sm-9">
            <h1 className="page__title">Estadísticas de mensajería</h1>
            <span className="current-page">
              Datos interesantes que tienes en cada plataforma de mensajería
            </span>
          </div>
        </div>

        <div className="row box-container mt-24 p-30">
          <div className="d-flex col-md-12 beetwen-flex p-relative">
            <h5 className="form-container_sub-title ml-0">Mensajes por plataformas</h5>
            <div className="stats-date-range-button flex-center-xy" onClick={() => setShowDateRange(!showDateRange)}>
              {moment(initialStartDate).format('DD/MM/YYYY')}
              {' - '}
              {moment(initialEndDate).format('DD/MM/YYYY')}
              <i className="fas fa-chevron-down" />
            </div>
            {showDateRange && (
            <div className="stats-date-range bg-white" id="date-range-stats">
              <DateRange
                locale={es}
                ranges={[
                  {
                    startDate: initialStartDate,
                    endDate: initialEndDate,
                    key: 'selection'
                  }
                ]}
                onChange={manageRangeDate}
                moveRangeOnFirstSelection={false}
                showPreview={false}
              />
              <button type="button" className="btn text-danger" onClick={cancelSearch}>Cancelar</button>
              <button type="button" className="btn text-blue" onClick={applySearch}>Aplicar</button>
            </div>
            )}
          </div>

          <div className="row col-md-12">
            <div className="col-lg-4 col-md-4 flex-column flex-center-xy p-12">
              <div className="stats-total-message-container">
                <p>Mensajes en total</p>
                <p>{(messagesByPlatform.ws.total_messages + messagesByPlatform.msn.total_messages + messagesByPlatform.ig.total_messages + messagesByPlatform.ml.total_messages)}</p>
              </div>
              <div className="stats-card-row-values w-100">
                <span className="stats-card-label pb-8">Recibidos</span>
                <span className="stats-card-label pb-8 pr-50">
                  {(messagesByPlatform.ws.total_inbound + messagesByPlatform.msn.total_inbound + messagesByPlatform.ig.total_inbound + messagesByPlatform.ml.total_inbound)}
                </span>
              </div>
              <div className="stats-card-row-values w-100">
                <span className="stats-card-label pb-0">Enviados</span>
                <span className="stats-card-label pb-8 pr-50">
                  {(messagesByPlatform.ws.total_outbound + messagesByPlatform.msn.total_outbound + messagesByPlatform.ig.total_outbound + messagesByPlatform.ml.total_outbound)}
                </span>
              </div>
            </div>
            <div className="col-lg-8 col-md-8 mt-30">
              <LineChart colors={["#20B038", "#625BFF", "#F95D0E", "#FFE800"]} data={dataMessagesByPlatform} />
            </div>
          </div>

          <div className="row col-md-12 mt-20 stats-platform-counters">
            <PlatformMessageCounter
              icon={waIcon}
              className="stats-border-right"
              total={messagesByPlatform.ws.total_messages}
              inbound={messagesByPlatform.ws.total_inbound}
              outbound={messagesByPlatform.ws.total_outbound}
            />
            <PlatformMessageCounter
              className="stats-border-right"
              icon={msmIcon}
              total={messagesByPlatform.msn.total_messages}
              inbound={messagesByPlatform.msn.total_inbound}
              outbound={messagesByPlatform.msn.total_outbound}
            />
            <PlatformMessageCounter
              className="stats-border-right"
              icon={igIcon}
              total={messagesByPlatform.ig.total_messages}
              inbound={messagesByPlatform.ig.total_inbound}
              outbound={messagesByPlatform.ig.total_outbound}
            />
            <PlatformMessageCounter
              icon={mlIcon}
              total={messagesByPlatform.ml.total_messages}
              inbound={messagesByPlatform.ml.total_inbound}
              outbound={messagesByPlatform.ml.total_outbound}
            />
          </div>
        </div>

        <div className="row mt-24 col-md-12 pr-0 pl-0">
          <div className="col-md-6 pr-12 stats-card">
            <div className="col-md-12 box-container pt-30 pr-30 pb-30 pl-30">
              <h5 className="form-container_sub-title ml-0 stats-card-title">Uso por plataforma</h5>
              <div className="mt-20">
                <Doughnut
                  data={doughnutData}
                  width={200}
                  height={200}
                  options={{
                    maintainAspectRatio: false,
                    cutout: '70%'
                  }}
                />
              </div>

              <div className="mt-20 text-center">
                <div className="flex-center-xy">
                  <PlatformPercentage className="mr-24" percentage={usageByPlatform.percentage_total_ws_messages} name="WhatsApp" color="#20B038" />
                  <PlatformPercentage className="ml-24" percentage={usageByPlatform.percentage_total_msn_messages} name="Messenger" color="#625BFF" />
                </div>
                <div className="flex-center-xy mt-24">
                  <PlatformPercentage className="mr-24" percentage={usageByPlatform.percentage_total_ig_messages} name="Instagram" color="#F95D0E" />
                  <PlatformPercentage className="ml-24" percentage={usageByPlatform.percentage_total_ml_messages} name="Mercado Libre" color="#FFE800" />
                </div>
              </div>
            </div>
          </div>

          <div className="col-md-6 pl-12 stats-card">
            <div className="col-md-12 box-container pt-30 pr-30 pb-30 pl-30">
              <h5 className="form-container_sub-title ml-0 stats-card-title">Tiempo promedio de respuesta</h5>
              <div className="mt-15 text-center">
                <div className="d-flex justify-content-center mb-20">
                  <Select
                    options={agentsOptions}
                    value={agentSelected1}
                    className="stats-selector col-md-5 pl-0"
                    classNamePrefix="stats-selector"
                    onChange={getAverageResponseTimes}
                    placeholder="Todos los agentes"
                  />
                </div>
                <div className="stats-chart-bar-value">{averageResponseTimesText}</div>
                <span className="stats-chart-bar-label">Tiempo promedio de respuesta</span>
              </div>
              <div className="mt-20 flex-center-xy">
                <div style={{ width: 240 }}>
                  <Bar
                    options={VBoptions}
                    data={averageResponseTimesFormated}
                    width={240}
                    height={200}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="row mt-24 col-md-12 pr-0 pl-0">
          <div className="col-md-6 pr-12 stats-card">
            <div className="col-md-12 box-container pt-30 pr-30 pb-30 pl-30 mh-vh-30">
              <h5 className="form-container_sub-title ml-0 stats-card-title">Etiquetas más utilizadas</h5>
              {mostUsedTags.map((tag) => (
                <div key={tag.id} className="stats-card-row-values">
                  <span className="stats-card-label">{tag.tag_name}</span>
                  <span className="stats-card-label">{tag.amount_used}</span>
                </div>
              ))}
            </div>
          </div>

          <div className="col-md-6 pl-12 stats-card">
            <div className="col-md-12 box-container pt-30 pr-30 pb-30 pl-30">
              <div className="d-flex justify-content-between col-md-12 pl-0 pr-0">
                <div className="w-50">
                  <h5 className="form-container_sub-title ml-0 stats-card-title">Conversaciones nuevas VS recurrentes</h5>
                </div>
                <div className="w-50 pl-20">
                  <Select
                    options={agentsOptions}
                    value={agentSelected2}
                    className="stats-selector"
                    classNamePrefix="stats-selector"
                    onChange={getNewAndRecurringConversations}
                    placeholder="Todos los agentes"
                  />
                </div>
              </div>

              <div className="col-md-12 pl-0 pr-0">
                <div className="stats-card-row-values">
                  <span className="stats-card-label">Conversaciones nuevas</span>
                  <span className="stats-card-label">{newAndRecurringConversations.newConversations}</span>
                </div>
                <Progressbar bgcolor="#3CAAE1" progress={newAndRecurringConversations.percentageNewConversations} height={32} />
                <div className="stats-card-row-values">
                  <span className="stats-card-label">Conversaciones recurrentes</span>
                  <span className="stats-card-label">{newAndRecurringConversations.recurringConversations}</span>
                </div>
                <Progressbar bgcolor="#3CAAE1" progress={newAndRecurringConversations.percentageRecurringConversations} height={32} />
              </div>
            </div>
          </div>
        </div>

        <div className="row mt-24 col-md-12 pr-0 pl-0">
          <div className="col-md-6 pr-12 stats-card">
            <div className="col-md-12 box-container pt-30 pr-30 pb-30 pl-30 mh-vh-40">
              <div className="d-flex justify-content-between col-md-12 pl-0 pr-0 align-items-center">
                <h5 className="form-container_sub-title ml-0 stats-card-title pb-0 w-50">Rendimiento por agente</h5>
                <div className="w-50 pl-20">
                  <Select
                    options={agentPerformancePlatforms}
                    value={selectedPlatform1}
                    className="stats-selector"
                    classNamePrefix="stats-selector"
                    onChange={getAgentPerformance}
                    placeholder="Todas las plataformas"
                  />
                </div>
              </div>

              <table className="table table-borderless stats-table">
                <thead>
                  <tr>
                    <th scope="col">Agente</th>
                    <th scope="col">Total</th>
                    <th scope="col">Pendientes</th>
                    <th scope="col">Resueltos</th>
                  </tr>
                </thead>
                <tbody>
                  {agentPerformance.map((agentStat, index) => (
                    <tr key={index.toString()}>
                      <td>
                        <AvatarName name={`${agentStat.first_name} ${agentStat.last_name}`} />
                      </td>
                      <td className="text-right">{(agentStat.amount_chat_in_process + agentStat.amount_chat_resolved)}</td>
                      <td className="text-right">{agentStat.amount_chat_in_process}</td>
                      <td className="text-right">{agentStat.amount_chat_resolved}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div className="col-md-6 pl-12 stats-card">
            <div className="col-md-12 box-container pt-30 pr-30 pb-30 pl-30">
              <div className="d-flex justify-content-between col-md-12 pl-0 pr-0 align-items-center">
                <h5 className="form-container_sub-title ml-0 stats-card-title pb-0 w-50">Mensajes enviados por</h5>
                <Select
                  options={platforms}
                  value={selectedPlatform2}
                  className="stats-selector w-50 pl-20"
                  classNamePrefix="stats-selector"
                  onChange={getSentMessagesBy}
                  placeholder="Todas las plataformas"
                />
              </div>

              <table className="table table-borderless stats-table">
                <thead>
                  <tr>
                    <th scope="col">Agente</th>
                    <th scope="col" className="text-center">Total</th>
                  </tr>
                </thead>
                <tbody>
                  {setMessagesBy.map((agentStat) => (
                    <tr key={agentStat.retailer_user_id}>
                      <td>
                        <AvatarName name={`${agentStat.first_name} ${agentStat.last_name}`} />
                      </td>
                      <td className="text-right">{agentStat.total_messages}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StatsComponent;