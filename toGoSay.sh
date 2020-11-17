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

build_cowsay() {
    log 0 "Convert cowsay template to gosay template"

    # Define
    log 0 "Define local var for parsing"
    local _tmp
    _tmp="$(tmp_dir)"

    local -a _tmpIO
    _tmpIO[0]="/in"
    _tmpIO[1]="/out"

    local _git
    _git="https://github.com/schacon/cowsay"

    local _template _templateExt
    _template="${_tmp}${_tmpIO[0]}/cows"
    _templateExt=".cow"

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
        local _fName _buff _comm

        _fName="$(basename "$file")"
        _fName="${_fName%.*}.gosay"

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
        done < "$file"

        # Save to out
        log 0 "Save result to ${_fName}"
        _buff="${_comm}"$'\n'"${_buff}"
        echo "$_buff" > "${_tmp}${_tmpIO[1]}/${_fName}"
    done
    IFS="$_b"

    #aller en fichier tmp 
    #creer fichier in 
    #    clone git
    #    define in cow
    #creer fichier out
    #parser fichier in 
    #    transformer en out 
    ##    enregistrer en out
    ##mv vers final folder

    log 0 "Move result from \`${_tmp}${_tmpIO[1]}/\` to \`${pwd}/cowsay/\`"
    mv "${_tmp}${_tmpIO[1]}/"* "${pwd}/cowsay/"
    clear "${_tmp}"
}

pwd="$(pwd)"
log 0 "Programme is runing at \`${pwd}\`"

case "$1" in
  "cowsay")
    build_cowsay
    ;;

  *)
    build_cowsay
    ;;
esac

quit