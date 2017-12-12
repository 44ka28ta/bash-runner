#/bin/sh

WATCH_EVENT="modify"

usage_exit() {
    echo "Usage: $0 [-h] monitoring-item -- command" 1>&2
    echo
    echo "Options:" 1>&2
    echo "      h: this usage shows." 1>&2
    exit 1
}



while getopts "h" OPT
do
	case $OPT in
		h)	usage_exit
			;;
		\?) usage_exit
			;;
	esac
done

file_name_with_ext=$(basename $1)
directory_path=$(dirname $1)

shift $OPTIND


while getopts "" OPT
do
	case $OPT in
		\?) usage_exit
			;;
	esac
done

shift



immediate_command="$@"

inotifywait -m --event $WATCH_EVENT $directory_path'/.' | while read -r result; do echo $result | if [ -n "$(grep -G $file_name_with_ext'$')" ]; then execution_result=`${immediate_command} 2>&1 > /dev/null`; fst_filter_result=$(echo "$execution_result" | grep '.*'); [ ! -n "$fst_filter_result" ] && (display_notification="Success."; notify-send "Compilation Success" "$display_notification" --icon=dialog-information) || (notify-send "Compilation Failure" "Please see the error display on the terminal." --icon=dialog-error; echo "$execution_result" 1>&2 ); fi done

