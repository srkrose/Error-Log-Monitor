#!/bin/bash

source /home/sample/scripts/dataset.sh

function yum_log() {
	cat /var/log/yum.log | awk -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%d) -v Date2=$(date -d '1 hours ago' +%d) -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($1 >= Month1 && $1 <= Month2) {if ($2 >= Date1 && $2 <= Date2) {if ($3 >= Time1 && $3 <= Time2) print $0}}}' >>$temp/yumlog_$time.txt
}

function categorize_log() {
	if [ -r $temp/yumlog_$time.txt ] && [ -s $temp/yumlog_$time.txt ]; then
		category=($(cat $temp/yumlog_$time.txt | awk '{print $4}' | sort | uniq))
		count=${#category[@]}

		for ((i = 0; i < count; i++)); do
			data=$(cat $temp/yumlog_$time.txt | grep ${category[i]} | awk '{printf "%-15s %-100s\n","DATE: "$1" "$2,"MODULE: "$NF}')
			lines=$(echo "$data" | wc -l)

			echo "${category[i]} $lines modules" >>$svrlogs/errorlogwatch/yumlog_$time.txt
			echo "$data" >>$svrlogs/errorlogwatch/yumlog_$time.txt
			echo "" >>$svrlogs/errorlogwatch/yumlog_$time.txt
		done
	fi
}

yum_log

categorize_log
