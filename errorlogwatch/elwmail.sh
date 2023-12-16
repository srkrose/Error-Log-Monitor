#!/bin/bash

source /home/sample/scripts/dataset.sh

function send_mail() {
	errorlogwatch=($(find $svrlogs/errorlogwatch -type f -name "errorlogwatch*" -exec ls -lat {} + | grep "$(date +"%F")" | head -1 | awk '{print $NF}'))

	if [ ! -z $errorlogwatch ]; then
		echo "SUBJECT: Error Log Watch - $(hostname) - $(date +"%F")" >>$svrlogs/mail/elwmail_$time.txt
		echo "FROM: Error Log Watch <root@$(hostname)>" >>$svrlogs/mail/elwmail_$time.txt
		echo "" >>$svrlogs/mail/elwmail_$time.txt
		echo "$(cat $errorlogwatch)" >>$svrlogs/mail/elwmail_$time.txt
		sendmail "$emaillo,$emaillg" <$svrlogs/mail/elwmail_$time.txt
	else
		echo "$(date +"%F %T") No content to send" >>$svrlogs/logs/errorlogwatchlogs_$logtime.txt
	fi
}

send_mail
