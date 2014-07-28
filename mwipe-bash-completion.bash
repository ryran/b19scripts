# This file is part of mwipe, providing intelligent valine tab-completion for BASH
# Save it to: /etc/bash_completion.d/
#
# Revision date:  2014/07/28 matching up with mwipe 4.5.0
# 
# Copyright 2014 Ryan Sawhill Aroha <rsaw@redhat.com>
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
#
#-------------------------------------------------------------------------------

_mwipe()  {
  
    # Variables
    local curr prev shrtopts longopts
    
    # Wipe out COMPREPLY array
    COMPREPLY=()
  
    # Set cur & prev appropriately
    curr=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    prevX2=${COMP_WORDS[COMP_CWORD-2]}

    shrtopts="-h -y -n -b -r -s -t -f -R -x -d -P -S"
    longopts="--help --bypass --dryrun --background --reboot --shutdown --chvt --full --random --extra --dev --prefix --suffix"
    
    
    # Check previous arg to see if we need to do anything special
    case "${prev}" in
        # Disable autocompletion for options that can only be run alone or we can't autocomplete
        -h|--help|-P|--prefix|-S|--suffix)
            return 0
            ;;
        -d|--dev)
            COMPREPLY=( $(compgen -W "$(awk '$1==8 && $4!~/[0-9]$/ {print "/dev/" $4}' /proc/partitions)" -- "${curr}") )
            return 0
            ;;
    esac
    
    if [[ ${curr} == --* ]]; then
        # If current arg starts w/2 dashes, attempt to autocomplete long opts
        COMPREPLY=( $(compgen -W "${longopts}" -- "${curr}") )
        return 0
    elif [[ ${curr} == -* ]]; then
        # Otherwise, if current only starts w/1 dash, attempt autocomplete short opts
        COMPREPLY=( $(compgen -W "${shrtopts}" -- "${curr}") )
        return 0
    fi
  
}

# Add the names of any valine aliases (or alternate file-names) to the end of the following line
complete -F _mwipe mwipe
