#!/bin/bash
URL=$1
LAST_WD=$(pwd)

cd /srv/yt/downloads
if [[ $? -ne 0 ]]
then
exit
fi

cd /var/log/yt
if [[ $? -ne 0 ]]
then
exit
fi

cd $LAST_WD

LOG_PATH=/var/log/yt/download.log

VIDEO_NAME=$(youtube-dl -e "$URL")
DIR_PATH="/srv/yt/downloads/$VIDEO_NAME"
FILE_PATH="$DIR_PATH/$VIDEO_NAME.mp4"
mkdir "$DIR_PATH" &> /dev/null

youtube-dl "$URL" --output="$FILE_PATH" &> /dev/null
if [[ $? -ne 0 ]]
then
echo "Failed."
exit
fi

youtube-dl --get-description "$URL" > "$DIR_PATH/description" 2> /dev/null

echo "Video $URL was downloaded."
echo "File path : $FILE_PATH"

echo "[$(date +%D) $(date +%T)] Video $URL was downloaded. File path : $FILE_PATH" >> $LOG_PATH
