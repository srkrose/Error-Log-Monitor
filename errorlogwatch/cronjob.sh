#!/bin/bash

source /home/sample/scripts/dataset.sh

function cronjob_list() {
	cat /var/spool/cron/* | grep -v "SHELL=\|MAILTO=" | awk '{if ($1=="*" || $1=="*/1" || $1=="*/2" || $1=="*/3" || $1=="*/4" || $1=="*/5" || $1=="*/6" || $1=="*/7" || $1=="*/8"|| $1=="*/9" || $1=="*/10" || $1=="*/11" || $1=="*/12" || $1=="*/13" || $1=="*/14") print $0}' | grep -v "/cpuloadalert.sh\|/dcpumon-wrapper\|/lscache -type\|/lincolk/\|/mahawat1/" >>$temp/cronjob_$time.txt
}

function check_log() {
	if [ -r $temp/cronjob_$time.txt ] && [ -s $temp/cronjob_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			cron=$(echo "$line" | cut -d" " -f6- | sed -e 's/^[[:space:]]*//;s/[[:blank:]]*$//')
			username=$(cat /var/log/cron | grep "$cron" | awk '{print $6}' | sort | uniq | sed 's/(//g;s/)//g')

			if [[ $username != "root" ]]; then
				edit_cron
			fi

		done <"$temp/cronjob_$time.txt"
	fi
}

function edit_cron() {
	num=$(grep -n "$cron" /var/spool/cron/$username | cut -d : -f1)
	col=$(echo "$line" | awk '{print $1}')

	if [[ ! -z $num ]]; then
		sed -i "$num s|$col|*/15|" /var/spool/cron/$username

		result=$(cat /var/spool/cron/$username | grep "$cron" | awk '{if ($1=="*/15") print 1; else print 0}')

		if [ $result -eq 1 ]; then
			status="Yes"
		else
			status="No"
		fi
	fi

	printf "%-25s %-20s\n" "USER: $username" "UPDATED: $status" >>$svrlogs/errorlogwatch/cronjob_$time.txt
	printf "CRONJOB: $line\n\n" >>$svrlogs/errorlogwatch/cronjob_$time.txt
}

cronjob_list

check_log
