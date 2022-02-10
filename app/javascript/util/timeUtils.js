import Big from 'big.js';

const secondsToHms = (d) => {
  d = Number(d);
  const h = Math.floor(d / 3600);
  const m = Math.floor(d % 3600 / 60);
  const s = Math.floor(d % 3600 % 60);

  const hDisplay = h > 0 ? h + (h == 1 ? " hora, " : " horas, ") : "";
  const mDisplay = m > 0 ? m + (m == 1 ? " minuto, " : " minutos, ") : "";
  const sDisplay = s > 0 ? s + (s == 1 ? " segundo" : " segundos") : "";
  return hDisplay + mDisplay + sDisplay; 
}

const secondsToH = (d) => {
  d = Number(d);
  const h = Number(Big(d).div(3600).round(2));
  return `${h} hr`;
}

export default {
  secondsToHms,
  secondsToH
};
