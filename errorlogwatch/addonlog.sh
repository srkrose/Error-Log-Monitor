#!/bin/bash

source /home/sample/scripts/dataset.sh

function addon_log() {
	cat /usr/local/cpanel/logs/error_log | grep "Creating Addon domain" | awk '{print $1,$2,$9,$11}' | sed 's/[][]//;s/\.$//g' | tr -d "'" | awk -F'[ .]' '{print $1,$2,$3"."$4,$(NF-1)"."$NF}' | grep "$(date -d '12 hours ago' +%Y-%m-%d)" | awk -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($2 >= Time1 && $2 <= Time2) print $0}' | awk '{printf "%-19s %-17s %-50s %-50s\n","DATE: "$1,"TIME: " $2,"DOMAIN: "$3,"MAIN: "$NF}' >>$temp/addonlog_$time.txt
}

function check_log() {
	if [ -r $temp/addonlog_$time.txt ] && [ -s $temp/addonlog_$time.txt ]; then
		cat $temp/addonlog_$time.txt >>$svrlogs/errorlogwatch/addonlog_$time.txt
	fi
}

addon_log

check_log
