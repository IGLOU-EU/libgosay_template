#!/bin/bash
err() {
    echo "FATAL ERROR: ${1}"
    exit 1
}

quit() {
    log 0 "Program Termination"
    exit 0
}

clear() {
    log 0 "Clear temporary folder \`${1}\`"

    cd "${pwd}" || log 1 "Fail to move to \`${pwd}\`"
    rm -rf "${1}"
}

log() {
    local _buff=""

    if [ "$1" -eq 1 ]; then _buff="ERROR"
    else _buff="INFO "; fi

    _buff="[${_buff}] $(date '+%H%M%S-%d%m%y'): ${2}"

    echo "${_buff}" >&2
    return "$1"
}

tmp_dir() {
    log 0 "Make a temporary folder"

    local _tmp
    _tmp="$(mktemp -d)"

    echo "$_tmp"
}

builder() {
    log 0 "Convert a template to gosay template"
    local _builder="${1}"

    # Define
    log 0 "Define local var for parsing"
    local _tmp
    _tmp="$(tmp_dir)"

    local -a _tmpIO _fout
    _tmpIO[0]="/in"
    _tmpIO[1]="/out"
    _fout="${2}"

    local _git
    _git="${3}"

    local _template _templateExt
    _template="${_tmp}${_tmpIO[0]}/${4}"
    _templateExt=".${5}"

    # Func
    log 0 "Move to tmp folder"
    cd "${_tmp}" || { log 1 "Can't go to tmp file \`${_tmp}\`"; return; }

    log 0 "Create I/O folder"
    mkdir -p "${_tmp}${_tmpIO[0]}"
    mkdir -p "${_tmp}${_tmpIO[1]}"

    log 0 "Clone repository"
    git clone "$_git" "${_tmp}${_tmpIO[0]}"

    _b="$IFS"
    IFS=''
    log 0 "Parsse and convert ${_templateExt} file"
    for file in "${_template}/"*"${_templateExt}"; do
        local _fName

        _fName="$(basename "$file")"
        _fName="${_fName%.*}.gosay"

        # Save to out
        log 0 "Save result to ${_fName}"
        echo "{{/* From ${_git} */}}" > "${_tmp}${_tmpIO[1]}/${_fName}"
        ${_builder} "$file" >> "${_tmp}${_tmpIO[1]}/${_fName}"
    done
    IFS="$_b"

    log 0 "Move result from \`${_tmp}${_tmpIO[1]}/\` to \`${pwd}/${_fout}/\`"
    mkdir -p "${pwd}/${_fout}/"
    mv "${_tmp}${_tmpIO[1]}/"* "${pwd}/${_fout}/"
    clear "${_tmp}"
}

from_cowmore() {
    local -A _var
    local _buff _comm _page

    _comm=""
    _page="${1}"
    _buff=" {{.Said}}"

    while read -r line; do
        if [[ $line == "EOC"* ]] || [[ $line == "\$the_cow"* ]] || [[ $line == "" ]]; then
            continue
        fi

        # Create color library var
        if [[ $line == "\$"*"= "* ]]; then
            local _i _v
            _i="${line%% *}"
            _v="$(echo "${line}" | sed -r -E 's/[^=]* = "([^"]+)".*/\1/g')"

            _var[${_i/\$/}]="${_v}"
            continue
        fi

        # Licence / Artiste
        if [[ $line == \#* ]]; then
            if [[ ${#line} -lt 3 ]]; then
                continue
            fi

            if [[ $_comm == "" ]]; then
                _comm="{{/* ${line#### } */}}"
            else
                _comm="${_comm}"$'\n'"{{/* ${line#### } */}}"
            fi

            continue
        fi

        #extract body
        _buff="${_buff}"$'\n'"${line}"
    done < "${_page}"

    # Replace
    for i in "${!_var[@]}"; do
        _buff="${_buff//\$$i/${_var[$i]}}"
    done

    _buff="${_buff//\$eyes/\{\{.EyeL\}\}\{\{.EyeR\}\}}"
    _buff="${_buff//\$tongue/\{\{.Tongue\}\}}"
    _buff="${_buff//\$thoughts/\{\{.Tail\}\}}"

    _buff="${_comm}"$'\n'"${_buff}"
    echo "$_buff"
}

from_cowsay() {
    local _buff _comm

    _comm=""
    _buff=" {{.Said}}"

    while read -r line; do
        if [[ $line == "EOC"* ]] || [[ $line == "\$"*"= "* ]]; then
            continue
        fi

        if [[ $line == \#* ]]; then
            if [[ ${#line} -lt 5 ]]; then
                continue
            fi

            # Licence / Artiste
            if [[ $_comm == "" ]]; then
                _comm="{{/* ${line#### } */}}"
            else
                _comm="${_comm}"$'\n'"{{/* ${line#### } */}}"
            fi

            continue
        fi

        # Replace
        line="${line/\$eyes/\{\{.EyeL\}\}\{\{.EyeR\}\}}"
        line="${line/\$tongue/\{\{.Tongue\}\}}"
        line="${line/\$thoughts/\{\{.Tail\}\}}"

        # Add to buff
        _buff="${_buff}"$'\n'"${line}"
    done < "${1}"

    _buff="${_comm}"$'\n'"${_buff}"
    echo "$_buff"
}

build_cowsay() {
    builder "from_cowsay" "cowsay" "https://github.com/schacon/cowsay" "cows" "cow"
}

build_cowmore() {
    builder "from_cowmore" "cowmore" "https://github.com/paulkaefer/cowsay-files.git" "cows" "cow"
}

pwd="$(pwd)"
log 0 "Programme is runing at \`${pwd}\`"

    case "$1" in
        "cowsay")
            build_cowsay
            ;;

        "cowmore")
            build_cowmore
            ;;

        *)
            build_cowsay
            build_cowmore
            ;;
    esac

quit