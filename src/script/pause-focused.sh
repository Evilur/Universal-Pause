#!/usr/bin/env sh

source $ROOT_DIR/locale/pause-focused/$LOCALE

# Play sound from the assets directory
# $1: the file name in the assets directory
play_audio() {
    # -q: quiet mod
    # -v: volume <FACTOR>
    play -qv 0.1 $ROOT_DIR/sound/$1
}

# Get the currently active window and get the process ID
process_id=$(xdotool getactivewindow getwindowpid)

# Check if the variable is empty
if [ -z $process_id ]; then
    echo $EMPTY_VARIABLE
    play_audio error.wav
    exit 100
fi

# Get the process stats and its name
process_stats=$(ps --no-headers -o stat $process_id)
process_name=$(ps --no-headers -o comm $process_id)

# Has the process been stopped already?
if [[ $process_stats == *"T"* ]]; then
    # If the process has been stopped already, send the continue SIGNAL
    if $(kill -CONT $process_id); then
        printf "$CONTINUE_SUCCESS\n" $process_name $process_id
        play_audio pause-off.wav
    else
        printf "$CONTINUE_FAILURE\n" $process_name $process_id
        play_audio error.wav
        exit 101
    fi
else
    # If the process is running, send the stop SIGNAL
    if $(kill -STOP $process_id); then
        printf "$STOP_SUCCESS\n" $process_name $process_id
        play_audio pause-on.wav
    else
        printf "$STOP_FAILURE\n" $process_name $process_id
        play_audio error.wav
        exit 102
    fi
fi

# Exit with the success code
exit 0
