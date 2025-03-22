#!/usr/bin/env sh

# Include locale file
source $SHAREDIR/locale/evdev/$LOCALE

# Source the files where our event code names and event type names can be
for source_file in \
EVENT_TYPES EV_SYN EV_KEY EV_REL EV_ABS EV_MSC EV_SW EV_LED EV_SND EV_REP; do
    source "$SHAREDIR/bin/$source_file.sh"
done

# Get the event from the input data
# It can find an event if we have its type, and if we don't
# $1: event type or event code (if we haven't event type)
# $2: event code
# return:
#    event type (integer)
#    event code (integer)
get_event() {
    # Find the event arguments by the code name
    # $1: string event code name
    # return:
    #    event type (integer)
    #    event code (integer)
    get_arguments_by_code_name() {
        # Set the event code name
        local code_name=$1
        readonly code_name

        # Get the event type
        case "$code_name" in
            SYN_*      ) local -r event_type=$EV_SYN;;
            KEY_*|BTN_*) local -r event_type=$EV_KEY;;
            REL_*      ) local -r event_type=$EV_REL;;
            ABS_*      ) local -r event_type=$EV_ABS;;
            MSC_*      ) local -r event_type=$EV_MSC;;
            SW_*       ) local -r event_type=$EV_SW;;
            LED_*      ) local -r event_type=$EV_LED;;
            SND_*      ) local -r event_type=$EV_SND;;
            REP_*      ) local -r event_type=$EV_REP;;
            *)
                # Print the error message and exit
                printf "$ERROR_NO_SUCH_EVENT_CODE\n" "$code_name" >&2
                return
                ;;
        esac

        # Check the code for existence
        if [[ -z ${!code_name} ]]; then
            # Print the error message and exit
            printf "$ERROR_NO_SUCH_EVENT_CODE\n" "$code_name" >&2
            return
        fi

        # Print the result
        echo "$event_type ${!code_name}"
    }

    # Set the regex to check for the event code: starts with a Latin letters,
    # consists of uppercase Latin letters, numbers, and underscores
    local evdev_code_regex='^[A-Z][A-Z0-9_]+$'
    readonly evdev_code_regex

    # If we have only a key code
    if [[ "$#" == 1 ]]; then
        # Set the event code name
        local code_name=$1
        readonly code_name

        # Check for the ivalid input
        if [[ ! "$code_name" =~ $evdev_code_regex ]]; then
            # Print the error message and exit
            printf "$ERROR_NO_SUCH_EVENT_CODE\n" "$code_name" >&2
            return
        fi

        # If the input is correct
        get_arguments_by_code_name $code_name
    # If we have both event type and code
    else
        # Set the type name
        local type_name=$1
        readonly type_name

        # Get the event type (integer)
        local event_type=${!type_name}
        readonly event_type

        # If there is no such an event type
        if [[ -z "$event_type" ]]; then
            # Print the error message and exit
            printf "$ERROR_NO_SUCH_EVENT_TYPE\n" "$type_name" >&2
            return
        fi

        # Set the event code. It can be a code name or a code (integer)
        local event_code=$2
        readonly event_code

        # If the $event_code is a string event name
        if [[ "$event_code" =~ $evdev_code_regex ]]; then
            # Get the event arguments
            local event_arguments=$(get_arguments_by_code_name \
                $event_code 2>/dev/null)
            readonly event_arguments

            # If no such code exists for this type of event
            if [[ "$(cut -d ' ' -f 1 <<< $event_arguments)" != "$event_type" ]]\
               || [[ -z "$event_arguments" ]]; then
                    # Print the error message and exit
                    printf "$ERROR_NO_SUCH_EVENT_CODE_FOR_TYPE\n" \
                        "$event_code" "$type_name" >&2
                    return
            fi

            # If all is OK
            echo "$event_arguments"
        # If the $event_code is an integer
        elif [[ "$event_code" =~ ^[0-9]+$ ]]; then
            # Print the event type and code
            echo "$event_type $event_code"
        # If there is an invalid input for the $event_code
        else
            # Print the error message and exit
            printf "$ERROR_SHOULD_BE_NUMERIC\n" "$event_code" >&2
            return
        fi
    fi
}

# Get the comparison type and value
# $1: the sign (=, ==, !=, <, >, <=, >=)
# $2: comparison value
# return:
#    the comparison type: eq, ne, lt, gt, le, ge (according to the bash docs)
#    the comparison value
get_comparison() {
    # Get arguments
    local comp_sign=$1
    readonly comp_sign
    local comp_value=$2
    readonly comp_value

    # Check the comparison value for NaN
    if ! [[ "$comp_value" =~ ^-?[0-9]*$ ]]; then
        # Print the error message and exit
        printf "$ERROR_NAN\n" "$comp_value" >&2
        return
    fi

    # Get the current comparison type
    case "$comp_sign" in
        '='|'==') local -r comp_type='-eq';;
        '!='    ) local -r comp_type='-ne';;
        '<'     ) local -r comp_type='-lt';;
        '>'     ) local -r comp_type='-gt';;
        '<='    ) local -r comp_type='-le';;
        '>='    ) local -r comp_type='-ge';;
    esac

    # Check the comparison type for emptiness
    if [[ -z "$comp_type" ]]; then
        # Print the error message and exit
        printf "$ERROR_INVALID_OPERATOR\n" "$comp_sign" >&2
        return
    fi

    # Print the comparison
    echo "$comp_type $comp_value"
}

# Assemble one of the condition necessary for the hotkey
# $1: argument from the shell
# return: condition arguments for the evdev program (C binary)
#    event type (integer)
#    event code (integer)
#    the comparison type: eq, ne, lt, gt, le, ge (according to the bash docs)
#    the comparison value
get_hotkey_arguments() {
    # Set the argument from the shell
    local argument=$1
    readonly argument

    # Set the default comparison (greater or equal 1)
    local comparison='-ge 1'

    # Read the argument as a complex condition
    # Possible variants: EV_TYPE:EV_CODE(comparison)number
    #                    EV_TYPE:EV_CODE
    #                    EV_CODE(comparison)number
    #                    EV_CODE
    # EV_CODE can be a number or a string
    # Possible comparisons: =, !=, <, >, <=, >=
    local condition_arr=($(\
        awk -F '[:\\\\/|]' '{sub("(=|==|!=|<|>|<=|>=)", " & "); print $1, $2}' \
        <<< "$argument"))
    readonly condition_arr

    # Get the necessary information from an unsorted array
    case ${#condition_arr[@]} in
        # Possible variant: EV_TYPE:EV_CODE(comparison)number
        4)
            local -r event=$(get_event \
                "${condition_arr[0]}" "${condition_arr[1]}")
            comparison=$(get_comparison \
                "${condition_arr[2]}" "${condition_arr[3]}")
            ;;

        # Possible variant: EV_CODE(comparison)number
        3)
            local -r event=$(get_event "${condition_arr[0]}")
            comparison=$(get_comparison \
                "${condition_arr[1]}" "${condition_arr[2]}")
            ;;

        # Possible variant: EV_TYPE:EV_CODE
        2)
            local -r event=$(get_event \
                "${condition_arr[0]}" "${condition_arr[1]}")
            ;;

        # Possible variant: EV_CODE
        1)
            local -r event=$(get_event "${condition_arr[0]}")
            ;;

        # If we have an unexpected input
        *)
            # Print the error message
            printf "$ERROR_CANT_RECOGNIZE_ARGUMENT\n" "$argument" >&2
            ;;
    esac
    readonly comparison

    # If it was not possible to get any of the arguments,
    # it means that at some stage we had an error
    if [[ -z "$event" ]] || [[ -z "$comparison" ]]; then
        # Print the error message and exit
        printf "$ERROR_IGNORE_ARGUMENT\n\n" "$argument" >&2
        return
    fi

    # If all is OK, print the assembled arguments
    echo "$event $comparison"
}

# Check the number of arguments (it must be at least 2)
if [[ "$#" -lt 2 ]]; then
    # Print the error message and exit
    echo "$ERROR_AT_LEAST_TWO_ARGS" >&2
    exit 140
fi

# Get all arguments
for ((i = 1; i <= $#; i++)); do
    # Get the current argument
    argument=${!i}

    # If there is the existing path
    if [[ -e "$argument" ]]; then
        # Set the device path for future manupulations
        device_path=$argument
        # Goto the next iteration
        continue
    fi

    # Get arguments for the evdev (C binary)
    hotkey_arguments+=($(get_hotkey_arguments "$argument"))
done

# Check the number of assembled arguments
if [[ "${#hotkey_arguments[@]}" -eq 0 ]]; then
    echo "$ERROR_IMPOSSIBLE_TO_GET_HOTKEY" >&2
    exit 141
fi

# If the $device_path is empty
if [[ -z "$device_path" ]]; then
    echo "$ERROR_NO_DEVICE_PATH" >&2
    exit 142
fi

# If all is OK, run the evdev (C binary) with the assembled argument list
# evdev arguments order:
# <event device path> <command to run> <hotkey argument array>
evdev "$device_path" 'pause-focused.sh' ${hotkey_arguments[@]}

# Exit with the code of the last command
exit $?
