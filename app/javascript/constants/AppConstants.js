let hours = []
for (let i = 0; i <= 24; i++) {
  hours.push({
    value: i,
    label: `${i < 12 ? i : (i == 12 ? i : i - 12) } ${i < 12 ? 'a.m.' : (i == 12 ? 'm.' : 'p.m.')}`
  })
}
export const HOURS_OPTIONS = hours;

export const INTERVALS = [
  {value: 1, label: '1 hora'},
  {value: 2, label: '2 horas'},
  {value: 4, label: '4 horas'},
  {value: 8, label: '8 horas'},
  {value: 12, label: '12 horas'},
  {value: 24, label: '24 horas'},
  {value: 48, label: '48 horas'},
  {value: 72, label: '72 horas'},
  {value: 96, label: '96 horas'}
]
