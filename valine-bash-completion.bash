# This file is part of valine, providing intelligent valine tab-completion for BASH
# Save it to: /etc/bash_completion.d/
#
# Revision date:  2014/07/17 matching up with valine 0.1.1
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

_valine()  {
  
    # Variables
    local curr prev prevX2 virtDomains
  
    # Wipe out COMPREPLY array
    COMPREPLY=()
  
    # Set cur & prev appropriately
    curr=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    prevX2=${COMP_WORDS[COMP_CWORD-2]}

    virtDomains=$(virsh list --all --name)
    
    # Check previous arg to see if we need to do anything special
    case "${prev}" in
        valine)
            COMPREPLY=( $(compgen -W "--all ${virtDomains}" -- "${curr}") )
            return 0
            ;;
        --help|-h|list|l|new|n|start|s|shutdown|h|destroy|d|console|c)
            return 0
            ;;
        revert|r|delete|e)
            [[ ${prevX2} != --all ]] \
                && COMPREPLY=( $(compgen -W "$(virsh snapshot-list ${prevX2} --name)" -- "${curr}") )
            return 0
            ;;
        --all)
            COMPREPLY=( $(compgen -W "new revert start shutdown destroy" -- "${curr}") )
            ;;
        *)
            grep -wsq ${prev} <<<"${virtDomains}" \
                && COMPREPLY=( $(compgen -W "list new revert delete start shutdown destroy console" -- "${curr}") )
            return 0
    esac

}

# Add the names of any valine aliases (or alternate file-names) to the end of the following line
complete -F _valine valine

