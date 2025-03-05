#!/usr/bin/env sh

# Print the help message
cat $ROOT_DIR/locale/help/$LOCALE

# Print examples
echo '    universal-pause --help
    universal-pause --run
    universal-pause --run --volume 0.5 --silent
    universal-pause --evfind
    universal-pause --evtest
    universal-pause --evtest /dev/input/event5'

exit 0
