#! /bin/bash
# Initialising Carelink Automation
# Proof of concept ONLY - 640g csv to NightScout
#
echo '*****************************'
echo '***       CHIP640G       ***'
echo '*** FOR TEST PURPOSES ONLY***'
echo '*Only Use If You Accept This*'
echo '* Started 5th May 2016      *'
echo '*** Thanks - @LittleDMatt ***'
echo '*****************************'
VERSION='V0.12 10th May 2016'
echo $VERSION
echo
echo "Indebted to Lennart Goerdhart for https://github.com/pazaan/decoding-contour-next-link"
echo "Please use with caution. There'll be bugs here..."
echo "You run this at your own risk."
echo "Thank you."

echo '*****************************'
echo ' Known Issues TO (TRY TO) FIX'
echo '*****************************'
echo 'Tons - this is thrown together...'
echo '*****************************'
echo Setting Varables...
source pi_config.sh

# Capture empty JSON files later ie "[]"
EMPTYSIZE=3 #bytes
# ****************************************************************************************
# Let's go...
# ****************************************************************************************

# Uploader setup
#START_TIME=0	#last time we ran the uploader (if at all)

# Check if we're probably running as cron job
#uptime1=$(</proc/uptime)
#uptime1=${uptime%%.*}

# Allow to run for ~240 hours (roughly), ~5 min intervals
# This thing is bound to need some TLC and don't want it running indefinitely...
#COUNT=0
#MAXCNT=2880
#until [ $COUNT -gt $MAXCNT ]; do

# Set up value file 

touch latest_sg.json

#Check time to avoid overlap with pump and transmitter communication

M=$(date +%M)

echo $M > t.txt

sed -i '1s/^.\(.*\)/\1/' t.txt 

time=$(<t.txt)

if [ $time -eq 1 ] || [ $time -eq 6 ] || [ $time -eq 2 ] || [ $time -eq 7 ]; then

        echo Waiting 
	sleep 90

else
	echo Running
	sleep 5
	sudo python read_minimed_next24.py
	sleep 10
	sudo python read_minimed_next24.py
fi

# Time to extract and upload entries (SG only)
filesize=0
if [ -s latest_sg.json ] 
then 
	filesize=$(stat -c%s latest_sg.json)
fi
if [ $filesize -gt $EMPTYSIZE ]
then
#	sed -i '1s/^/[{/' latest_sg.json
#	echo '}]' >> latest_sg.json
#	more latest_sg.json

	sed -i '1s/^/{/' latest_sg.json
	echo '}' >> latest_sg.json
	more latest_sg.json
fi

# Write data to local file for offline use ensuring that the glucose level has been updated

./line_add.sh
echo "line add complete"

./comma_check.sh
echo "comma check complete"

# cp sg_monitor.json /home/pi/timsaps/monitor/glucose.json
cp sg_monitor.json /home/pi/myopenaps/monitor/glucose.json

echo "file copied"

curl -s -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "api-secret:"$api_secret_hash --data-binary @latest_sg.json "$your_nightscout"$"/api/v1/entries"

cp latest_sg.json old_data/latest.json
cp latest_sg_prev.json old_data/latest_sg_prev.json
cp latest_sg.json latest_sg_prev.json

rm latest_sg.json
echo "file removed"

#echo
# And now basal info
# filesize=$(wc -c <latest_basal.json)
#filesize=0
#if [ -s latest_basal.json ]
#then
#	filesize=$(stat -c%s latest_basal.json)
#fi
#if [ $filesize -gt $EMPTYSIZE ]
#then
#	sed -i '1s/^/[{/' latest_basal.json
#	echo '}]' >> latest_basal.json
#	more latest_basal.json
#	curl -s -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "api-secret:"$api_secret_hash --data-binary @latest_basal.json "$your_nightscout"$"/api/v1/treatments"
#fi

#echo
#echo "Checking for Bayer..."
#lsusb > /home/pi/decoding-contour-next-link/lsusb.log
#grep 'Bayer' /home/pi/decoding-contour-next-link/lsusb.log > /home/pi/decoding-contour-next-link/usb.log
# Bayer will be listed -  "Bayer Health Care LLC"
# Action (if required): reboot (ffs, got to be a better way :o )
#if [ ! -s /home/pi/decoding-contour-next-link/usb.log  ] 
#then 
#	echo 'Announcement - USB Loss'
#	echo '{"enteredBy": "Uploader", "eventType": "Announcement", "reason": "", "notes": "Cycle Bayer Power", "created_at": "'$(date +"%Y-%m-%dT%H:%M:%S.000%z")$'", " isAnnouncement": true }' > announcement.json
#	curl -s -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "api-secret:"$api_secret_hash --data-binary @announcement.json "$your_nightscout"$"/api/v1/treatments"
#/sbin/shutdown -r +1
#fi

#echo "Waiting..."
#sleep $gap_seconds
#rm -f latest_sg.json
#rm -f latest_basal.json

#let COUNT=COUNT+1
#echo $COUNT
# done
