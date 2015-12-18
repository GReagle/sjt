#!/bin/mksh

for i in `seq $1` ; do
	sjfs-monitor-all-chats > /dev/null 2>&1 &
	pids[$i]=$!
done

sleep 10

for i in `seq $1` ; do
	kill ${pids[$i]}
done
