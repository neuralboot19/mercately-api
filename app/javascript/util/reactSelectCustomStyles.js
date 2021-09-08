const reactSelectCustomStyles = {
  control: () => ({
    display: 'flex'
  }),
  menu: (provided, state) => ({
    ...provided,
    width: '98%',
    color: state.selectProps.menuColor,
    marginTop: -10,
    marginLeft: '1%',
  }),
  option: (provided, state) => ({
    ...provided,
    padding: 10,
    marginTop: -4
  })
}

export default reactSelectCustomStyles;