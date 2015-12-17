#!/bin/sh

# Ctrl-D to end

tail -f -n +0 out | while IFS= read -r line
do
	printf '%s\a\n' "$line"
done &

##cat > in  # this works except that it inserts extra new lines
while read -r line 
do
    printf '%s' "$line" >> in
done

# kill the background jobs
kill 0  # kill -- -$$  also works

