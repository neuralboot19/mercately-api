import React, { useState } from 'react';
import SearchIcon from 'images/search.svg';

const searchInput = ({
  applySearch,
  placeholder
}) => {
  const [searchText, setSearchText] = useState('');

  const handleInputChange = (e) => {
    e.preventDefault();
    const input = e.target;
    let { value } = input;
    setSearchText(value)
  };

  const handleKeyPress = (event) => {
    if (event.key === "Enter") {
      applySearch(searchText);
    }
  }

  return(
    <>
      <div className="col-md-6">
        <div className="p-relative">
          <input
            type="text"
            value={searchText}
            placeholder={placeholder || "Buscar"}
            className="input-icon bg-white search-funnels-input"
            onChange={handleInputChange}
            onKeyPress={handleKeyPress}
          />
          <span className="p-absolute icon-search">
            <img src={SearchIcon} alt="search icon" />
          </span>
        </div>
      </div>
      <button type="button" onClick={() => applySearch(searchText)} className="btn-btn btn-submit btn-primary-style mt-5">
        Buscar
      </button>
    </>
  )
}

export default searchInput;