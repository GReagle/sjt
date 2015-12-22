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
: "${note_time:=no}"

while [ "$1" ]; do
	case "$1" in
		-d) [ "$2" ] && SJ_DIR="$2"; shift;;
		-b) [ "$2" ] && buddy="$2"; shift;;
		*)  printf "$(basename $0): invalid option $1\n"; exit 1;;
	esac
	shift
done

[ "$SJ_DIR" ] || { echo SJ_DIR is not defined; exit 1; }
[ "$buddy" ] || { echo buddy is not defined; exit 1; }
cd "$SJ_DIR"/"$buddy" || { echo cannot cd to "$SJ_DIR"/"$buddy"; exit 1; }

cat out || { echo out file required; exit 1; }
#trap "kill 0; exit" HUP INT QUIT EXIT
tail -f -n0 out | while IFS= read -r line; do
	[ "$color" != no ] && tput setaf "$color"
	[ "$style" != no ] && tput "$style"
	printf '%s\n' "$line"
	tput sgr0  # Turn off all attributes: back to normal
	if echo "$line" | egrep -q "^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2} [[:digit:]]{2}:[[:digit:]]{2} <${SJ_USER}@${SJ_SERVER}"; then
		:  # this is a message that I sent myself, so don't notify
	else
		printf '\a'
		[ "$note_time" != no ] && notify-send -t "$note_time" "sjfs-chat: $(basename $(pwd))" "$(echo "$line" | cut -d\> -f2-)"
	fi
done &

## cat > in  # this works except that it inserts extra new lines
while read -r line
do
	printf '%s' "$line" >> in
done

# kill the background jobs
for child in $(ps -o pid,ppid ax | awk "{ if ( \$2 == $$ ) { print \$1 }}"); do
	ps $child >/dev/null && kill $child || true
done
## kill 0  # kill -- -$$  also works
