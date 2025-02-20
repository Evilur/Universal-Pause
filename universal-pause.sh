#!/usr/bin/env sh

# Root directory of the installed program
readonly ROOT_DIR=/usr/share/UniversalPause
export ROOT_DIR

# Add a script directory to the PATH variable
PATH=$ROOT_DIR/script:$PATH

# Get the locale filename
case $LANG in
    ru_*)
        readonly LOCALE=ru_RU
        ;;
    *)
        readonly LOCALE=en_US
        ;;
esac
export LOCALE

# Arguments for access from a function
readonly args=$@

# Check if the required argument exists in the arguments
# $1: argument to check
check_arg() {
    if [[ " $args " == *" $1 "* ]]; then echo 1; fi
}

# Check for -h, --help arguments. If there is such an argument, 
# print a help message and exit the program
if [[ $(check_arg -h) || $(check_arg --help) ]]; then
    help.sh
    exit 0
fi

# Check for -r, --run arguments. If there is such an argument, 
# execute the script and exit the program
if [[ $(check_arg -r) || $(check_arg --run) ]]; then
    pause-focused.sh
    exit 0
fi

# If there were no valid arguments, then display a help message and 
# exit with error code
help.sh
exit 100