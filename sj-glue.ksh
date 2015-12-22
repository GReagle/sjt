#!/bin/sh
# mksh does not have <() feature

: "${te:=st}"  # terminal emulator, e.g. xterm, st, rxvt

state=""
for arg; do
	if [ "$state" ]; then
		case "$state" in
			-d) SJ_DIR="$arg";;
			-u) SJ_USER="$rg";;
			-r) SJ_RESOURCE="$rg";;
			-s) SJ_SERVER="$arg";;
			*)  echo invalid state;;
		esac
		state=""
	else
		case "$arg" in
			-d | -u | -r | -s) state="$arg";;
			-D) ;;
			*)  printf "$(basename $0): invalid option $arg\n"; exit 1;;
		esac
	fi
done

[ "$SJ_DIR" = "" ] && { echo SJ_DIR is not defined; exit 1; }
cd "$SJ_DIR" || { echo cannot cd to "$SJ_DIR"; exit 1; }

$te -T sjfs-start -e sjfs-start "$@" &
echo After you connect, hit enter
read line
presence -d "$SJ_DIR"
$te -T sjfs-online-buddies -e watch sjfs-online-buddies -d "$SJ_DIR" &
$te -T sjfs-monitor-all-chats -e sjfs-monitor-all-chats -d "$SJ_DIR" &

exit 0

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

while [ "$1" ]; do
	case "$1" in
		-d) SJ_DIR="$2"; shift;;
		-u) SJ_USER="$2"; shift;;
		-r) SJ_RESOURCE="$2"; shift;;
		-s) SJ_SERVER="$2"; shift;;
		*)  printf "$(basename $0): invalid option $1\n$usage\n"; exit 1;;
	esac
	shift
done
