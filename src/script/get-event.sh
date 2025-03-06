#!/usr/bin/env sh

# Get the directory with the list of the event codes
readonly event_codes_dir=$SHAREDIR/bin

# Get the event type/code name by id
# $1: a file to read from
# $2: event type/code id
get_name_by_id() {
    # For printing the output in one line
    echo $(cat $1 | grep -w "$2" | cut -d '=' -f 1)
}

# Print the event to the terminal in a human-readable format
# $1: event type (integer)
# $2: event code (integer)
# $3: event value (integer)
print_event() {
    # Get the event type name
    readonly event_type=$(get_name_by_id $event_codes_dir/event-types.sh $1 )

    # Get the file where we can find the event code name
    readonly event_code_file="$event_codes_dir/$event_type.sh"

    # If we have such a file
    if [[ -e $event_code_file ]]; then
        # Get the event code name
        readonly event_code=$(get_name_by_id $event_code_file $2 )
    fi

    # Print the event. Format: Type 0 (<name>), Code 0 (<name>), Value 0
    echo -n "Type $1"
    if [[ ! -z "$event_type" ]]; then echo -n " ($event_type)"; fi
    echo -n ", Code $2"
    if [[ ! -z "$event_code" ]]; then echo -n " ($event_code)"; fi
    echo ", Value $3"

    # Exit with the success code
    exit 0
}

case $1 in
    --print)
        print_event $2 $3 $4
        exit 0
        ;;
esac
