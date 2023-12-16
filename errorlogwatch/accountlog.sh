#!/bin/bash

source /home/sample/scripts/dataset.sh

function account_log() {
	cat /var/cpanel/accounting.log | grep -ie "$(date -d '12 hours ago' +"%Y")\|$(date -d '1 hours ago' +"%Y")" | awk -v Day1=$(date -d '12 hours ago' +%a) -v Day2=$(date -d '1 hours ago' +%a) -v Month1=$(date -d '12 hours ago' +%b) -v Month2=$(date -d '1 hours ago' +%b) -v Date1=$(date -d '12 hours ago' +%-d) -v Date2=$(date -d '1 hours ago' +%-d) -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($1 >= Day1 && $1 <= Day2) {if ($2 >= Month1 && $2 <= Month2) {if ($3 >= Date1 && $3 <= Date2) {if ($4 >= Time1 && $4 <= Time2) print $0}}}}' | awk -F':' '{print $1,$2,$3,$4,$7,$8,$9}' | awk '{if ($8=="CREATE") printf "%-19s %-23s %-25s %-50s\n","DATE: "$7"-"$2"-"$3,"TYPE: "$8,"USER: "$11,"DOMAIN: "$9; else if ($8=="REMOVE") printf "%-19s %-23s %-25s %-50s\n","DATE: "$7"-"$2"-"$3,"TYPE: "$8,"USER: "$10,"DOMAIN: "$9; else if ($8=="SUSPEND" || $8=="UNSUSPEND") printf "%-19s %-23s %-25s %-50s\n","DATE: "$7"-"$2"-"$3,"TYPE: "$8,"USER: "$9,"DOMAIN: "$10; else if ($8=="CREATEAPITOKEN" || $8=="REVOKEAPITOKEN" || $8=="UPDATEAPITOKEN") printf "%-19s %-23s %-25s\n","DATE: "$7"-"$2"-"$3,"TYPE: "$8,"ID: "$10; else print $0;}' >>$temp/accountlog_$time.txt
}

function categorize_log() {
	if [ -r $temp/accountlog_$time.txt ] && [ -s $temp/accountlog_$time.txt ]; then
		cat $temp/accountlog_$time.txt | grep "CREATE" | grep -v "APITOKEN" >>$temp/createaccount_$time.txt
		cat $temp/accountlog_$time.txt | grep "REMOVE" | grep -v "APITOKEN" >>$temp/removeaccount_$time.txt
		cat $temp/accountlog_$time.txt | grep "SUSPEND" | grep -v "UNSUSPEND" >>$temp/suspendaccount_$time.txt
		cat $temp/accountlog_$time.txt | grep "UNSUSPEND" >>$temp/unsuspendaccount_$time.txt
		cat $temp/accountlog_$time.txt | grep "CREATEAPITOKEN" >>$temp/createapi_$time.txt
		cat $temp/accountlog_$time.txt | grep "REMOVEAPITOKEN" >>$temp/removeapi_$time.txt
		cat $temp/accountlog_$time.txt | grep "UPDATEAPITOKEN" >>$temp/updateapi_$time.txt
	fi
}

function summarize_log() {
	count=$(whmapi1 get_current_users_count | grep -i users: | awk '{print $2}')
	echo "Total Accounts: $count" >>$svrlogs/errorlogwatch/accountlog_$time.txt
	echo "" >>$svrlogs/errorlogwatch/accountlog_$time.txt

	if [ -r $temp/createaccount_$time.txt ] && [ -s $temp/createaccount_$time.txt ]; then
		count=$(wc -l $temp/createaccount_$time.txt | awk '{print $1}')
		echo "Accounts Created: $count" >>$svrlogs/errorlogwatch/accountlog_$time.txt
		cat $temp/createaccount_$time.txt >>$svrlogs/errorlogwatch/accountlog_$time.txt
		echo "" >>$svrlogs/errorlogwatch/accountlog_$time.txt
	fi

	if [ -r $temp/removeaccount_$time.txt ] && [ -s $temp/removeaccount_$time.txt ]; then
		count=$(wc -l $temp/removeaccount_$time.txt | awk '{print $1}')
		echo "Accounts Removed: $count" >>$svrlogs/errorlogwatch/accountlog_$time.txt
		cat $temp/removeaccount_$time.txt >>$svrlogs/errorlogwatch/accountlog_$time.txt
		echo "" >>$svrlogs/errorlogwatch/accountlog_$time.txt
	fi

	if [ -r $temp/suspendaccount_$time.txt ] && [ -s $temp/suspendaccount_$time.txt ]; then
		count=$(wc -l $temp/suspendaccount_$time.txt | awk '{print $1}')
		echo "Accounts Suspended: $count" >>$svrlogs/errorlogwatch/accountlog_$time.txt
		cat $temp/suspendaccount_$time.txt >>$svrlogs/errorlogwatch/accountlog_$time.txt
		echo "" >>$svrlogs/errorlogwatch/accountlog_$time.txt
	fi

	if [ -r $temp/unsuspendaccount_$time.txt ] && [ -s $temp/unsuspendaccount_$time.txt ]; then
		count=$(wc -l $temp/unsuspendaccount_$time.txt | awk '{print $1}')
		echo "Accounts Unsuspended: $count" >>$svrlogs/errorlogwatch/accountlog_$time.txt
		cat $temp/unsuspendaccount_$time.txt >>$svrlogs/errorlogwatch/accountlog_$time.txt
		echo "" >>$svrlogs/errorlogwatch/accountlog_$time.txt
	fi

	if [ -r $temp/createapi_$time.txt ] && [ -s $temp/createapi_$time.txt ]; then
		count=$(wc -l $temp/createapi_$time.txt | awk '{print $1}')
		echo "API Created: $count" >>$svrlogs/errorlogwatch/accountlog_$time.txt
		cat $temp/createapi_$time.txt >>$svrlogs/errorlogwatch/accountlog_$time.txt
		echo "" >>$svrlogs/errorlogwatch/accountlog_$time.txt
	fi

	if [ -r $temp/removeapi_$time.txt ] && [ -s $temp/removeapi_$time.txt ]; then
		count=$(wc -l $temp/removeapi_$time.txt | awk '{print $1}')
		echo "API Removed: $count" >>$svrlogs/errorlogwatch/accountlog_$time.txt
		cat $temp/removeapi_$time.txt >>$svrlogs/errorlogwatch/accountlog_$time.txt
		echo "" >>$svrlogs/errorlogwatch/accountlog_$time.txt
	fi

	if [ -r $temp/updateapi_$time.txt ] && [ -s $temp/updateapi_$time.txt ]; then
		count=$(wc -l $temp/updateapi_$time.txt | awk '{print $1}')
		echo "API Updated: $count" >>$svrlogs/errorlogwatch/accountlog_$time.txt
		cat $temp/updateapi_$time.txt >>$svrlogs/errorlogwatch/accountlog_$time.txt
		echo "" >>$svrlogs/errorlogwatch/accountlog_$time.txt
	fi
}

account_log

categorize_log

summarize_log
