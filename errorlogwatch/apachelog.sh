#!/bin/bash

source /home/sample/scripts/dataset.sh

function apache_log() {
	cat /usr/local/apache/logs/error_log | awk -v Day1=$(date -d '12 hours ago' +"[%a") -v Day2=$(date -d '1 hours ago' +"[%a") -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%d) -v Date2=$(date -d '1 hours ago' +%d) -v Time1=$(date -d '12 hours ago' +%H:00:00.000000) -v Time2=$(date -d '1 hours ago' +%H:59:59.999999) -v Year1=$(date -d '12 hours ago' +%Y]) -v Year2=$(date -d '1 hours ago' +%Y]) '{if ($1 >= Day1 && $1 <= Day2) {if ($2 >= Month1 && $2 <= Month2) {if ($3 >= Date1 && $3 <= Date2) {if ($4 >= Time1 && $4 <= Time2) {if ($5 >= Year1 && $5 <= Year2) print $0}}}}}' | grep -iE "MaxRequestWorkers" >>$temp/maxrequest_$time.txt
}

function check_log() {
	if [ -r $temp/maxrequest_$time.txt ] && [ -s $temp/maxrequest_$time.txt ]; then
		cp $temp/maxrequest_$time.txt $svrlogs/errorlogwatch/maxrequest_$time.txt
	fi
}

apache_log

check_log
