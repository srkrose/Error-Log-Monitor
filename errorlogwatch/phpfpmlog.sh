#!/bin/bash

source /home/sample/scripts/dataset.sh

function fpm_log() {
	cat /usr/local/cpanel/logs/php-fpm/error.log | awk -v Date1=$(date -d '12 hours ago' +"[%d-%b-%Y") -v Date2=$(date -d '1 hours ago' +"[%d-%b-%Y") -v Time1=$(date -d '12 hours ago' +"%H:00:00]") -v Time2=$(date -d '1 hours ago' +"%H:59:59]") '{if ($1 >= Date1 && $1 <= Date2) {if ($2 >= Time1 && $2 <= Time2) print $0}}' | grep -iv "using inherited socket" | tail >>$temp/fpmerror_$time.txt
}

function check_log() {
	if [ -r $temp/fpmerror_$time.txt ] && [ -s $temp/fpmerror_$time.txt ]; then
		status=$(cat $temp/fpmerror_$time.txt | tail -1 | awk '{print $4" "$5" "$6" "$NF}')

		if [[ "$status" != "ready to handle connections" ]]; then
			cp $temp/fpmerror_$time.txt $svrlogs/errorlogwatch/fpmerror_$time.txt
		fi
	fi
}

fpm_log

check_log
