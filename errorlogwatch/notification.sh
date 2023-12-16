#!/bin/bash

source /home/sample/scripts/dataset.sh

function notification_log() {
	cat /usr/local/cpanel/logs/error_log | awk -v Date1=$(date -d '12 hours ago' +"[%Y-%m-%d") -v Date2=$(date -d '1 hours ago' +"[%Y-%m-%d") -v Time1=$(date -d '12 hours ago' +"%H:00:00") -v Time2=$(date -d '1 hours ago' +"%H:59:59") '{if ($1 >= Date1 && $1 <= Date2) {if ($2 >= Time1 && $2 <= Time2) print $0}}' | grep "Notification" | grep "via EMAIL" | grep "@" | grep "eventimportance =>" | awk '{print $1,$6,$9,$14}' | sed 's/[][]//g' | awk '{printf "%-19s %-25s %-50s %-70s\n","DATE: "$1,"IMPORTANCE: "$NF,"EMAIL: "$3,"NOTIFICATION: "$2}' | sort | uniq -c | sort -nr >>$temp/notification_$time.txt
}

function check_log() {
	if [ -r $temp/notification_$time.txt ] && [ -s $temp/notification_$time.txt ]; then
		cp $temp/notification_$time.txt $svrlogs/errorlogwatch/notification_$time.txt
	fi
}

notification_log

check_log
