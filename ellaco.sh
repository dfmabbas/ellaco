#!/usr/bin/env bash
terminal=`tty`

echo "LOADING ..."

q="best"
s="none"
p=$PWD'/'

setting="-ciw -4 -R infinite"

while getopts q:f:p:s: option
do
    case "${option}"
        in
        q) q=${OPTARG};;
        f) f=${OPTARG};;
        p) p=${OPTARG};;
        s) s=${OPTARG};;
    esac
done

log="log.txt"
rm -rf $log
touch $log
printLOG(){
    echo $1 >> $log
}


if [[ $s == *"none"* ]]; then
    subtitle=""
else
    subtitle="--write-auto-sub --sub-lang $s --embed-subs"
fi

if [[ $q != *"best"* ]]; then
    echo "UNKNOWN ARGUMENT"
    return
else quality="-f $q"
fi

videoOutput="-o  $p""youtube/other/%(title)s.%(ext)s"
listOutput="-o $p ""youtube/%(playlist)s/%(playlist_index)s.%(title)s.%(ext)s -i --yes-playlist"
channelOutput="-o $p""youtube/%(uploader)s/(channel)s/(playlist)s/%(playlist_index)s.%(title)s.%(ext)s"

ariaQuery="-x6 -s6 -j1 -c -m 1000 --retry-wait=15 -d $p"
channelQuery="$quality $setting $subtitle $channelOutput"
playLisQuery="$quality $setting $subtitle $listOutput"
videoQuery="$quality $setting $subtitle $videoOutput"

downoadURL(){
    if [[ $1 == *"youtube"* && $1 == *"&list="* ]]; then
        youtube-dl $playLisQuery $1
        elif [[ $1 == *"youtube"* && $1 == *"watch"* ]]; then
        youtube-dl $videoQuery $1
        elif [[ $1 == *"youtube"* && $1 == *"channel"* ]]; then
        youtube-dl $channelQuery $1
        elif [[ $1 == *"http"* && $1 != *"youtube"* ]]; then
        aria2c $ariaQuery $1
    else
        printLOG "JUMP"
        return
    fi
    
    printLOG "DOWNLOADED URL -> $1"
}

exec < $f
while read -r url
do
    
    if [[ $1 == *"end"* ]]; then
        #say complete download items #macos
        echo "COMPLETE DOWNLOAD ITEMS"
        break
        return
    else downoadURL $url
    fi
    
done
exec < "$terminal"