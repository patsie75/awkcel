#!/usr/bin/env bash

function do_type {
  wait=$1; shift

  str="$*"

  if [[ $wait -ne 0 ]]; then
    echo -n "$str"
  else
    for ((i=0; i<${#str}; i++)); do
      echo -n "${str:i:1}"
      rnd=$( printf "0.%02d" "$((RANDOM % 10 + 5))" )
      sleep "$rnd"
    done
  fi

  sleep 1
}

function do_cmd {
  wait="$1"; shift
  do_type "$wait" "$*"
  eval "clear; $@"
  echo -n "$> "
  sleep 3
}
 
RANDOM=$(date +%s)

echo -n "$> "
sleep 2

do_cmd 0 'ls -lR'

do_cmd 0 'awk -f examples/gen_pivot | tee pivot.csv | head -20'

do_cmd 0 'cat examples/simple.awk'
do_cmd 0 'awk -F";" -f lib/awkcel -f examples/simple < pivot.csv'

do_cmd 0 'awk -F";" -f lib/awkcel -f examples/pivot -v column="Ship date" -v row="Region" -v data="Units" -v fnc="sum" < pivot.csv'
sleep 2

do_cmd 1 'awk -F";" -f lib/awkcel -f examples/simple < pivot.csv'
do_cmd 0 'awk -F";" -f lib/awkcel -f examples/pivot -v column="Gender" -v row="Style" -v data="Price" -v fnc="avg" < pivot.csv'

do_cmd 1 'awk -F";" -f lib/awkcel -f examples/simple < pivot.csv'
do_cmd 0 'awk -F";" -f lib/awkcel -f examples/pivot -v column="Style" -v row="Gender" -v data="Cost" -v fnc="avg" < pivot.csv'

do_cmd 1 'awk -F";" -f lib/awkcel -f examples/simple < pivot.csv'
do_cmd 0 'awk -F";" -f lib/awkcel -f examples/pivot -v column="Region" -v row="Ship date" -v data="Price" -v fnc="min" < pivot.csv'
do_cmd 1 'awk -F";" -f lib/awkcel -f examples/pivot -v column="Region" -v row="Ship date" -v data="Price" -v fnc="max" < pivot.csv'
do_cmd 1 'awk -F";" -f lib/awkcel -f examples/pivot -v column="Region" -v row="Ship date" -v data="Price" -v fnc="cnt" < pivot.csv'
do_cmd 1 'awk -F";" -f lib/awkcel -f examples/pivot -v column="Region" -v row="Ship date" -v data="Price" -v fnc="sum" < pivot.csv'
do_cmd 1 'awk -F";" -f lib/awkcel -f examples/pivot -v column="Region" -v row="Ship date" -v data="Price" -v fnc="avg" < pivot.csv'
sleep 2
