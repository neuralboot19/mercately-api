import React from "react";

const AvatarName = ({ firstName, lastName }) => {
  firstName = firstName.trim();
  lastName = lastName.trim();

  let initials = firstName? `${firstName.charAt(0).toUpperCase()}` : '';
  initials += lastName? `${lastName.charAt(0).toUpperCase()}` : '';

  return (
    <div className="d-flex align-items-center">
      <div className="stats-avatar flex-center-xy">
        {initials}
      </div>
      {`${firstName} ${lastName}`}
    </div>
  );
};

export default AvatarName;
