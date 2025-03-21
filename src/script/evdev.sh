#!/usr/bin/env sh

# Source the file with event type names
source "/home/flame/Programs/UniversalPause/src/event-codes/EVENT_TYPES.sh"

# Source the files where out code names can be
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_SYN.sh"
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_KEY.sh"
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_REL.sh"
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_ABS.sh"
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_MSC.sh"
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_SW.sh"
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_LED.sh"
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_SND.sh"
source "/home/flame/Programs/UniversalPause/src/event-codes/EV_REP.sh"

readonly INVALID_INPUT_ERROR='[!] Invalid input'

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
                # Print the error message
                echo "$INVALID_INPUT_ERROR:"\
                    "\"$code_name\" - no such an event code" >&2
                # Exit from the function
                return
                ;;
        esac

        # Check the code for existence
        if [[ -z ${!code_name} ]]; then
            # Print the error message
            echo "$INVALID_INPUT_ERROR:"\
                "\"$code_name\" - no such an event code" >&2
            # Exit from the function
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
            # Print the error message
            echo "$INVALID_INPUT_ERROR:"\
                "\"$code_name\" must be the string code name of the event" >&2
            # Exit from the function
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
            # Print the error message
            echo "$INVALID_INPUT_ERROR:"\
                "\"$type_name\" - no such an event type" >&2
            # Exit from the function
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
                    # Print the error message
                    echo "$INVALID_INPUT_ERROR:"\
                        "\"$event_code\" - no such an event code"\
                        "for the event type \"$type_name\"" >&2
                    # Exit from the function
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
            # Print the error message
            echo "$INVALID_INPUT_ERROR:"\
                "\"$event_code\" should be the numeric event code" >&2
            # Exit from the function
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
        # Print the error message
        echo "$INVALID_INPUT_ERROR:"\
            "\"$comp_value\" - Not a Number" >&2
        # Exit from the function
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
        # Print the error message
        echo "$INVALID_INPUT_ERROR:"\
            "\"$comp_sign\" is not an available operator" >&2
        # Exit from the function
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
get_hotkey_condition() {
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
            echo "$INVALID_INPUT_ERROR:"\
                "can't recognize the argument - \"$argument\"" >&2
            ;;
    esac
    readonly comparison

    # If it was not possible to get any of the arguments,
    # it means that at some stage we had an error
    if [[ -z "$event" ]] || [[ -z "$comparison" ]]; then
        # Print the error message
        echo "[!] The argument \"$argument\" was ignored due to an error"
        # Exit from the function
        return
    fi

    # If all is OK, print the assembled arguments
    echo "$event $comparison"
}

# Get all arguments
for ((i = 1; i <= $#; i++)); do
    get_hotkey_condition "${!i}"
done

# Exit with the successs code
exit 0
