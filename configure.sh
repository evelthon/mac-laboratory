#!/bin/sh
 
# Check for root/sudo access
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root or a user with sudo privileges" ; exit 1 ; fi

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# TODO: Set desired computer name
read -s -p "Enter desired computer name: " computerName
scutil --set ComputerName $computerName
echo "Computer name set to ${$computerName}"

# Set auto-restart on freeze
systemsetup -setrestartfreeze on

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

# Install network printer#
# /Library/Printers/PPDs/Contents/Resources/Kyocera\ TASKalfa\ 4052ci.PPD
/usr/sbin/lpadmin -p PRINT1 -o Option18=HardDisk -o Option19=One -o Option26=True -o Resolution=1200dpi -o auth-info-required=negotiate -o printer-error-policy=abort-job -o printer-is-shared="False" -E -v smb://<print_server>/<print_queue> -P /Library/Printers/PPDs/Contents/Resources/Kyocera\ TASKalfa\ 4052ci.PPD -D "Papercut printer"

# Instal Papercut client & install plist


# Wake-up/Boot daily at 07:30
sudo pmset repeat wakeorpoweron MTWRFSU 07:30:00

# Set display sleep after 60 minutes, when connected on power adapter
sudo systemsetup -setdisplaysleep 60


# Create folder to store scripts and copy them
mkdir /Users/admin/scripts
# Install force logout & shutdown
cp scripts/ /Users/admin/scripts
chmod 744 /Users/admin/scripts/logoutUser.sh
chmod 744 /Users/admin/scripts/startup.sh

# Start screen saver after 5 minutes

# Install all mobileconfig profiles in folder
for filename in profiles/*.mobileconfig; do
    /usr/bin/profiles -I -F profiles/$filename
done

# Allow admin user to execute cron command as sudo w/o password.
cronCommand="scripts/logoutUser.sh"
# Do not evaluate the output of grep but rather its return value
# -F option to grep is to prevent it from interpreting regular expression metacharacters
if grep -qF "$cronCommand" /etc/sudoers;then
   echo "Found it"
else
   echo "Adding command to sudoers."
   # echo '%admin          ALL=(ALL) NOPASSWD: /Users/admin/scripts/logoutUser.sh' | sudo EDITOR='tee -a' visudo
   
   # Or even better place file in sudoers.d to avoid editing main sudoers file.
   bash -c 'echo "%admin          ALL=(ALL) NOPASSWD: /Users/admin/scripts/logoutUser.sh" >> /etc/sudoers.d/99_sudo_include_file'
fi

# Install profile clean-up script & plist
cp requirements/com.papercut.client.plist /Library/LaunchAgents/com.papercut.client.plist  
cp requirements/cy.ac.ucy.library.mac.startup.plist /Library/LaunchDaemons/cy.ac.ucy.library.mac.startup.plist
chmod 644 /Library/LaunchAgents/com.papercut.client.plist /Library/LaunchDaemons/cy.ac.ucy.library.mac.startup.plist


# Add cronjob for shutdown procedure (execute at 00:15)
# 15 0 * * * sudo /Users/admin/scripts/logoutUser.sh >/dev/null 2>&1 
(crontab -l 2>/dev/null; echo "15 0 * * * sudo /Users/admin/scripts/logoutUser.sh >/dev/null 2>&1 ") | crontab -


# Final step
echo "Copy PCClient.app to /Applications/PCClient.app and you are done."

