#!/bin/sh

tail -f -n +0 out | while IFS= read -r line
do
	printf '%s\a\n' "$line"
done &
tailpid=$!
# Ctrl-D to end
##cat > in  # this works except that it inserts extra new lines
while read -r line 
do
    printf '%s' "$line" > in
done
kill $tailpid
