#!/bin/bash

source /home/sample/scripts/dataset.sh

function ext_index() {
	cat /var/log/messages | awk -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%-d) -v Date2=$(date -d '1 hours ago' +%-d) -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($1 >= Month1 && $1 <= Month2) {if ($2 >= Date1 && $2 <= Date2) {if ($3 >= Time1 && $3 <= Time2) print $0}}}' | grep "EXT4-fs warning" >>$temp/extindex_$time.txt
}

function check_data() {
	if [ -r $temp/extindex_$time.txt ] && [ -s $temp/extindex_$time.txt ]; then
		count=$(cat $temp/extindex_$time.txt | wc -l)
		summary=$(cat $temp/extindex_$time.txt | sort | uniq -c)

		echo "Count: $count" >>$svrlogs/errorlogwatch/extindex_$time.txt
		echo "" >>$svrlogs/errorlogwatch/extindex_$time.txt
		echo "$summary" >>$svrlogs/errorlogwatch/extindex_$time.txt
	fi
}

ext_index

check_data
