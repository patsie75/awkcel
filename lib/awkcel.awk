BEGIN {
  srand()

  ## get terminal size
  #"stty size" | getline
  #close("stty size")
  #terminal["width"] = $2
  #terminal["height"] = $1

  COLOR["black"]                = 30
  COLOR["red"]                  = 31
  COLOR["green"]                = 32
  COLOR["yellow"]               = 33
  COLOR["blue"]                 = 34
  COLOR["magenta"]              = 35
  COLOR["cyan"]                 = 36
  COLOR["white"]                = 37
  COLOR["grey"] = COLOR["gray"] = 90
  COLOR["bright red"]           = 91
  COLOR["bright green"]         = 92
  COLOR["bright yellow"]        = 93
  COLOR["bright blue"]          = 94
  COLOR["bright magenta"]       = 95
  COLOR["bright cyan"]          = 96
  COLOR["bright white"]         = 97

  # have ord and chr tables
  for (i=0; i<256; i++) {
    ORD[sprintf("%c", i)] = i
    CHR[i] = sprintf("%c", i)
  }

  # labels
  split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", labels, "")
}

function f_cnt(a,     i, cnt) { for (i in a) if (a[i] != "") cnt++; return cnt }
function f_sum(a,     i, sum) { for (i in a) sum += a[i]; return sum }
function f_avg(a)             { return f_sum(a) / f_cnt(a) }
function f_min(a,     i, min) { min = 9999999999; for (i in a) min = (a[i] < min) ? a[i] : min; return min }
function f_max(a,     i, max) { for (i in a) max = (a[i] > max) ? a[i] : max; return max }
function f_rnd(a, b) { return rand() * a + b }

function xls_getpage(self) { return self["page"] }
function xls_setpage(self, val) { self["page"] = val }
function xls_setwidth(self, column, width) { self[self["page"],toupper(column),"width"] = width }
function xls_getwidth(self, column) { return self[self["page"],toupper(column),"width"] }

function xls_init(self,     i) {
  self["width"] = 100
  self["height"] = 20

  self["page"] = 1
  for (i=1; i<=4; i++) {
    self[i,"cursor","x"] = 1
    self[i,"cursor","y"] = 1
  }
}

function xls_addrow(self, data,     page, f, arr) {
  page = self["page"]
  self[page,"NR"]++

  if (data != "") {
    NF = split(data, arr)
    for (f=1; f<=NF; f++)
      self[page,labels[f],self[page,"NR"],"value"] = arr[f]
  } else {
    for (f=1; f<=NF; f++)
      self[page,labels[f],self[page,"NR"],"value"] = $f
  }
}

function xls_range(self, str, arr,     n, i, a_tmp, a1, a2, b1, b2) {
  n = split(toupper(str), a_tmp, ":")

  if (n == 1) {
    delete arr

    a1 = a2 = a_tmp[1]
    gsub(/[^A-Z]/, "", a1)
    gsub(/[^0-9]/, "", a2)

    arr[a2] = cell_value(self, a1, a2)

    return a1
  }

  if (n == 2) {
    delete arr

    a1 = a2 = a_tmp[1]
    gsub(/[^A-Z]/, "", a1)
    gsub(/[^0-9]/, "", a2)

    b1 = b2 = a_tmp[2]
    gsub(/[^A-Z]/, "", b1)
    gsub(/[^0-9]/, "", b2)

    # vertical column
    if (a1 == b1) {
      for (i=int(a2); i<=int(b2); i++)
        arr[i] = cell_value(self, a1, i)
      return a1
    }

    # horizontal row
    if (a2 == b2) {
      for (i=ORD[a1]; i<=ORD[b1]; i++)
        arr[i] = cell_value(self, CHR[i], a2)
      return a2
    }
  } else return
}

function cell_value(self, x,y,     content,page,lhs,rhs,op) {
  page = self["page"]
  content = self[page,x,y,"value"]

  if (content ~ /^=[A-Z]+[0-9]+/) {
    lhs = self[page,substr(content,2,1),substr(content,3,1),"value"]
    op  = substr(content, 4, 1)
    rhs = self[page,substr(content,5,1),substr(content,6,1),"value"]

    if (op == "+") return (lhs + rhs)
    if (op == "-") return (lhs - rhs)
    if (op == "*") return (lhs * rhs)
    if (op == "/") return (lhs / rhs)

    return "[error]"
  }

  if (content ~ /=[a-z][a-z][a-z]\([A-Z]+[0-9]+:[A-Z]+[0-9]+\)/) {
    op = substr(content, 2, 3)
    range = substr(content, 6, length(content) - 6)

    xls_range(self, range, a_tmp)

    if (op == "cnt") return f_cnt(a_tmp)
    if (op == "sum") return f_sum(a_tmp)
    if (op == "avg") return f_avg(a_tmp)
    if (op == "min") return f_min(a_tmp)
    if (op == "max") return f_max(a_tmp)
    return "[error]"
  }

  if (content ~ /=rnd\([0-9]+:?([0-9]+)?\)/) {
    op = substr(content, 2, 3)
    v1 = substr(content, 6, index(content, ":") - 6)
    v2 = substr(content, index(content, ":") + 1, length(content) - index(content, ":") - 1 )

    return rand() * v1 + v2
  }
  return content
}

function cell_print(self,x, y,     page, w, val, fg, bg) {
  page = self["page"]
  w   = self[page,x,"width"] ? self[page,x,"width"] : 11
  val = cell_value(self, x,y)
  fg  = self[page,x,y,"fg"] ? self[page,x,y,"fg"] : COLOR["black"]
  bg  = self[page,x,y,"bg"] ? self[page,x,y,"bg"] : (y%2) ? COLOR["white"] : COLOR["bright white"]

  c1 = " "
  c2 = "|"
  #c2 = self[page,"cursor","y"] == y ? self[page,"cursor","x"] == ORD[x]-64 ? "]" : "|" : "|"
  printf("\033[%s;%sm%*s%c\033[0m", fg, bg+10, w, substr(val,1,w), c2)
}

function xls_cursor(self, x, y,    page) {
  page = self["page"]

  #if (self[page,"cursor","y"] == y) {
  #  if (self[page,"cursor","x"] == (x+1)) return "["
  #  if (self[page,"cursor","x"] == x) return "]"
  #}
  return "|"
}

function xls_setcolor(self, str, fg, bg,     n, a_tmp, page) {
  n = xls_range(self, str, a_tmp)
  page = self["page"]

  # vertical range
  if (n ~ /^[A-Z]+$/) {
    for (i in a_tmp) {
      self[page, n, i, "fg"] = fg ? COLOR[fg] : self[page, n, i, "fg"]
      self[page, n, i, "bg"] = bg ? COLOR[bg] : self[page, n, i, "bg"]
    }
  }
  # horixontal range
  if (n ~ /^[0-9]+$/) {
    for (i in a_tmp) {
      self[page, CHR[i], n, "fg"] = fg ? COLOR[fg] : self[page, i, n, "fg"]
      self[page, CHR[i], n, "bg"] = bg ? COLOR[bg] : self[page, i, n, "bg"]
    }
  }
}

function xls_statusbar(self,     page, x,y, i, fg,bg, s_page, barlen) {
  page = self["page"]
  x = labels[ self[page, "cursor","x"] ]
  y = self[page, "cursor","y"]

  for (i=1; i<=4; i++) {
    if (i == page)
      s_page = s_page sprintf("\033[%s;%sm/%10s|\033[%s;%sm", COLOR["bright white"], COLOR["black"]+10, self[i,"name"] ? self[i,"name"] : "page "i, COLOR["black"], COLOR["white"]+10)
    else
      s_page = s_page sprintf("/%10s|", self[i,"name"] ? self[i,"name"] : "page "i)
  }

  barlen = 30
  printf("\033[%s;%sm [%-6s] [%-*s] %74s\033[0m\n", COLOR["black"], COLOR["white"]+10, x "" y, barlen, substr(self[page,x,y,"value"],1,barlen), s_page)
}

function xls_print(self,     n, page, arrx, x, y, w, fg, bg, width) {
  n = split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", arrx, "")
  page = self["page"]

  # draw status bar
  xls_statusbar(self)

  # draw top column labels
  width = 0
  for (xx=0; xx<=n && (width+11)<=self["width"]; xx++) {
    w = self[page,arrx[xx],"width"] ? self[page,arrx[xx],"width"] : (xx == 0) ? 4 : 11
    printf("\033[%s;%sm%*s%c", COLOR["bright white"], COLOR["bright blue"]+10, w, arrx[xx], xls_cursor(self, xx,0))
    width += w
  }
  printf("\033[0m\n")

  # draw rows
  for (y=1; y<=self["height"]; y++) {
    fg = COLOR["bright white"]
    bg = (y%2) ? COLOR["blue"] : COLOR["bright blue"]

    # row number
    printf("\033[%s;%sm%*s%c", fg, bg+10, 4, y, xls_cursor(self, 0,y))

    # field contents
    for (x=1; x<xx; x++)
      cell_print(self, arrx[x],y)
    printf("\033[0m\n")
  }
}
