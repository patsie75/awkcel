#!/usr/bin/awk -f
BEGIN {
  xls_init(book)
}

{
  xls_addrow(book)
}

END {
  xls_print(book)
}
