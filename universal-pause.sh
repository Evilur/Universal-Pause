#!/usr/bin/env sh

# Root directory of the installed program
readonly ROOT_DIR=/usr/share/UniversalPause
export ROOT_DIR

# Add a script directory to the PATH variable
PATH=$ROOT_DIR/bin:$PATH

# Get the locale filename
case $LANG in
    ru_*) readonly LOCALE=ru_RU;;
    *) readonly LOCALE=en_US;;
esac
export LOCALE

# Get arguments
for ((i = 1; i <= $#; i++)); do
    case ${!i} in
        # Set varibales to true to do something later
        -r|--run) readonly ARG_RUN=true;;
        -s|--silent) readonly ARG_SILENT=true;;
        -t|--evtest) readonly ARG_EVTEST=true;;

        # Print a help message and exit
        -h|--help)
            help.sh
            exit 0
            ;;

        # Print the version and exit
        --version)
            version.sh
            exit 0
            ;;

        # Set the volume percentage
        -v|--volume)
            # Get the next argument
            let i+=1

            # Set the volume variable
            readonly VOLUME=${!i}
            export VOLUME
            ;;
    esac
done

# Check the VOLUME variable. If it wasn't initialized,
# Set the fault volume level: 0.1
if [ -z $VOLUME ]; then
    readonly VOLUME=0.1
    export VOLUME
fi

# Check for -s, --silent arguments. If there is such an argument,
# redirect all the output to the /dev/null
if [[ $ARG_SILENT == true ]]; then
    exec > /dev/null 2>&1
fi

# Check for -t, --evtest arguments. If there is such an argument,
# start testing event input devices
if [[ $ARG_EVTEST == true ]]; then
    evdev-test.sh
    exit $?
fi

# Check for -r, --run arguments. If there is such an argument,
# execute the script and exit
if [[ $ARG_RUN == true ]]; then
    pause-focused.sh
    exit $?
fi

# If there were no valid arguments, then display a help message and
# exit with error code
help.sh
exit 100
