#!/bin/sh
# Ctrl-D to end
[ "$DEBUG" ] && set -x

# Set configuration variable to "no" to disable feature
#
# style of incming message:  a style for tput e.g. bold, dim, blink, smul
# (underlined), rev (reverse), smso (standout)
: "${style:=no}"
# color of incoming message:  a color for tput setaf, e.g. 1-7
: "${color:=1}"
# number of milliseconds for the notify-send timeout
: "${notify_duration:=2000}"

trap "kill 0; exit" HUP INT QUIT EXIT

cat out || { echo out file required; exit 1; }
tail -f -n0 out | while IFS= read -r line
do
	[ "$color" != no ] && tput setaf "$color"
	[ "$style" != no ] && tput "$style"
	printf '%s\n' "$line"
	tput sgr0  # Turn off all attributes: back to normal
	if echo "$line" | egrep -q "^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} [[:digit:]]{2}:[[:digit:]]{2} <${SJ_USER}@${SJ_SERVER}"; then
		:  # this is a message that I sent myself, so don't notify
	else
		printf '\a'
		[ "$notify_duration" != no ] && notify-send -t "$notify_duration" "sjfs-chat: $(basename $(pwd))" "$(echo "$line" | cut -d\> -f2-)"
	fi
done &

##cat > in  # this works except that it inserts extra new lines
while read -r line
do
    printf '%s' "$line" >> in
done

# kill the background jobs
kill 0  # kill -- -$$  also works
