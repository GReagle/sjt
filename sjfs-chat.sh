#!/bin/sh
# Ctrl-D to end
[ "$DEBUG" ] && set -x

# For all the following configuration variables, if the variable is unset
# or the empy string, then the feature is disabled.
#
# style of incming message:  a style for tput e.g. bold, dim, blink, smul
# (underlined), rev (reverse), smso (standout) : "${style:=''}"
#: "${style:=smul}"
# color of incoming message:  a color for tput setaf, e.g. 1-7
: "${color:=1}"
# number of milliseconds for the notify-send timeout
: "${notify:=3000}"

trap "kill 0; exit" HUP INT QUIT EXIT

cat out || { echo out file required; exit 1; }
tail -f -n0 out | while IFS= read -r line
do
	[ "$color" ] && tput setaf "$color"
	[ "$style" ] && tput "$style"
	printf '%s\n' "$line"
	tput sgr0  # Turn off all attributes: back to normal
	if echo "$line" | egrep -q "^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} [[:digit:]]{2}:[[:digit:]]{2} <${SJ_USER}@${SJ_SERVER}"; then
		:  # this is a message that I sent myself, so don't notify
	else
		printf '\a'
		[ "$notify" ] && notify-send -t "$notify" "sjfs-chat: $(basename $(pwd))" "$(echo "$line" | cut -d\> -f2-)"
	fi
done &

##cat > in  # this works except that it inserts extra new lines
while read -r line
do
    printf '%s' "$line" >> in
done

# kill the background jobs
kill 0  # kill -- -$$  also works
