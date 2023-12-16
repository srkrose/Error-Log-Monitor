#!/bin/bash

source /home/sample/scripts/dataset.sh

function lve_kill() {
	cat /var/log/messages | awk -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%-d) -v Date2=$(date -d '1 hours ago' +%-d) -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($1 >= Month1 && $1 <= Month2) {if ($2 >= Date1 && $2 <= Date2) {if ($3 >= Time1 && $3 <= Time2) print $0}}}' | grep -ie "killed as a result of limit" | awk '{print $1,$2,$NF}' | sed 's/\/lve//' | awk '{printf "%-15s %-15s\n","DATE: "$1" "$2,"LVE_ID: "$NF}' | sort | uniq -c | sort -nr >>$temp/lvekill_$time.txt
}

function check_data() {
	if [ -r $temp/lvekill_$time.txt ] && [ -s $temp/lvekill_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			lveid=$(echo "$line" | awk '{print $NF}')
			username=$(cloudlinux-limits --json get --lve-id $lveid | tr "," "\n" | grep "username" | awk '{print $2}' | sed 's/"//g;s/]//g;s/}//g')

			printf "%-40s %-30s\n" "$line" "USERNAME: $username" >>$svrlogs/errorlogwatch/lvekill_$time.txt

		done <"$temp/lvekill_$time.txt"
	fi
}

lve_kill

check_data
