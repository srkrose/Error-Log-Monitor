#!/bin/bash

source /home/sample/scripts/dataset.sh

function cpbroken_log() {
	cat /usr/local/cpanel/logs/cphulkd_errors.log | awk -v Date1=$(date -d '12 hours ago' +"[%Y-%m-%d") -v Date2=$(date -d '1 hours ago' +"[%Y-%m-%d") -v Time1=$(date -d '12 hours ago' +"%H:00:00") -v Time2=$(date -d '1 hours ago' +"%H:59:59") '{if ($1 >= Date1 && $1 <= Date2) {if ($2 >= Time1 && $2 <= Time2) print $0}}' | grep "Broken pipe" >>$temp/cpbrokenlog_$time.txt
}

function cperror_log() {
	cat /usr/local/cpanel/logs/cphulkd_errors.log | awk -v Date1=$(date -d '12 hours ago' +"[%Y-%m-%d") -v Date2=$(date -d '1 hours ago' +"[%Y-%m-%d") -v Time1=$(date -d '12 hours ago' +"%H:00:00") -v Time2=$(date -d '1 hours ago' +"%H:59:59") '{if ($1 >= Date1 && $1 <= Date2) {if ($2 >= Time1 && $2 <= Time2) print $0}}' | grep "Internal Failure" | grep "does not own the email account" | awk '{print $1,$8,$12,$NF}' | sed 's/[][]//;s/(state://;s/“//g;s/”//g;s/\.[^.]*$//' | awk '{printf "%-19s %-17s %-20s %-50s\n","DATE: "$1,"STATE: "$2,"USER: "$3,"EMAIL: "$NF}' | sort | uniq -c | sort -nr >>$temp/cperrorlog_$time.txt
}

function check_broken() {
	if [ -r $temp/cpbrokenlog_$time.txt ] && [ -s $temp/cpbrokenlog_$time.txt ]; then
		cp $temp/cpbrokenlog_$time.txt $svrlogs/errorlogwatch/cpbrokenlog_$time.txt
	fi
}

function mail_check() {
	if [ -r $temp/cperrorlog_$time.txt ] && [ -s $temp/cperrorlog_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			email=$(echo "$line" | awk '{print $NF}')
			username=$(echo "$line" | awk '{print $7}')

			status=$(uapi --user=$username Mailboxes get_mailbox_status_list account=$email | grep -i "status:" | awk '{print $2}')

			if [ "$status" -eq 0 ]; then
				printf "%-120s %-15s\n" "$line" "MAILBOX: No" >>$temp/cpmailbox_$time.txt
			fi

		done <"$temp/cperrorlog_$time.txt"
	fi
}

function check_log() {
	if [ -r $temp/cpmailbox_$time.txt ] && [ -s $temp/cpmailbox_$time.txt ]; then
		cp $temp/cpmailbox_$time.txt $svrlogs/errorlogwatch/cpmailbox_$time.txt
	fi
}

cpbroken_log

cperror_log

check_broken

mail_check

check_log
