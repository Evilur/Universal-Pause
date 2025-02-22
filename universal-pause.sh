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
        -r|--run) ARG_RUN=true;;
        -s|--silent) ARG_SILENT=true;;

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
    esac
done

# Check for -s, --silent arguments. If there is such an argument,
# redirect all the output to the /dev/null
if [[ $ARG_SILENT == true ]]; then
    exec > /dev/null 2>&1
fi

# Check for -r, --run arguments. If there is such an argument,
# execute the script and exit
if [[ $ARG_RUN == true ]]; then
    pause-focused.sh
    exit 0
fi

# If there were no valid arguments, then display a help message and
# exit with error code
help.sh
exit 100
