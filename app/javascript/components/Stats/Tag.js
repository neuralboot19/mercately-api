import React from 'react';

const Tag = ({ tag }) => {
  return (
    <div className="stats-card-row-values">
      <span className="stats-card-label">{tag.tag_name}</span>
      <span className="stats-card-label">{tag.amount_used}</span>
    </div>
  );
}

export default Tag;