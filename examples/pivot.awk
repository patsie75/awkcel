#!/usr/bin/awk -f

function is_int(val) { return val+0 == val && int(val) == val }
function is_float(val) { return val+0 == val && int(val) != val }
function is_number(val) { return is_int(val) || is_float(val) }
function is_string(val) { return !is_number(val) }

(NR == 1) {
  # extract label names from header row (#1)
  for (i=1; i<=NF; i++)
    label[$i] = i

  x = label[column]
  y = label[row]
  d = label[data]
}

(NR != 1) {
  # Get unique column and row values and calculate count, sum, min and max values
  cols[$x]
  rows[$y]

  cnt[$y,$x]++
  sum[$y,$x] += $d
  min[$y,$x] = (!(($y,$x) in min) || ($d < min[$y,$x])) ? $d : min[$y,$x]
  max[$y,$x] = (!(($y,$x) in max) || ($d > max[$y,$x])) ? $d : max[$y,$x]
}

# generate pivot table
END {
  xls_init(book)
  #xls_setpage(book, 3)

  # start with function and columns labels
  xls_addrow(book, sprintf("%s(%s)%c%s", fnc, data, FS, column))

  # header row (cols)
  line = row
  for (c in cols)
    line = line FS c

  xls_addrow(book, line)

  # data row prepended with row name value
  for (r in rows) {
    line = r
    for (c in cols) {
      if (fnc == "cnt") val = cnt[r,c]
      if (fnc == "sum") val = sum[r,c]
      if (fnc == "avg") val = cnt[r,c] ? sum[r,c] / cnt[r,c] : "-nan"
      if (fnc == "min") val = min[r,c]
      if (fnc == "max") val = max[r,c]

      # do some better formatting based on cell value
      if (is_float(val)) line = line FS sprintf("%.2f", val)
      else if (is_int(val)) line = line FS sprintf("%d", val)
      else line = line FS sprintf("%s", val)
    }

    xls_addrow(book, line)
  }

  # add "total" line with sum of column values
  line = "Total"
  for (i=2; i<=length(cols)+1; i++)
    line = line sprintf(";=sum(%c3:%c%d)", labels[i], labels[i], book[book["page"],"NR"])

  xls_addrow(book, line);

  # set some colors
  xls_setcolor(book, "A1",  "bright white", "black")
  xls_setcolor(book, "A2",  "bright red", "black")
  xls_setcolor(book, "A3:A30",  "red")

  xls_setcolor(book, "B1",  "bright blue", "black")
  xls_setcolor(book, "B2:H2",   "blue")

  # set cursor
  #book[1,"cursor","x"] = 2
  #book[1,"cursor","y"] = 7

  # print sheet
  #xls_setpage(book, 3)
  xls_print(book)
}
