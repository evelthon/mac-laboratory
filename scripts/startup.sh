#!/bin/sh  
for home in $(ls /Users | grep -v localadmin | grep -v Shared | grep -v admin | grep -v library)  
do  
# echo $home  
sudo dscl . -delete /Users/$home  
sudo rm -rf /Users/$home  
done 
