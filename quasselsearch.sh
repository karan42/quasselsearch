#!/bin/bash
#Usage : quasselsearch.sh -n <nick> -c <channel> -t start date in the format "YYYY-MM-DD HH:MM:SS" -e end date in same format -s search term -o output file 
#Everything is optional




#Initialise the variables
nick="%%"
channel="%%"
time=0
search="%%"
endtime="2524626000"
stdout=1
timeformat="%d/%m/%y %T"
quasseluser="%$USER%"
#Get the parameters
while getopts 'n:c:t:s:e:o:f:q:' flag; do
	case $flag in 
		n) nick="%$OPTARG%" ;;
		c) channel="%$OPTARG%" ;;
		t) time=$(date -d "$OPTARG" "+%s") ;;
		s) search="%$OPTARG%" ;;
		e) endtime=$(date -d "$OPTARG" "+%s") ;;
		o) output=$OPTARG ;;
		f) timeformat="$OPTARG" ;;
		q) quasseluser="$OPTARG" ;;
		*) echo "ERROR" ;;
		esac
	done

if [ ! $output ]; then 
	output=/tmp/chatlogs.kk
	stdout=0
fi
#echo "nick: $nick  c: $channel t : $time s: $search e: $endtime o:  $output"
if [ ! -f $output ]; then
	touch $output
fi
sqlite3 -csv /var/lib/quassel/quassel-storage.sqlite "SELECT backlog.time,buffer.buffername,sender.sender,backlog.message FROM backlog,buffer,sender,quasseluser WHERE backlog.time BETWEEN $time AND $endtime AND quasseluser.username LIKE \"$quasseluser\" AND buffer.userid = quasseluser.userid AND backlog.senderid = sender.senderid AND backlog.bufferid = buffer.bufferid AND buffer.buffername LIKE \"$channel\" AND sender.sender like \"$nick\" AND backlog.message LIKE \"$search\"" > "$output"
touch "$output.tmp"
tmpfile="$output.tmp"
awk -F, -vtimeformat="$timeformat" 'BEGIN {OFS=","}{$1=strftime(timeformat,$1);split($3,a,"!");$3="<"a[1]">";print}' $output > $tmpfile
mv $tmpfile $output
if [ $stdout -eq 0 ]; then
	cat $output
	rm $output
fi
