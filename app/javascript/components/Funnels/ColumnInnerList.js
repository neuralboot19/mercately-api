import React from "react";
import Column from "./Column";

const ColumnInnerList = ({
  column,
  dealMap,
  index,
  allowColumn,
  openCreateDeal,
  openDeleteStep,
  openDeleteDeal
}) => {
  const deals = column.dealIds.map((dealId) => dealMap[dealId]);
  return (
    <Column
      column={column}
      deals={deals}
      index={index}
      openCreateDeal={openCreateDeal}
      openDeleteStep={openDeleteStep}
      openDeleteDeal={openDeleteDeal}
      allowColumn={allowColumn}
    />
  );
};

export default ColumnInnerList;
