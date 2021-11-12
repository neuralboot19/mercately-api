import React from "react";
import Column from "./Column";

const ColumnInnerList = ({
  column,
  dealMap,
  index,
  allowColumn,
  openCreateDeal,
  toggleEditDeal,
  deleteStep,
  deleteDeal,
  loadMoreDeals
}) => {
  const deals = column.dealIds.map((dealId) => dealMap[dealId]);
  return (
    <Column
      column={column}
      deals={deals}
      index={index}
      openCreateDeal={openCreateDeal}
      toggleEditDeal={toggleEditDeal}
      deleteStep={deleteStep}
      deleteDeal={deleteDeal}
      loadMoreDeals={loadMoreDeals}
      allowColumn={allowColumn}
    />
  );
};

export default ColumnInnerList;
