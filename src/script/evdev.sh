#!/usr/bin/env sh

# Get the event from the input data
# It can find an event if we have its type, and if we don't
# $1: event type or event code (if we haven't event type)
# $2: event code
# return:
#    event type (integer)
#    event code (integer)
get_event() {
    # If we have only a key code
    #if [[ -z $2 ]]; then
        #echo $1 $2
    #fi

    echo $1 $2
}

# Get the comparison type and value
# $1: the sign (=, ==, !=, <, >, <=, >=)
# $2: comparison value
# return:
#    the comparison type: eq, ne, lt, gt, le, ge (according to the bash docs)
#    the comparison value
get_comparison() {
    # Check the comparison value for number
    if ! [[ "$2" =~ ^-?[1-9][0-9]*$ ]]; then
        echo "Invalid input"
        echo "\"$2\" is Not a Number"
        exit 141
    fi

    case "$1" in
        '='|'==') local comp_type='-eq';;
        '!=') local comp_type='-ne';;
        '<') local comp_type='-lt';;
        '>') local comp_type='-gt';;
        '<=') local comp_type='-le';;
        '>=') local comp_type='-ge';;
    esac

    # Check the comparison type
    if [[ -z $comp_type ]]; then
        echo "Invalid input"
        echo "\"$1\" is not an available operator"
        exit 142
    fi

    # Print the comparison
    echo "$comp_type $2"
}

# Assemble one of the condition necessary for the hotkey
# $1: argument from the shell
# return: condition arguments for the evdev program (C binary)
#    event type (integer)
#    event code (integer)
#    the comparison type: eq, ne, lt, gt, le, ge (according to the bash docs)
#    the comparison value
get_hotkey_condition() {
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
      <<< "$1"))
    readonly condition_arr

    # Get the necessary information from an unsorted array
    case ${#condition_arr[@]} in
        # Possible variant: EV_TYPE:EV_CODE(comparison)number
        4)
            local event=$(get_event ${condition_arr[0]} ${condition_arr[1]})
            comparison=$(get_comparison ${condition_arr[2]} ${condition_arr[3]})
            ;;

        # Possible variant: EV_CODE(comparison)number
        3)
            local event=$(get_event ${condition_arr[0]})
            comparison=$(get_comparison ${condition_arr[1]} ${condition_arr[2]})
            ;;

        # Possible variant: EV_TYPE:EV_CODE
        2)
            local event=$(get_event ${condition_arr[0]} ${condition_arr[1]})
            ;;

        # Possible variant: EV_CODE
        1)
            local event=$(get_event ${condition_arr[0]})
            ;;

        # If we have unexpected input
        *)
            echo "Ivalid input: \"$1\""
            exit 140
            ;;
    esac

    # Mark event and comparison varibales as readonly
    readonly event
    readonly comparison

    # Print the assembled arguments
    echo "$event $comparison"
}

# Get all arguments
for ((i = 1; i <= $#; i++)); do
    get_hotkey_condition "${!i}"
done

# Exit with the successs code
exit 0
