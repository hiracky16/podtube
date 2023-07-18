#!/bin/sh
DIR_NAME=downloads

curl -X GET https://anchor.fm/s/91756cdc/podcast/rss > rss.xml

RSS=`cat rss.xml | tr -d '[:cntrl:]'`

if [ ! -e $DIR_NAME ]; then mkdir $DIR_NAME ; fi

image=`echo $RSS | xq -c -r '.rss.channel.image.url'`
echo $image
image_file=downloads/input_picture.png
wget -O $image_file $image

IFS=$'\n'; for item in $(echo $RSS | xq -c -r '.rss.channel.item[]'); do
  title=`echo $item | jq -r '.title'`
  echo $title
  url=`echo $item | jq -r '.enclosure."@url"'`
  guid=`echo $item | jq -r '.guid."#text"'`

  file="$DIR_NAME/${guid}.m4a"

  wget -O $file "$url"
  mp3_file=$DIR_NAME/$guid.mp3
  ffmpeg -i $file $mp3_file

  ffmpeg \
    -loop 1 \
    -r 30000/1001 \
    -i $image_file -i $mp3_file \
    -vcodec libx264 \
    -acodec aac -strict experimental -ab 320k -ac 2 -ar 48000 \
    -pix_fmt yuv420p \
    -shortest \
    -t 30 \
    $DIR_NAME/$guid.mp4
  # gsutil cp $DIR_NAME/$guid.mp4 gs://podtube/$guid.mp4
  break
done