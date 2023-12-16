#!/bin/bash

source /home/sample/scripts/dataset.sh

function exim_log() {
	exigrep '451 Temporary local problem' /var/log/exim_mainlog | cat | awk -v Date1=$(date -d '12 hours ago' +%Y-%m-%d) -v Date2=$(date -d '1 hours ago' +%Y-%m-%d) -v Time1=$(date -d '12 hours ago' +%H:00:00) -v Time2=$(date -d '1 hours ago' +%H:59:59) '{if ($1 >= Date1 && $1 <= Date2) {if ($2 >= Time1 && $2 <= Time2) print $0}}' >>$temp/error451_$time.txt
}

function check_log() {
	if [ -r $temp/error451_$time.txt ] && [ -s $temp/error451_$time.txt ]; then
		eximid=($(cat $temp/error451_$time.txt | awk '{print $3}' | sort | uniq))
		count=${#eximid[@]}

		for ((i = 0; i < count; i++)); do
			status=$(cat $temp/error451_$time.txt | grep "${eximid[i]}" | tail -1 | awk '{print $NF}')

			if [[ $status != "Completed" ]]; then
				echo "Exim ID: ${eximid[i]}" >>$svrlogs/errorlogwatch/error451_$time.txt

				cat /var/log/exim_mainlog | grep "${eximid[i]}" >>$temp/${eximid[i]}-error451_$time.txt

				started=$(cat $temp/${eximid[i]}-error451_$time.txt | grep "${eximid[i]}" | head -1 | awk '{print $1" "$2}')

				lastrec=$(cat $temp/${eximid[i]}-error451_$time.txt | grep "${eximid[i]}" | tail -1 | awk '{print $1" "$2}')

				echo "Started: $started" >>$svrlogs/errorlogwatch/error451_$time.txt
				echo "Last Record: $lastrec" >>$svrlogs/errorlogwatch/error451_$time.txt

				sender=$(exim -bp | grep "${eximid[i]}" | awk '{print $NF}' | sed 's/<//;s/>//')

				echo "Sender: $sender" >>$svrlogs/errorlogwatch/error451_$time.txt

				receivers=$(exiqgrep -abf $sender | grep "${eximid[i]}" | awk -F'To:' '{print $2}' | tr ";" "\n" | sed 's/D//;s/ //g')

				echo "Receivers in queue:" >>$svrlogs/errorlogwatch/error451_$time.txt
				echo "$receivers" >>$svrlogs/errorlogwatch/error451_$time.txt
				echo "" >>$svrlogs/errorlogwatch/error451_$time.txt
			fi
		done
	fi
}

exim_log

check_log
