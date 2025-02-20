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
process_pid=$(xdotool getactivewindow getwindowpid)

# Get the process stats and its name
process_stats=$(ps --no-headers -o stat $process_pid)
process_name=$(ps --no-headers -o comm $process_pid)

# Has the process been stopped already?
if [[ $process_stats == *"T"* ]]; then
    # If the process has been stopped already, send the continue SIGNAL
    if $(kill -CONT $process_pid); then
        printf "$CONTINUE_SUCCESS\n" $process_name $process_pid
        play_audio pause-off.wav
        exit 0
    else
        printf "$CONTINUE_FAILURE\n" $process_name $process_pid
        exit 100
    fi
else
    # If the process is running, send the stop SIGNAL
    if $(kill -STOP $process_pid); then
        printf "$STOP_SUCCESS\n" $process_name $process_pid
        play_audio pause-on.wav
        exit 0
    else
        printf "$STOP_FAILURE\n" $process_name $process_pid
        exit 101
    fi
fi
