#!/usr/bin/sh

# Play sound from the assets directory
# -q: quiet mod
# -v: volume <FACTOR>
# $1: the file name in the assets directory
play_audio() {
    play -qv 0.1 /usr/share/UniversalPause/$1
}

# Get the currently active window and get the process ID
process_pid=`xdotool getactivewindow getwindowpid`

# Get the process stats and its name
process_stats=`ps --no-headers -o stat $process_pid`
process_name=`ps --no-headers -o comm $process_pid`

# Has the process been stopped already?
if [[ $process_stats == *"T"* ]]; then
    # If the process has been stopped already, send the continue SIGNAL
    if `kill -CONT $process_pid`; then
        echo Process \"$process_name\" \($process_pid\) has been continued
        play_audio continue.wav
    else
        echo Can\'t continue the process \"$process_name\" \($process_pid\)
        exit 100
    fi
else
    # If the process is running, send the stop SIGNAL
    if `kill -STOP $process_pid`; then
        echo Process \"$process_name\" \($process_pid\) has been stopped
        play_audio stop.wav
    else
        echo Can\'t stop the process \"$process_name\" \($process_pid\)
        exit 101
    fi
fi