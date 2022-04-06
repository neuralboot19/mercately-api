let hours = []
for (let i = 0; i <= 24; i++) {
  hours.push({
    value: i,
    label: `${i < 12 ? i : (i == 12 ? i : i - 12) } ${i < 12 ? 'a.m.' : (i == 12 ? 'm.' : 'p.m.')}`
  })
}
export const HOURS_OPTIONS = hours;

export const INTERVALS = [
  {value: 12, label: '12 horas'},
  {value: 24, label: '24 horas'},
  {value: 48, label: '48 horas'},
  {value: 72, label: '72 horas'},
  {value: 96, label: '96 horas'}
]