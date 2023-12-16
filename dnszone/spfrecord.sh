#!/bin/bash

source /home/sample/scripts/dataset.sh

function account_spf() {
	newdomains=($(find $temp -type f -name "createaccount*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $newdomains ]]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			domain=$(echo "$line" | awk '{print $NF}')
			domip=$(whmapi1 dumpzone domain=$domain | grep -v "cname: " | grep -B 2 "name: webmail.$domain." | grep "address:" | awk '{print $NF}')
			spf="v=spf1 +a +mx +ip4:$domip +include:eig.spf.a.cloudfilter.net ~all"
			zonerecord=$(whmapi1 dumpzone domain=$domain | grep -B 2 "txtdata: v=spf1" | grep -A 2 "name: $domain." | grep "txtdata:" | sed 's/txtdata://' | sed -e 's/^[[:space:]]*//')

			spf_rec

		done <"$newdomains"
	fi
}

function addon_spf() {
	newdomains=($(find $svrlogs/errorlogwatch -type f -name "addonlog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $newdomains ]]; then
		while IFS= read -r line || [[ -n "$line" ]]; do
			domain=$(echo "$line" | awk '{print $6}')
			username=$(whmapi1 getdomainowner domain=$domain | grep -i "user:" | awk '{print $2}')
			domip=$(whmapi1 dumpzone domain=$domain | grep -v "cname: " | grep -B 2 "name: webmail.$domain." | grep "address:" | awk '{print $NF}')
			spf="v=spf1 +a +mx +ip4:$domip +include:eig.spf.a.cloudfilter.net ~all"
			zonerecord=$(whmapi1 dumpzone domain=$domain | grep -B 2 "txtdata: v=spf1" | grep -A 2 "name: $domain." | grep "txtdata:" | sed 's/txtdata://' | sed -e 's/^[[:space:]]*//')

			spf_rec

		done <"$newdomains"
	fi
}

function spf_rec() {

	if [[ ! -z $domip ]]; then
		if [[ "$zonerecord" != "$spf" ]]; then
			if [[ "$domip" != "$svrip" ]]; then
				iplist=$(ip a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d"/" -f1)

				filter=$(echo "$iplist" | grep "$domip")

				if [[ ! -z $filter ]]; then
					default="v=spf1 +a +mx +ip4:$domip ~all"
					def2="v=spf1 ip4:$domip +a +mx +include:eig.spf.a.cloudfilter.net ~all"

					spfrec="v%3Dspf1%20%2Ba%20%2Bmx%20%2Bip4%3A$domip%20%2Binclude%3Aeig.spf.a.cloudfilter.net%20~all"

					spf_update
				fi
			else
				default="v=spf1 +a +mx +ip4:$svrip ~all"
				def2="v=spf1 ip4:$svrip +a +mx +include:eig.spf.a.cloudfilter.net ~all"

				spfrec="v%3Dspf1%20%2Ba%20%2Bmx%20%2Bip4%3A$svrip%20%2Binclude%3Aeig.spf.a.cloudfilter.net%20~all"

				spf_update
			fi
		fi
	fi
}

function spf_update() {
	if [[ "$zonerecord" == "$default" || "$zonerecord" == "$def2" ]]; then
		result=$(whmapi1 install_spf_records domain=$domain record=$spfrec | grep -i "result:" | awk '{print $2}')

		print_data
	else
		result=0

		print_data
	fi
}

function print_data() {
	filename=$(echo "$newdomains" | awk -F'/' '{print $NF}' | awk -F'_' '{print $1}')

	if [[ $filename == "createaccount" ]]; then
		if [ "$result" -eq 1 ]; then
			printf "%-120s %-22s %-20s\n" "$line" "IP: $domip" "UPDATED: Yes" >>$svrlogs/dnszone/accountspf_$time.txt
			printf "SPF: $zonerecord\n\n" >>$svrlogs/dnszone/accountspf_$time.txt
		else
			printf "%-120s %-22s %-20s\n" "$line" "IP: $domip" "UPDATED: No" >>$svrlogs/dnszone/accountspf_$time.txt
			printf "SPF: $zonerecord\n\n" >>$svrlogs/dnszone/accountspf_$time.txt
		fi

	elif [[ $filename == "addonlog" ]]; then
		if [ "$result" -eq 1 ]; then
			printf "%-120s %-25s %-22s %-20s\n" "$line" "USER: $username" "IP: $domip" "UPDATED: Yes" >>$svrlogs/dnszone/addonspf_$time.txt
			printf "SPF: $zonerecord\n\n" >>$svrlogs/dnszone/addonspf_$time.txt
		else
			printf "%-120s %-25s %-22s %-20s\n" "$line" "USER: $username" "IP: $domip" "UPDATED: No" >>$svrlogs/dnszone/addonspf_$time.txt
			printf "SPF: $zonerecord\n\n" >>$svrlogs/dnszone/addonspf_$time.txt
		fi
	fi
}

account_spf

addon_spf
