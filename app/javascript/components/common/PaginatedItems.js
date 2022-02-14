import React, {
  useEffect,
  useState
} from "react";
import ReactPaginate from 'react-paginate';
import Tag from '../Stats/Tag';

const Items = ({ currentItems }) => {
  return (
    <div className="items">
      {currentItems && currentItems.map((item) => (
        <Tag key={item.id} tag={item} />
      ))}
    </div>
  );
}

const PaginatedItems = ({ items, itemsPerPage }) => {
  const [currentItems, setCurrentItems] = useState(null);
  const [pageCount, setPageCount] = useState(0);
  const [itemOffset, setItemOffset] = useState(0);

  useEffect(() => {
    const endOffset = itemOffset + itemsPerPage;

    setCurrentItems(items.slice(itemOffset, endOffset));
    setPageCount(Math.ceil(items.length / itemsPerPage));
  }, [itemOffset, itemsPerPage]);

  const handlePageClick = (event) => {
    const newOffset = event.selected * itemsPerPage % items.length;
    setItemOffset(newOffset);
  };

  return (
    <div className="stats-pagination">
      <Items currentItems={currentItems} />
      <ReactPaginate
        nextLabel="Siguiente >"
        onPageChange={handlePageClick}
        pageRangeDisplayed={3}
        marginPagesDisplayed={2}
        pageCount={pageCount}
        previousLabel="< Anterior"
        pageClassName="page-item"
        pageLinkClassName="page-link"
        previousClassName="page-item"
        previousLinkClassName="page-link"
        nextClassName="page-item"
        nextLinkClassName="page-link"
        breakLabel="..."
        breakClassName="page-item"
        breakLinkClassName="page-link"
        containerClassName="pagination"
        activeClassName="active"
        renderOnZeroPageCount={null}
      />
    </div>
  );
}

export default PaginatedItems;