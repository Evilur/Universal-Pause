#!/usr/bin/env sh

# Kill all background processes
kill_background() {
    # Print that we are interrupting the process
    echo "Interrupting..."

    echo $(jobs | wc -l)

    # Kill all background processes
    kill $(jobs -p) 2>/dev/null

    # Exit with the success code
    exit 0
}

# Handle the event from the device
# $1: event device path
handle_device() {
    # If we handle at least one byte
    IFS= read -r -N 1

    # Get the device name
    local device_name=/sys/class/input/$(basename $1)/device/name

    # Print that we found one device
    echo -e "Found the device: $1 ($(cat $device_name))"
}

# Define a counter for all event devices
event_devices=0

# Define an array for available devices
available_devices=()

# Get all event devices from the /dev/input/ directory
for event in /dev/input/event*; do
    # Increase the number of event devices
    let event_devices+=1

    # If we can read the event
    if [[ -r $event ]]; then
        # Push the event device to the array
        available_devices+=($event)
    fi
done

# If we have NOT any available devices
if [[ ${#available_devices[@]} == 0 ]]; then
    # Print the message
    echo "No available devices were found"

    # If the user is not a superuser
    if [[ $UID != 0 ]]; then
        # Hint that you can run the program as superuser
        echo "Try running the command as superuser"
    fi

    # Exit the program with error code
    exit 131
fi

# If not all devices are available
if [[ ${#available_devices[@]} != $event_devices ]]; then
    # Print how many devices are currently available
    echo "Devices are available: ${#available_devices[@]}/$event_devices"

    # If the user is not a superuser
    if [[ $UID != 0 ]]; then
        # Hint that you can run the program as superuser
        echo "Try running the command as superuser to get more"
    fi
fi

# Wait 1 second to avoid catching the release of the enter key
echo "Wait 1 second..."
sleep 1

# Rewrite the previous output and print that we are listening to devices
echo -e "Listening to devices... (Ctrl+C for interrupt)\n"

# Trap the SIGINT and SIGTERM
trap kill_background SIGINT SIGTERM

# Start listening all the available devices
for device in ${available_devices[@]}; do
    cat $device | handle_device $device &
done

# Wait for all background processes
wait
