#!/bin/sh

# Ctrl-D to end

# style of incming message: either "no" to disable or a style for tput
# e.g. bold, dim, blink, smul (underlined), rev (reverse), smso (standout)
# only works if color is off
: "${style:=no}"
# color of incoming message: either "no" to disable or a color fot tput setaf
# e.g. 1-7
# color output disables any style
: "${color:=1}"
# either no to disable or a number of milliseconds for the notification timeout
: "${notify:=2000}"

cat out
tail -f -n0 out | while IFS= read -r line
do
	[ "$color" = no ] || tput setaf "$color"
	[ "$style" = no ] || tput "$style"	
	printf '%s' "$line"
	tput sgr0  # Turn off all attributes: back to normal
	printf '\a\n'
	[ "$notify" = no ] || notify-send -t "$notify" "$(basename $(pwd))" "$line"
done &

##cat > in  # this works except that it inserts extra new lines
while read -r line 
do
    printf '%s' "$line" >> in
done

# kill the background jobs
kill 0  # kill -- -$$  also works
