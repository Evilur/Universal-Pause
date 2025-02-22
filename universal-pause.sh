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
        -h|--help) ARG_HELP=true;;
        -v|--version) ARG_VERSION=true;;
        -r|--run) ARG_RUN=true;;
    esac
done

# Check for -h, --help arguments. If there is such an argument,
# print a help message and exit
if [[ $ARG_HELP == true ]]; then
    help.sh
    exit 0
fi

# Check for -v, --version arguments. If there is such an argument,
# print the version and exit
if [[ $ARG_VERSION == true ]]; then
    version.sh
    exit 0
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
