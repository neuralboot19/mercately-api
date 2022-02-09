import React from 'react';

const ProgressBar = ({ bgcolor, progress, height }) => {
  const Parentdiv = {
    height,
    backgroundColor: 'whitesmoke',
    marginBottom: 10
  };

  const Childdiv = {
    height: '100%',
    width: `${progress}%`,
    backgroundColor: bgcolor
  };

  const progresstext = {
    color: 'white',
    fontWeight: 600
  };

  return (
    <div style={Parentdiv}>
      <div style={Childdiv} className="flex-center-xy">
        <span style={progresstext}>{`${progress}%`}</span>
      </div>
    </div>
  );
};

export default ProgressBar;
