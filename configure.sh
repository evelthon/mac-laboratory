#!/bin/sh
 
# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# TODO: Set desired computer name
read -s -p "Enter desired computer name: " computerName
echo $computerName

# Id not added to AD, do a BIND  
currentDomain=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')
# Bind, if not binded
if [[ $currentDomain -ne 'ucy.ac.cy' ]]; then
  echo "Binding to domain."
  read -s -p "Enter local user: " localUser
  echo $localUser
  read -s -p "Enter local password: " localPass
  read -s -p "Enter domain user: " domain
  read -s -p "Enter domain password: " domainPass
  
  dsconfigad -add domain -username $domainUser [-computer value] [-force] -password $domainPass [-ou dn] -preferred 'ucy.ac.cy' -localuser $localUser -localpassword $localPass
  #exit 1
fi


# Install Kyocera driver
sudo installer -verbose -pkg Kyocera\ OS\ X\ 10.5+\ build\ 2016.05.15.pkg -target /


# Wake-up/Boot daily at 07:30
sudo pmset repeat wakeorpoweron MTWRFSU 07:30:00

# Set display sleep after 60 minutes, when connected on power adapter
sudo systemsetup -setdisplaysleep 60

# Start screen saver after 5 minutes

# Require password to unlock immediately after screen saver begins.

for home in $(ls /Users | grep -v localadmin | grep -v Shared | grep -v library | grep -v admin)
do
#echo $home
sudo dscl . -delete /Users/$home
rm -rf /Users/$home
done
