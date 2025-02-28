#!/usr/bin/env sh

# Include locale files
source locale/evdev-test/$LOCALE

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
        device_path=$(tail -n 1 $input/event*/uevent)
        device_path=/dev/${device_path:8}

        # Can we read the device?
        if [[ -r $device_path ]]; then
            let available_devices+=1
            echo -e "$device_path\t$device_name"
        fi
    done
fi

# If we have available devices
if [[ $available_devices > 0 ]]; then
    # Now user is selecting the device
    echo -n "$SELECT_DEVICE [0-$(($available_devices - 1))]: "
    read device_event_number

    # Print the empty line
    echo

    # If user has entered the correct number
    if [[ $device_event_number =~ ^[0-9]+$ ]] &&  # Check for a non-negative num
       [[ $device_event_number -lt $available_devices ]]; then
        # Run the event device test for printing the event data
        evdev-test /dev/input/event$device_event_number

        # Exit with the success code
        exit 0
    else # If user has entered the incorrect number
        echo $INCORRECT_INPUT
        exit 121
    fi
else
    # If there are no available devices
    echo -e $NO_DEVICES
    exit 120
fi
