#!/bin/bash

source /home/sample/scripts/dataset.sh

function access_log() {
	cat /usr/local/cpanel/logs/access_log | awk -v Date1=$(date -d '12 hours ago' -u +"[%m/%d/%Y:%H:00:00") -v Date2=$(date -d '7 hours ago' -u +"[%m/%d/%Y:%H:59:59") '{if ($4 >= Date1 && $4 <= Date2) print $0}' | awk '{print $1,$3,$4,$6,$9,$NF}' | awk -F'[/ :]' '{if ($2!="-") printf "%-19s %-13s %-16s %-13s %-22s %-13s\n","DATE: "$5"-"$3"-"$4,"TYPE: "$9,"RESPONSE: "$10,"PORT: "$NF,"IP: "$1,"USER: "$2}' | sed 's/[][]//;s/"//g' | sort | uniq -c | sort -nr | grep -ie "POST\|GET" | grep -ie "2086\|2087" >>$temp/whmaccess_$time.txt

	cat /usr/local/cpanel/logs/access_log | awk -v Date1=$(date -d '6 hours ago' -u +"[%m/%d/%Y:%H:00:00") -v Date2=$(date -d '1 hours ago' -u +"[%m/%d/%Y:%H:59:59") '{if ($4 >= Date1 && $4 <= Date2) print $0}' | awk '{print $1,$3,$4,$6,$9,$NF}' | awk -F'[/ :]' '{if ($2!="-") printf "%-19s %-13s %-16s %-13s %-22s %-13s\n","DATE: "$5"-"$3"-"$4,"TYPE: "$9,"RESPONSE: "$10,"PORT: "$NF,"IP: "$1,"USER: "$2}' | sed 's/[][]//;s/"//g' | sort | uniq -c | sort -nr | grep -ie "POST\|GET" | grep -ie "2086\|2087" >>$temp/whmaccess_$time.txt
}

function check_log() {
	if [ -r $temp/whmaccess_$time.txt ] && [ -s $temp/whmaccess_$time.txt ]; then
		ips=($(cat $temp/whmaccess_$time.txt | awk '{print $11}' | sort | uniq))
		count=${#ips[@]}

		for ((i = 0; i < count; i++)); do
			data=$(cat $temp/whmaccess_$time.txt | grep ${ips[i]})

			whois=$(sh $scripts/ipmonitor/iplookup.sh ${ips[i]})

			while IFS= read -r line; do
				printf "%-105s %-30s\n" "$line" "ID: $whois" >>$svrlogs/errorlogwatch/whmaccess_$time.txt

			done <<<"$data"
		done
	fi
}

access_log

check_log
