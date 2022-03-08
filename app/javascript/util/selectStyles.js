const selectStyles = {
  option: (provided) => ({
    ...provided
  }),
  control: (provided) => ({
    ...provided,
    background: '#F7F8FD',
    borderRadius: '12px',
    border: 'none',
    height: '48px',
    fontSize: '14px',
    color: '#3C4348',
    width: '100%'
  }),
  placeholder: (provided) => ({
    ...provided,
    color: '#3C4348'
  }),
  menuPortal: base => ({ ...base, zIndex: 9999 })
};

export default selectStyles;