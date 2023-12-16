#!/bin/bash

source /home/sample/scripts/dataset.sh

function last_log() {
	last | head -100 | awk -v Day1=$(date -d '12 hours ago' +%a) -v Day2=$(date -d '1 hours ago' +%a) -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%-d) -v Date2=$(date -d '1 hours ago' +%-d) '{if ($(NF-6) >= Day1 && $(NF-6) <= Day2) {if ($(NF-5) >= Month1 && $(NF-5) <= Month2) {if ($(NF-4) >= Date1 && $(NF-4) <= Date2) print $0}}}' | grep -v "tty1\|reboot" >>$temp/lastlog_$time.txt
}

function check_log() {
	if [ -r $temp/lastlog_$time.txt ] && [ -s $temp/lastlog_$time.txt ]; then
		ips=($(cat $temp/lastlog_$time.txt | awk '{print $3}' | sort | uniq))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			data=$(cat $temp/lastlog_$time.txt | grep ${ips[i]})

			whois=$(sh $scripts/ipmonitor/iplookup.sh ${ips[i]})

			while IFS= read -r line; do
				printf "%-80s %-30s\n" "$line" "ID: $whois" >>$svrlogs/errorlogwatch/lastlog_$time.txt

			done <<<"$data"
		done

		other=$(last | head -100 | awk -v Day1=$(date -d '12 hours ago' +%a) -v Day2=$(date -d '1 hours ago' +%a) -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%-d) -v Date2=$(date -d '1 hours ago' +%-d) '{if ($(NF-6) >= Day1 && $(NF-6) <= Day2) {if ($(NF-5) >= Month1 && $(NF-5) <= Month2) {if ($(NF-4) >= Date1 && $(NF-4) <= Date2) print $0}}}' | grep -v "pts")

		if [[ ! -z "$other" ]]; then
			echo "" >>$svrlogs/errorlogwatch/lastlog_$time.txt
			echo "$other" >>$svrlogs/errorlogwatch/lastlog_$time.txt
		fi
	fi
}

last_log

check_log
