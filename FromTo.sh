#!/bin/bash
################################################################################
# PROGRAM : FromTo.sh
# BY      : Paul Schaap
# DATED   : 2020-01-06
# PURPOSE : To find google directions between NMEA logs
################################################################################

MISSING=0
# Check for exiftool
EXIFTOOL="`which exiftool`"
if [ ! -f "$EXIFTOOL" ]
then
        echo "ERROR: exiftool missing, brew install exiftool"
        MISSING=1
fi
if [ $MISSING -eq 1 ]
then
        exit
fi

function find_log {
	GPS=""
	for LOG in $(ls $1/PRIVATE/SONY/GPS/*.LOG)
	do
		DATE=$(head -1 $LOG | awk -F\/ '{print $4}')
		if [ "$2" == "$DATE" ]
		then
			GPS=$LOG
		fi
	done
}

# Check if we are in the correct directory
if [ "$(ls */MP_ROOT)" != "" ] && [ "$(ls */PRIVATE/SONY/GPS)" != "" ]
then
	# All good
	echo -n
else
	echo "Usage $0 from one directory above the Sony storage roots, i.e. where there are MP_ROOT and PRIVATE subdirectories."
	exit
fi

PRV_TO=$1
FINISH=$2

N=1
NF=$(printf "%03d" $N)
for MP4 in $(ls */MP_ROOT/*/*.MP4)
do
	CD=$("$EXIFTOOL" -CreateDate $MP4 | grep "^Create Date")
	Y4=${CD:34:4}
	Y2=${CD:36:2}
	MN=${CD:39:2}
	DY=${CD:42:2}
	HH=${CD:45:2}
	MM=${CD:48:2}
	SS=${CD:51:2}
	find_log "$(echo "$MP4" | awk -F "/" '{print $1}')" "$Y4$MN$DY$HH$MM$SS.000"
	if [ "$GPS" != "" ]
	then
		if [ $(wc -l <"$GPS" | awk '{print $1}') -gt 10 ]
		then
			FROM=$(head -3 $GPS | tail -1 | awk -M -v PREC=100 -F, '{print int(($3)/100)+($3/100-int(($3)/100))*100/60$4","int(($5)/100)+($5/100-int(($5)/100))*100/60$6}')
			TO=$(tail -2 $GPS | head -1 | awk -M -v PREC=100 -F, '{print int(($3)/100)+($3/100-int(($3)/100))*100/60$4","int(($5)/100)+($5/100-int(($5)/100))*100/60$6}')
			# Assume the from is right
			if [ "$PRV_TO" == "" ]
			then
				PRV_TO=$FROM
			fi
			echo "$NF. Save https://www.google.com/maps/dir/$PRV_TO/$FROM as ${NF}_00000000.gpx"
			if [ "$TO" != "0,0" ]
			then
				PRV_TO=$TO
			fi
			N=$((N+2))
			NF=$(printf "%03d" $N)
		else
			echo "     GPS file $GPS too small to bother with"	
		fi
	else
		echo "     No GPS found for $MP4, probably a continuation ..."
	fi
done
echo "$NF. Save https://www.google.com/maps/dir/$PRV_TO/$FINISH as ${NF}_00000000.gpx"
