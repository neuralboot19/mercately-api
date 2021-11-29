import React from 'react';

const CustomerTags = ({ tags }) => (
  <>
    {
      tags.map((tag) => (
        <div className="col-auto" key={tag.id}>
          <div
            key={tag.id}
            className="customer-tags-chats p-6"
            style={ { backgroundColor: tag.tag_color,
              color: tag.font_color,
              borderColor: tag.font_color }
            }>
            {tag.tag}
          </div>
        </div>
      ))
    }
  </>
);

export default CustomerTags;
