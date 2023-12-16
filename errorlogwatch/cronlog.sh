#!/bin/bash

source /home/sample/scripts/dataset.sh

function cron_log() {
	cat /var/log/cron | awk -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%-d) -v Date2=$(date -d '1 hours ago' +%-d) -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($1 >= Month1 && $1 <= Month2) {if ($2 >= Date1 && $2 <= Date2) {if ($3 >= Time1 && $3 <= Time2) print $0}}}' | grep -iv "(root)" | awk '{printf "%-15s %-30s\n","DATE: "$1" "$2,"USER: "$6}' | sed 's/(//g;s/)//g' | sort | uniq -c | sort -nr | head >>$temp/cronlog_$time.txt
}

function check_log() {
	if [ -r $temp/cronlog_$time.txt ] && [ -s $temp/cronlog_$time.txt ]; then
		cp $temp/cronlog_$time.txt $svrlogs/errorlogwatch/cronlog_$time.txt
	fi
}

cron_log

check_log
