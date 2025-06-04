#!/usr/bin/awk -f
BEGIN {
  xls_init(book)
}

{
  # add each row of data to the spreadsheet
  xls_addrow(book)
}

END {
  # create pivot table on page 2
  # use "avg" function on column "F" (Price)
  # with column "A" (Region) for columns
  # and column "D" (Ship date) for rows
  xls_pivot(book,2, "avg", "F", "A", "D")

  # set page 2 and show the spreadsheet
  xls_setpage(book,2)
  xls_print(book)
}
