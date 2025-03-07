#!/usr/bin/env sh

# Print the help message
cat $SHAREDIR/locale/help/$LOCALE

# Print examples
cat << EOF
    universal-pause --help
    universal-pause --run
    universal-pause --run --volume 0.5 --silent
    universal-pause --evfind
    universal-pause --evtest
    universal-pause --evtest /dev/input/event5
EOF

exit 0
