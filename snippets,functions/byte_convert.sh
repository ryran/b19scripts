#!/bin/bash
# byte_convert.sh v0.10 last mod 2012/12/08
# Latest version at <http://github.com/ryran/b19scripts>
# Copyright 2012, 2013 Ryan Sawhill <ryan@b19.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#    General Public License <gnu.org/licenses/gpl.html> for more details.
#-------------------------------------------------------------------------------
# Save to /etc/profile.d/
# Resource your BASH config files (or reload your shell)
# byte_convert will provide 7 new commands:
# b, k, m, g, t, p, and e
#-------------------------------------------------------------------------------


byte_convert() {
  
  # $1 == $u == initial unit
  # $2 == $n == initial number
  
  local name u n unit reset bold red green orange blue purple cyan
  local -A arr
  
  name=byte-convert
  
  case $1 in
    b|k|m|g|t|p|e)
      :
  ;;
    ?)
      { echo "$name: error with first argument '$1'"
        echo "First arg is binary unit to convert from & must be one of:"
        echo "{ b k m g t p e }"
      } >&2
      return 1
  esac
  
  u=$1
  shift
  
  # Remove commas & spaces
  n=$(sed -e 's/,//g' -e 's/ //g' <<<"$@")
  
  if [[ -z $@ ]] || grep -qs '[^0-9.]' <<<"$n"; then
    { echo "$name: error with second argument '$@'"
      echo "Second arg specifies number to convert from"
      echo "Can only contain numbers & periods (spaces & commas removed)"
    } >&2
    return 1
  fi
  
  
  case $u in
    b)
      arr[b]=$n
     #b
      arr[k]=$(bc <<<"scale=1; ${arr[b]}/1024")
      arr[m]=$(bc <<<"scale=2; ${arr[k]}/1024")
      arr[g]=$(bc <<<"scale=2; ${arr[m]}/1024")
      arr[t]=$(bc <<<"scale=3; ${arr[g]}/1024")
      arr[p]=$(bc <<<"scale=4; ${arr[t]}/1024")
      arr[e]=$(bc <<<"scale=5; ${arr[p]}/1024") 
    ;;
    k)
      arr[k]=$n
      arr[b]=$(bc <<<"scale=0; ${arr[k]}*1024")
     #k
      arr[m]=$(bc <<<"scale=2; ${arr[k]}/1024")
      arr[g]=$(bc <<<"scale=2; ${arr[m]}/1024")
      arr[t]=$(bc <<<"scale=3; ${arr[g]}/1024")
      arr[p]=$(bc <<<"scale=4; ${arr[t]}/1024")
      arr[e]=$(bc <<<"scale=5; ${arr[p]}/1024") 
    ;;  
    m)
      arr[m]=$n
      arr[k]=$(bc <<<"scale=1; ${arr[m]}*1024")
      arr[b]=$(bc <<<"scale=0; ${arr[k]}*1024")
     #m
      arr[g]=$(bc <<<"scale=2; ${arr[m]}/1024")
      arr[t]=$(bc <<<"scale=3; ${arr[g]}/1024")
      arr[p]=$(bc <<<"scale=4; ${arr[t]}/1024")
      arr[e]=$(bc <<<"scale=5; ${arr[p]}/1024") 
    ;;
    g)
      arr[g]=$n
      arr[m]=$(bc <<<"scale=2; ${arr[g]}*1024")
      arr[k]=$(bc <<<"scale=1; ${arr[m]}*1024")
      arr[b]=$(bc <<<"scale=0; ${arr[k]}*1024")
     #g
      arr[t]=$(bc <<<"scale=3; ${arr[g]}/1024")
      arr[p]=$(bc <<<"scale=4; ${arr[t]}/1024")
      arr[e]=$(bc <<<"scale=5; ${arr[p]}/1024") 
    ;;
    t)
      arr[t]=$n
      arr[g]=$(bc <<<"scale=2; ${arr[t]}*1024")
      arr[m]=$(bc <<<"scale=2; ${arr[g]}*1024")
      arr[k]=$(bc <<<"scale=1; ${arr[m]}*1024")
      arr[b]=$(bc <<<"scale=0; ${arr[k]}*1024")
     #t
      arr[p]=$(bc <<<"scale=4; ${arr[t]}/1024")
      arr[e]=$(bc <<<"scale=5; ${arr[p]}/1024") 
    ;;
    p)
      arr[p]=$n
      arr[t]=$(bc <<<"scale=3; ${arr[p]}*1024")
      arr[g]=$(bc <<<"scale=2; ${arr[t]}*1024")
      arr[m]=$(bc <<<"scale=2; ${arr[g]}*1024")
      arr[k]=$(bc <<<"scale=1; ${arr[m]}*1024")
      arr[b]=$(bc <<<"scale=0; ${arr[k]}*1024")
     #p
      arr[e]=$(bc <<<"scale=5; ${arr[p]}/1024") 
    ;;
    e)
      arr[e]=$n
      arr[p]=$(bc <<<"scale=4; ${arr[e]}*1024")
      arr[t]=$(bc <<<"scale=3; ${arr[p]}*1024")
      arr[g]=$(bc <<<"scale=2; ${arr[t]}*1024")
      arr[m]=$(bc <<<"scale=2; ${arr[g]}*1024")
      arr[k]=$(bc <<<"scale=1; ${arr[m]}*1024")
      arr[b]=$(bc <<<"scale=0; ${arr[k]}*1024")
     #e
    ;;
  esac

  reset='\033[0;0m'
  bold='\033[1;30m'
  red='\033[1;31m'
  green='\033[1;32m'
  orange='\033[1;33m'
  blue='\033[1;34m'
  purple='\033[1;35m'
  cyan='\033[1;36m'

  printf "B@KiB@MiB@GiB@TiB@PiB@EiB\n${arr[b]}@${arr[k]}@${arr[m]}@${arr[g]}@${arr[t]}@${arr[p]}@${arr[e]}\n" |
   column -ts@ | 
    awk -vcolor_head="$bold" -vcolor_hilight="$red" -vcolor_reset="$reset" '
      { if (NR == 1) print color_head $0 color_reset
        else printf gensub(/('${arr[$u]}')/, color_hilight"\\1"color_reset, 1)"\n" }
    '

}

# Setup one-letter aliases
for unit in b k m g t p e; do
  alias $unit="byte_convert $unit"
done
