#!/bin/ksh93
set -eux
: "${DEBUG:=}"
[ -n "$DEBUG" ] && set -x

: "${te:=xterm}"  # terminal emulator, e.g. xterm, st, rxvt

: "${SJ_DIR:=}"

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
$te -T "${jid} - connect" -e sjfs-connect "$@" &
echo After you enter your password in the connect window, hit enter here...
read line
echo Announcing presence
presence -d "$SJ_DIR"
$te -T "${jid} - buddies" -e watch -d sjfs-online-buddies -d "$SJ_DIR" &
$te -T "${jid} - monitor-all" -e sjfs-monitor-all-chats -d "$SJ_DIR" -u "$SJ_USER" -s "$SJ_SERVER" &

# prepare for runit
echo "#!/bin/sh
$te -T \$(basename \$PWD) -e sjfs-chat -c -u $SJ_USER -s $SJ_SERVER" > run
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
