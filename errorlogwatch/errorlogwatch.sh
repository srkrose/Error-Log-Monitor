#!/bin/bash

source /home/sample/scripts/dataset.sh

function check_directory() {
	sh $scripts/directory.sh
}

printf "Error Log Watch - $(date +"%F %T")\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

function apache_log() {
	printf "\n# *** Apache Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/apachelog.sh

	apachelog=($(find $svrlogs/errorlogwatch -type f -name "maxrequest*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $apachelog ]]; then
		echo "$(cat $apachelog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No max request workers found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function access_log() {
	printf "\n# *** WHM Access Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/accesslog.sh

	accesslog=($(find $svrlogs/errorlogwatch -type f -name "whmaccess*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $accesslog ]]; then
		echo "$(cat $accesslog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No whm access history\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function phpfpm_log() {
	printf "\n# *** PHP FPM Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/phpfpmlog.sh

	phpfpmlog=($(find $svrlogs/errorlogwatch -type f -name "fpmerror*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $phpfpmlog ]]; then
		echo "$(cat $phpfpmlog | tail -1)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No php fpm error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function account_log() {
	printf "\n# *** Account Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/accountlog.sh

	accountlog=($(find $svrlogs/errorlogwatch -type f -name "accountlog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $accountlog ]]; then
		echo "$(cat $accountlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No account history\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function spf_log() {
	printf "\n# *** SPF Check - New Account ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/dnszone/spfrecord.sh

	accountspf=($(find $svrlogs/dnszone -type f -name "accountspf*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $accountspf ]]; then
		echo "$(cat $accountspf)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No SPF updates\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	printf "\n# *** SPF Check - Addon Domain ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	addonspf=($(find $svrlogs/dnszone -type f -name "addonspf*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $addonspf ]]; then
		echo "$(cat $addonspf)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No SPF updates\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function account_new() {
	printf "\n# *** Account Log - New Accounts ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/accountpackage.sh

	accountnew=($(find $svrlogs/errorlogwatch -type f -name "accountpackage*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $accountnew ]]; then
		echo "$(cat $accountnew)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No new accounts\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function addon_log() {
	printf "\n# *** Addon Domain Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/addonlog.sh

	addonlog=($(find $svrlogs/errorlogwatch -type f -name "addonlog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $addonlog ]]; then
		echo "$(cat $addonlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No new addon domains\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function ssh_log() {
	printf "\n# *** SSH Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/sshlog.sh

	sshlog=($(find $svrlogs/errorlogwatch -type f -name "sshlog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $sshlog ]]; then
		echo "$(cat $sshlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No ssh login attempts\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function exim_log() {
	printf "\n# *** Exim Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/eximlog.sh

	eximlog=($(find $svrlogs/errorlogwatch -type f -name "error451*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $eximlog ]]; then
		echo "$(cat $eximlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No 451 error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function logindefer_log() {
	printf "\n# *** Login Log - Deferred ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/logindefer.sh

	logindefer=($(find $svrlogs/errorlogwatch -type f -name "deferred-login*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $logindefer ]]; then
		echo "$(cat $logindefer)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No login defer found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function cron_log() {
	printf "\n# *** Cron Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/cronlog.sh

	cronlog=($(find $svrlogs/errorlogwatch -type f -name "cronlog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $cronlog ]]; then
		echo "$(cat $cronlog | head)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No cron job history\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function last_log() {
	printf "\n# *** Last Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/lastlog.sh

	lastlog=($(find $svrlogs/errorlogwatch -type f -name "lastlog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $lastlog ]]; then
		echo "$(cat $lastlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No server login history\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function cron_jobs() {
	printf "\n# *** Cron Jobs ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/cronjob.sh

	cronjob=($(find $svrlogs/errorlogwatch -type f -name "cronjob*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $cronjob ]]; then
		echo "$(cat $cronjob)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No limit exceeded cron jobs\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function dbgovernor_log() {
	printf "\n# *** DBGovernor Error Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/dbgovernorlog.sh

	dbgov=($(find $svrlogs/errorlogwatch -type f -name "dbgoverror*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $dbgov ]]; then
		echo "$(cat $dbgov)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No DBGovernor error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function lve_kill() {
	printf "\n# *** LVE Process Kill ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/lvekill.sh

	lvekill=($(find $svrlogs/errorlogwatch -type f -name "lvekill*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $lvekill ]]; then
		echo "$(cat $lvekill)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No process kill records found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function yum_log() {
	printf "\n# *** Yum Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/yumlog.sh

	yumlog=($(find $svrlogs/errorlogwatch -type f -name "yumlog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $yumlog ]]; then
		echo "$(cat $yumlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No yum records found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function cperror_log() {
	printf "\n# *** cPHulk Error Log - Broken ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/cphulkerror.sh

	cpbroken=($(find $svrlogs/errorlogwatch -type f -name "cpbrokenlog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $cpbroken ]]; then
		echo "$(cat $cpbroken)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No broken pipe error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	printf "\n# *** cPHulk Error Log - Mailbox ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	cpmailbox=($(find $svrlogs/errorlogwatch -type f -name "cpmailbox*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $cpmailbox ]]; then
		echo "$(cat $cpmailbox)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No ftpd-mailbox error found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function notification_log() {
	printf "\n# *** Error Log - Notification ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/notification.sh

	notification=($(find $svrlogs/errorlogwatch -type f -name "notification*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $notification ]]; then
		echo "$(cat $notification)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No notifications found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function ext_index() {
	printf "\n# *** EXT Warning ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/extindex.sh

	extindex=($(find $svrlogs/errorlogwatch -type f -name "extindex*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $extindex ]]; then
		echo "$(cat $extindex)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No directory index full warning found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function bot_log() {
	printf "\n# *** BOT Request ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	
	botlog=($(find $svrlogs/errorlogwatch -type f -name "botlog*" -exec ls -lat {} + | grep "$(date -d '15 minutes ago' +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $botlog ]]; then
		echo "$(cat $botlog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No BOT requests found\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function cpupdate_log() {
	printf "\n# *** WHM Version Update Log ***\n\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt

	sh $scripts/errorlogwatch/cpupdatelog.sh

	cpupdatelog=($(find $svrlogs/errorlogwatch -type f -name "cpupdatelog*" -exec ls -lat {} + | grep "$(date +"%F_%H:")" | head -1 | awk '{print $NF}'))

	if [[ ! -z $cpupdatelog ]]; then
		echo "$(cat $cpupdatelog)" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	else
		printf "No new version updates\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
	fi

	printf "\n************************************************************\n" >>$svrlogs/errorlogwatch/errorlogwatch_$time.txt
}

function send_mail() {
	sh $scripts/errorlogwatch/elwmail.sh
}

check_directory

access_log

last_log

logindefer_log

ssh_log

cpupdate_log

apache_log

bot_log

exim_log

cron_jobs

account_log

account_new

addon_log

spf_log

lve_kill

ext_index

dbgovernor_log

cperror_log

phpfpm_log

cron_log

yum_log

notification_log

send_mail
