#!/bin/bash

source /home/sample/scripts/dataset.sh

function cpupdate_log() {
	cat /var/cpanel/updatelogs/summary.log | grep "Completed update" | awk '{print $1,$2,$6,$8}' | sed 's/[][]//' | grep "$(date -d '12 hours ago' +%Y-%m-%d)" | awk -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($2 >= Time1 && $2 <= Time2) print $0}' | awk '{printf "%-19s %-17s %-20s %-20s\n","DATE: "$1,"TIME: " $2,"OLD: "$3,"NEW: "$NF}' >>$temp/cpupdatelog_$time.txt
}

function check_log() {
	if [ -r $temp/cpupdatelog_$time.txt ] && [ -s $temp/cpupdatelog_$time.txt ]; then
		cat $temp/cpupdatelog_$time.txt >>$svrlogs/errorlogwatch/cpupdatelog_$time.txt
	fi
}

cpupdate_log

check_log
