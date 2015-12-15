#!/bin/sh

tail -n +0 -f out &
tailpid=$!
# Ctrl-D to end
#cat > in  # this works fine except that it inserts extra new lines
while read -r line 
do
    printf '%s' "$line" > in
done
kill $tailpid
