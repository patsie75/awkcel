#!/usr/bin/awk -f

BEGIN {
  xls_init(book)
}

{
  # read CSV data
  xls_addrow(book)
}

END {
  book["cursor","x"] = 1
  book["cursor","y"] = 1

  book["width"] = 110
  book["height"] = 30

  # select column width
  xls_setwidth(book, "A", 20)
  xls_setwidth(book, "B", 11)
  xls_setwidth(book, "C", 11)
  xls_setwidth(book, "D", 11)
  xls_setwidth(book, "E", 11)
  xls_setwidth(book, "F", 11)
  xls_setwidth(book, "G", 11)
  xls_setwidth(book, "H", 11)

  # set some colors
  xls_setcolor(book, "B1",      "bright white", "red")
  xls_setcolor(book, "B26:B30", "bright white", "red")
  xls_setcolor(book, "C1",      "bright white", "green")
  xls_setcolor(book, "C26:C30", "bright white", "green")
  xls_setcolor(book, "D1",      "bright white", "bright blue")
  xls_setcolor(book, "D26:D30", "bright white", "bright blue")
  xls_setcolor(book, "e1",      "black", "bright yellow")
  xls_setcolor(book, "e26:e30", "black", "bright yellow")

  # make one row (2-24) white on black
  row = int(rand() * 23) + 2
  xls_setcolor(book, "A"row":E"row, "white", "black")

  # color the results of columns F, G and H
  xls_setcolor(book, "F13", "bright white", "red")
  xls_setcolor(book, "G13", "bright white", "green")
  xls_setcolor(book, "H13", "bright white", "blue")

  # fill some cells with "item" in column F
  for (i=2; i<=11; i++)
    if (rand() > 0.5) book[1,"F",i,"value"] = "item"

  # display the data in the terminal
  xls_print(book)
}

