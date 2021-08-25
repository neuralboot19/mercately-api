import React from 'react';

const CustomerTags = ({ tags }) => (
  <>
    {
      tags.map((tag) => (
        <div className="col-auto" key={tag.id}>
          <div key={tag.id} className="customer-tags-chats p-6">
            {tag.tag}
          </div>
        </div>
      ))
    }
  </>
);

export default CustomerTags;
