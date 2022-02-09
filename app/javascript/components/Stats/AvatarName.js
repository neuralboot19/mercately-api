import React from "react";

const AvatarName = ({ name }) => {
  const names = name.split(' ');
  const initials = names.length > 1 ? `${names[0][0]}${names[1][0]}` : `${name[0]}${name[1]}`;
  return (
    <div className="d-flex align-items-center">
      <div className="stats-avatar flex-center-xy">
        {initials}
      </div>
      {name}
    </div>
  );
};

export default AvatarName;
