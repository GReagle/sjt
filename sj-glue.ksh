#!/bin/ksh93
# mksh does not have <() feature

: "${te:=st}"  # terminal emulator e.g. xterm, st, rxvt

[ "$SJ_DIR" = "" ] && { echo SJ_DIR is not defined; exit 1; }
cd "$SJ_DIR" || { echo cannot cd to "$SJ_DIR"; exit 1; }

#$te -T sjfs-start -e sjfs-start &
#echo After you connect, hit enter
#read line
#presence
#$te -T sjfs-online-buddies -e watch sjfs-online-buddies &

outfiles1=`find . -name out | sort`
while true; do
	outfiles2=`find . -name out | sort`
	if [ "$outfiles1" != "$outfiles2" ] ; then
		new_outfiles=`comm -13 <(echo "$outfiles1") <(echo "$outfiles2")`
		if test "$new_outfiles" != ""; then
			for d in $new_outfiles; do
				if cd `dirname $d`; then
					printf '%s\a\n' "new chat from $(basename $(dirname $d))"
					$te -T $(basename $(dirname $d)) -e sjfs-chat.sh &
					cd ..
				fi
			done
		fi
		outfiles1="$outfiles2"
	fi
	echo snoozing
	sleep 5
done

#while dialog --dselect "" 0 0 2> msj-result
#do
#	result="`cat msj-result`"
#	cd "$result"
#	$te -T "chat: $result" -e sjfs-chat.sh &
#	cd "$SJ_DIR"
#done
