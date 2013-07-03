#!/bin/bash

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
