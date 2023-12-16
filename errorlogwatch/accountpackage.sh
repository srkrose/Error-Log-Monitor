#!/bin/bash

source /home/sample/scripts/dataset.sh

function account_list() {
	cat /var/cpanel/accounting.log | grep -ie "$(date -d '12 hours ago' +"%Y")\|$(date -d '1 hours ago' +"%Y")" | awk -v Day1=$(date -d '12 hours ago' +%a) -v Day2=$(date -d '1 hours ago' +%a) -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%-d) -v Date2=$(date -d '1 hours ago' +%-d) -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($1 >= Day1 && $1 <= Day2) {if ($2 >= Month1 && $2 <= Month2) {if ($3 >= Date1 && $3 <= Date2) {if ($4 >= Time1 && $4 <= Time2) print $0}}}}' | awk -F':' '{print $1,$2,$3,$4,$7,$8,$9}' | awk '{if ($8=="CREATE") printf "%-19s %-25s %-50s\n","DATE: "$7"-"$2"-"$3,"USER: "$11,"DOMAIN: "$9}' >>$temp/accountcreate_$time.txt
}

function check_package() {
	if [ -r $temp/accountcreate_$time.txt ] && [ -s $temp/accountcreate_$time.txt ]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			username=$(echo "$line" | awk '{print $4}')
			package=$(whmapi1 accountsummary user=$username | grep -i "plan:" | awk -F':' '{print $2}')

			printf "%-100s %-70s\n" "$line" "PACKAGE: $package" >>$temp/accountpackage_$time.txt

		done <"$temp/accountcreate_$time.txt"
	fi
}

function sort_package() {
	if [ -r $temp/accountpackage_$time.txt ] && [ -s $temp/accountpackage_$time.txt ]; then
		tcount=$(wc -l $temp/accountpackage_$time.txt | awk '{print $1}')
		echo "Total: $tcount" >>$svrlogs/errorlogwatch/accountpackage_$time.txt
		echo "" >>$svrlogs/errorlogwatch/accountpackage_$time.txt

		package=$(cat $temp/accountpackage_$time.txt | awk -F':' '{print $NF}' | sed -e 's/^[[:space:]]*//' | sort | uniq)

		while IFS= read -r line; do
			data=$(cat $temp/accountpackage_$time.txt | grep "$line")
			ucount=$(echo "$line" | wc -l)

			echo "$line - $ucount" | xargs >>$svrlogs/errorlogwatch/accountpackage_$time.txt
			echo "$data" >>$svrlogs/errorlogwatch/accountpackage_$time.txt
			echo "" >>$svrlogs/errorlogwatch/accountpackage_$time.txt

		done <<<"$package"
	fi
}

account_list

check_package

sort_package
