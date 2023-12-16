#!/bin/bash

source /home/sample/scripts/dataset.sh

function ssh_log() {
	cat /var/log/secure | awk -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%-d) -v Date2=$(date -d '1 hours ago' +%-d) -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($1 >= Month1 && $1 <= Month2) {if ($2 >= Date1 && $2 <= Date2) {if ($3 >= Time1 && $3 <= Time2) print $0}}}' | grep -iv "pam_unix\|wp-toolkit\|127.0.0.1\|Bad protocol version\|sudo:" >>$temp/sshlog_$time.txt
}

function check_log() {
	if [ -r $temp/sshlog_$time.txt ] && [ -s $temp/sshlog_$time.txt ]; then
		cp $temp/sshlog_$time.txt $svrlogs/errorlogwatch/sshlog_$time.txt
	fi
}

ssh_log

check_log
