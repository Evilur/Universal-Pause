#!/usr/bin/env sh

# Read the event device using the event-test C binary
# $1: the event device path
read_device() {
    # If we can read this device
    if [[ -r $1 ]]; then
        # Print that we start listening
        echo "Start listening to device input data..."

        # Run the event device test for printing the event data
        evdev-test "$1" | while IFS= read -r output; do
            export $output
            get-event.sh --print $event_type $event_code $event_value
        done

        # Exit with the success code
        exit 0
    else  # If we cant read the device
        echo $CANT_READ: $1
        exit 122
    fi
}

# Include locale files
source $ROOT_DIR/locale/evdev-test/$LOCALE

# If we have an argument
if [[ $# > 0 ]]; then
    # Read the event device
    read_device $1
fi

# Define a counter for all event devices
event_devices=0

# Define a counter for available devices
available_devices=0

# If the directory with input devices exists
if [[ -d /sys/class/input ]]; then
    # Get all event devices by id
    for input in /sys/class/input/input*; do
        # Check if we can read the file
        if ! [[ -r $input ]]; then continue; fi

        # Get the device name
        device_name=$(cat $input/name)

        # Get the device path
        device_path=/dev/input/$(basename $input/event*)

        # Increase the number of event devices
        let event_devices+=1

        # Can we read the device?
        if [[ -r $device_path ]]; then
            # Increase the number of available devices
            let available_devices+=1

            # Print the data
            echo -e "$device_path\t$device_name"
        fi
    done
fi

# If we have available devices
if [[ $available_devices > 0 ]]; then
    # Now user is selecting the device
    echo -n "$SELECT_DEVICE [0-$(($event_devices - 1))]: "
    read device_event_number

    # Print the empty line
    echo

    # If user has entered the correct number
    if [[ $device_event_number =~ ^[0-9]+$ ]] &&  # Check for a non-negative num
       [[ $device_event_number -lt $event_devices ]]; then
           # Read the event device
           read_device /dev/input/event$device_event_number
    else # If the user has entered the incorrect number
        echo $INCORRECT_INPUT
        exit 121
    fi
else
    # If there are no available devices
    echo -e $NO_DEVICES

    # If the user is not a superuser
    if [[ $UID != 0 ]]; then
        # Hint that you can run the program as superuser
        echo $TRY_AS_ROOT
    fi

    # Exit with the error code
    exit 120
fi
