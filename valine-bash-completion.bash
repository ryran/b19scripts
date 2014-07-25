# This file is part of valine, providing intelligent valine tab-completion for BASH
# Save it to: /etc/bash_completion.d/
#
# Revision date:  2014/07/25 matching up with valine 0.3.2
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

_VIRSH() {
    # When bash running as non-root, the expectation is that you have sudo nopasswd access to virsh command
    sudo virsh "${@}" 2>/dev/null
}

_valine()  {
  
    # Variables
    local curr prev prevX2 virtDomains
    
    # Wipe out COMPREPLY array
    COMPREPLY=()
  
    # Set cur & prev appropriately
    curr=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    prevX2=${COMP_WORDS[COMP_CWORD-2]}

    virtDomains=$(_VIRSH list --all --name)
    
    # Check previous arg to see if we need to do anything special
    case "${prev}" in
        valine)
            COMPREPLY=( $(compgen -W "-a --all ${virtDomains}" -- "${curr}") )
            ;;
        --help|-h|--off|list|l|start|s|shutdown|h|destroy|d|console|c)
            ;;
        new|n)
            COMPREPLY=( $(compgen -W "--off" -- "${curr}") )
            ;;
        revert|r)
            case "${prevX2}" in
                --all|-a)
                    COMPREPLY=( $(compgen -W "--off" -- "${curr}") )  ;;
                *)
                    if _VIRSH list --all --name | grep -q "^${prevX2}$"; then
                        COMPREPLY=( $(compgen -W "--off $(_VIRSH snapshot-list ${prevX2} --name)" -- "${curr}") )
                    fi
            esac
            ;;
        Delete|D)
            case "${prevX2}" in
                --all|-a)
                    : ;;
                *)
                    if _VIRSH list --all --name | grep -q "^${prevX2}$"; then
                        COMPREPLY=( $(compgen -W "$(_VIRSH snapshot-list ${prevX2} --name)" -- "${curr}") )
                    fi
            esac
            ;;
        --all|-a)
            COMPREPLY=( $(compgen -W "--off new revert start shutdown destroy" -- "${curr}") )
            ;;
        *)
            if grep -wsq -- ${prev} &>/dev/null <<<"${virtDomains}"; then
                COMPREPLY=( $(compgen -W "--off list new revert Delete start shutdown destroy console" -- "${curr}") )
            fi
    esac
    return 0

}

# Add the names of any valine aliases (or alternate file-names) to the end of the following line
complete -F _valine valine
