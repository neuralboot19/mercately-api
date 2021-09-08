const modalCustomStyles = (isMobile, otherStyles) => {
  const styles = {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)',
    height: '80vh',
    borderRadius: '12px',
    width: isMobile ? '90%' : '50%'
  }
  const overlay = {
    backgroundColor: 'rgba(0, 0, 0, 0.35)',
    backdropFilter: 'blur(9px)',
    zIndex: 10
  }
  
  return { overlay, content: { ...styles, ...otherStyles }}; 
}
export default modalCustomStyles;