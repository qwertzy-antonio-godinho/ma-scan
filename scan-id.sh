#! /bin/bash

# path to script (basename $0)
CWD=$"/lab/tools/scan-id"

# location of hashes
HASH_DATABASE="$CWD/malware-hash-list.txt"

# hashlist must have header
SSDEEP_HEADER="ssdeep,1.1--blocksize:hash:hash,filename"

# ssdeep default threshold
SSDEEP_THRESHOLD=24



# Functions
# ------------------------------

#
# WARNING: 
# Makes use of grep in a lousy way. Ohh well
# ...colour is nice when you're looking at thousands of files flying through the screen, 
# but might not work with Macs or other shell/grep combos
# if that's the case then comment it out or delete, ssdeep doesn't allow for highlighting

function ssdeep-process () {
    local value_action="$action"
    local value_file="$file"
    if [ ! -d "$value_file" ]; then
        case "$value_action" in
            "--check")
                printf "> Scanning: $file\n" #| GREP_COLOR='1;32' grep -P "> Scanning: " --color=always -A10000 -B10000 
                ssdeep -m "$HASH_DATABASE" "$file" -t $SSDEEP_THRESHOLD -s | awk '{$1="  [ ! ]"; print $0}' #| GREP_COLOR='1;31' grep -P "^|matches" --color=always -A10000 -B10000 | GREP_COLOR='1;30' grep -P "$HASH_DATABASE:" --color=always -A10000 -B10000
            ;;
            "--generate")
                local hash=$(ssdeep "$file" -s | tail -n +2) 
                printf "> Generating signature: $file $hash\n" #| GREP_COLOR='1;32' grep -P "> Generating signature: " --color=always -A10000 -B10000 | GREP_COLOR='1;35' grep -P "$hash" --color=always -A10000 -B10000
                grep -qxF "$hash" "$HASH_DATABASE" || printf "$hash\n" >> "$HASH_DATABASE" 
            ;;
            *)
                printf "$0 - Error: ssdeep-process \"$value_action\" was not recognized...\n\n"
                exit 1
            ;;
        esac
    fi
}

function ssdeep-list() {
    [[ -f "$HASH_DATABASE" ]] && cat "$HASH_DATABASE"
}



# Main
# ------------------------------

function main () {
    [[ ! -f "$HASH_DATABASE" ]] && printf "\n" > "$HASH_DATABASE"
    grep -qxF "$SSDEEP_HEADER" "$HASH_DATABASE" || sed -i '1 s/^/'$SSDEEP_HEADER'/' "$HASH_DATABASE"
    case "$action" in
        "--check"|"--generate")
            if [[ ${files[@]} ]]; then
                for file in ${files[*]}; do
                    ssdeep-process "$action" "$file"
                done
            else
                printf "$0 - Error: missing files for processing...\n"
                exit 1
            fi
        ;;
        "--list")
            ssdeep-list
        ;;
        *)
            printf "$0 - Error: main \"$action\" was not recognized...\n\n"
            printf "* Operations:\n"
            printf "  --check FILE    : Checks file for known signatures\n"
            printf "  --generate FILE : Generates a hash signature for each file\n"
            printf "  --list          : Lists known signatures\n"
			exit 127
        ;;
    esac
}

action=$1
files=${*: 2}

main $action $files