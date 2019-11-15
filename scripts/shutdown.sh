#!/bin/sh 
for user in $(who | cut -d' ' -f1 | sort | uniq | grep -v admin) 
do 
echo $user 
pkill -9 -u $user loginwindow 
done   
/sbin/shutdown -h now 
