#!/bin/bash

source /home/sample/scripts/dataset.sh

function login_log() {
	cat /usr/local/cpanel/logs/login_log | awk -v Date1=$(date -d '12 hours ago' +"[%Y-%m-%d") -v Date2=$(date -d '1 hours ago' +"[%Y-%m-%d") -v Time1=$(date -d '12 hours ago' +"%H:00:00") -v Time2=$(date -d '1 hours ago' +"%H:59:59") '{if ($1 >= Date1 && $1 <= Date2) {if ($2 >= Time1 && $2 <= Time2) print $0}}' | grep "DEFERRED LOGIN" | grep "IP address has changed:" | awk '{print $1,$5,$6,$8,$9,$(NF-5)}' | sed 's/[][]//g;s/"//' | awk '{printf "%-19s %-20s %-13s %-25s %-26s %-50s\n","DATE: "$1,"LOGIN: "$2,"TYPE: "$5,"CURIP: "$3,"PREVIP: "$6,"USER: "$4}' | grep "whostmgrd" | sort | uniq -c | sort -nr >>$temp/logindefer_$time.txt
}

function check_log() {
	if [ -r $temp/logindefer_$time.txt ] && [ -s $temp/logindefer_$time.txt ]; then
		ips=($(cat $temp/logindefer_$time.txt | awk '{print $9}' | sort | uniq))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			search=$(whmapi1 read_cphulk_records list_name='black' | grep ${ips[i]})

			if [[ -z $search ]]; then
				data=$(cat $temp/logindefer_$time.txt | grep ${ips[i]})

				whois=$(sh $scripts/ipmonitor/iplookup.sh ${ips[i]})

				while IFS= read -r line; do
					printf "%-160s %-10s\n" "$line" "ID: $whois" >>$temp/deferred-login_$time.txt

				done <<<"$data"
			fi
		done
	fi
}

function sort_log() {
	if [ -r $temp/deferred-login_$time.txt ] && [ -s $temp/deferred-login_$time.txt ]; then
		cat $temp/deferred-login_$time.txt | sort -k12 >>$svrlogs/errorlogwatch/deferred-login_$time.txt
	fi
}

login_log

check_log

sort_log
