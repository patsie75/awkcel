#!/usr/bin/awk -f

BEGIN {
  srand()

  lregion = split("North East South West", region)
  lgender = split("Male Female", gender)
  lstyle  = split("Tee Golf Fancy", style)
  ldate = split("01-31 02-28 03-31 04-30 05-31 05-30", shipdate)

  printf("%s;%s;%s;%s;%s;%s;%s\n", "Region", "Gender", "Style", "Ship date", "Units", "Price", "Cost")

  for (line=1; line<=100; line++) {
    regn = int(rand() * lregion) + 1
    gndr = int(rand() * lgender) + 1
    styl = int(rand() * lstyle) + 1
    date = int(rand() * ldate) + 1

    units = int(rand() * 99) + 1
    price = rand() * 99
    cost = price - (rand() * (price * 0.1) + (price * 0.1))

    printf("%s;%s;%s;2005-%s;%d;%.2f;%.2f\n", region[regn], gender[gndr], style[styl], shipdate[date], units, price, cost)
  }
}
