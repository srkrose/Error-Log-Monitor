#!/bin/bash

source /home/sample/scripts/dataset.sh

function bot_log() {
	egrep -i "bot" /var/log/apache2/domlogs/*/* | awk -v Date1=`date -d '11 hours ago' +[%d/%b/%Y:%H:00:00` -v Date2=`date +[%d/%b/%Y:%H:59:59` '{if ($4 >= Date1 && $4 <= Date2) print $0}' | awk '{for(i=1;i<=NF;i++) {for(j=1;j<=NF;j++) {if($i~/HTTP/ && $j=="compatible;" && $(j+1)!~/http/) print $1,$4,$6,$(i+1),$(j+1),$(j+2)}}}' | awk -F'[/+ :]' '{printf "%-20s %-22s %-13s %-12s %-20s %-25s %-50s\n","DATE: "$11"-"$10"-"$9,"IP: "$8,"TYPE: "$15,"STAT: "$16,"BOT: "$17,"USER: "$6,"LOG: "$7}' | sed 's/[][]//;s/(//;s/;//;s/"//g;s/'\''//g' | awk '{if($8==200) print $10}' | sort | uniq -c | sort -nr >>$temp/botlog_$time.txt
}

function check_log() {
	if [ -r $temp/botlog_$time.txt ] && [ -s $temp/botlog_$time.txt ]; then
		cp $temp/botlog_$time.txt $svrlogs/errorlogwatch/botlog_$time.txt
	fi
}

bot_log

check_log
