#!/bin/sh
set -eu
: "${DEBUG:=}"
[ -n "$DEBUG" ] && set -x

: "${SJ_DIR:=}"

dvtm_new_window() {  # $1 is command
	printf 'create "%s"\n' "$1" > $DVTM_CMD_FIFO
}

state=""
for arg; do
	if [ -n "$state" ]; then
		case "$state" in
			-d) SJ_DIR="$arg";;
			-u) SJ_USER="$arg";;
			-r) SJ_RESOURCE="$arg";;
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

[ -n "$SJ_DIR" ] || { echo SJ_DIR is not defined; exit 1; }
cd "$SJ_DIR" || { echo cannot cd to "$SJ_DIR"; exit 1; }
jid="${SJ_USER}@${SJ_SERVER}"

bud="set-title buddies\ $jid; watch -d sjfs-online-buddies -d $SJ_DIR"
mon="set-title monitor-all\ $jid; sjfs-monitor-all-chats -d $SJ_DIR -u $SJ_USER -s $SJ_SERVER"
reg="set-title register\ $jid; echo type enter to register presence after connect; read; presence -d $SJ_DIR"
con="set-title connect\ $jid; sjfs-connect $@"

: "${DVTM_CMD_FIFO:=}"
if [ -z "$DVTM_CMD_FIFO" ] ; then
	DVTM_CMD_FIFO="$HOME"/dvtm-cmd-$$
	dvtm -c "$DVTM_CMD_FIFO" "$bud" "$mon" "$reg" "$con"
else  # we're already inside of a dvtm session with a command fifo
	dvtm_new_window "$bud"
	dvtm_new_window "$mon"
	dvtm_new_window "$reg"
	dvtm_new_window "$con"
fi

echo pause
read pause

# prepare for runit
printf '#!/bin/sh
printf "create \\"sjfs-chat -c -u %s -s %s\\" TITLE $PWD\\n" > $DVTM_CMD_FIFO
sleep 60
' "$SJ_USER" "$SJ_SERVER" > run
chmod u+x run
trap 'kill 0; exit' HUP INT QUIT TERM EXIT

outs1=`find . -name out | sort`
for o in $outs1; do
	dir=$(dirname "$o")
	touch "$dir"/down
	[ -e "$dir"/run ] || ln -s ../run "$dir"
	runsv "$dir" &
	tail -f -n0 "$o" | while IFS= read -r line; do
		sv once "$dir"
	done &
done

read pausey

while true; do
	#sleep 5
	# The only purpose of entr here is to wait for a change in the current
	# directory; the first true is because entr needs a utility; the second
	# true is to prevent an error in the script since entr will return 2
	echo . | entr -pd true || true
	outs2=`find . -name out | sort`
	if [ "$outs1" != "$outs2" ] ; then
		new_outs=`comm -13 <(echo "$outs1") <(echo "$outs2")`  # <() requires ksh93
		for o in $new_outs; do
			dir=$(dirname "$o")
			touch "$dir"/down
			[ -e "$dir"/run ] || ln -s ../run "$dir"
			runsv "$dir" &
			tail -f -n0 "$o" | while IFS= read -r line; do
				sv once "$dir"
			done &
		done
		outs1="$outs2"
	fi
done

exit 0
