#!/bin/sh
 
# Check for root/sudo access
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root or a user with sudo privileges" ; exit 1 ; fi

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# TODO: Set desired computer name
read -p "Enter desired computer name: " computerName
scutil --set ComputerName $computerName
echo "Computer name set to ${computerName}.\n"

# Set auto-restart on freeze
systemsetup -setrestartfreeze on
echo "System set to restart on freeze.\n"

# Set sleep time
systemsetup -setdisplaysleep 60 -setharddisksleep 60 -setcomputersleep 10

# Disable sleep command in Apple Menu
defaults write /Library/Preferences/SystemConfiguration/com.apple.PowerManagement SystemPowerSettings -dict SleepDisabled -bool YES
echo "Disabled sleep command in Apple Menu\n"
# Install Kyocera driver
sudo installer -verbose -pkg requirements/Kyocera\ OS\ X\ 10.9+\ Web\ build\ 2018.10.08.pkg -target /
echo "Printer driver installed.\n"

# Install network printer#
# /Library/Printers/PPDs/Contents/Resources/Kyocera\ TASKalfa\ 4052ci.PPD
/usr/sbin/lpadmin -p PRINT1 -o Option18=HardDisk -o Option19=One -o Option26=True -o Resolution=1200dpi -o auth-info-required=negotiate -o printer-error-policy=abort-job -o printer-is-shared="False" -E -v smb://<print_server>/<print_queue> -P /Library/Printers/PPDs/Contents/Resources/Kyocera\ TASKalfa\ 4052ci.PPD -D "Papercut printer"
echo "Added network printer.\n"

# Wake-up/Boot daily at 07:30
sudo pmset repeat wakeorpoweron MTWRFSU 07:30:00
echo "Computer set to power-on daily at 07:30.\n"

# Set display sleep after 60 minutes, when connected on power adapter
sudo systemsetup -setdisplaysleep 60
echo "Display sleep time set to 60 minutes.\n"


# Create folder (if it does not exist) to store scripts and copy them
mkdir -p /Users/admin/scripts
# Install companion scripts
rm -f /Users/admin/scripts/* && cp scripts/* /Users/admin/scripts/
chmod 744 /Users/admin/scripts/shutdown.sh
chmod 744 /Users/admin/scripts/startup.sh
chmod 755 /Users/admin/scripts/login.sh

# Start screen saver after 5 minutes

# Install all mobileconfig profiles in folder
for filename in profiles/*.mobileconfig; do
	# echo $filename
    /usr/bin/profiles -I -F "$filename"
done

# Allow admin user to execute cron command as sudo w/o password.
cronCommand="scripts/shutdown.sh"
# Do not evaluate the output of grep but rather its return value
# -F option to grep is to prevent it from interpreting regular expression metacharacters
if grep -qF "$cronCommand" /etc/sudoers.d/99_sudo_logout ; then
   echo "Shutdown script already installed in sudoers.\n"
else
   echo "Adding command to sudoers.\n"
   # echo '%admin          ALL=(ALL) NOPASSWD: /Users/admin/scripts/logoutUser.sh' | sudo EDITOR='tee -a' visudo
   
   # Or even better place file in sudoers.d to avoid editing main sudoers file.
   bash -c 'echo "%admin          ALL=(ALL) NOPASSWD: /Users/admin/scripts/shutdown.sh" >> /etc/sudoers.d/99_sudo_logout'
fi

# Install profile clean-up script & plist
rm -f /Library/Preferences/com.apple.HIToolbox.plist && cp requirements/com.apple.HIToolbox.plist /Library/Preferences/com.apple.HIToolbox.plist 
rm -f /Library/LaunchAgents/cy.ac.ucy.library.mac.userstartup.plist && cp requirements/cy.ac.ucy.library.mac.userstartup.plist /Library/LaunchAgents/cy.ac.ucy.library.mac.userstartup.plist 
rm -f /Library/LaunchAgents/com.papercut.client.plist && cp requirements/com.papercut.client.plist /Library/LaunchAgents/com.papercut.client.plist  
rm -f /Library/LaunchDaemons/cy.ac.ucy.library.mac.startup.plist && cp requirements/cy.ac.ucy.library.mac.startup.plist /Library/LaunchDaemons/cy.ac.ucy.library.mac.startup.plist
chmod 644 /Library/LaunchAgents/com.papercut.client.plist /Library/LaunchDaemons/cy.ac.ucy.library.mac.startup.plist /Library/LaunchAgents/cy.ac.ucy.library.mac.userstartup.plist 


# Add cronjob for shutdown procedure (execute at 00:15)
# 15 0 * * * sudo /Users/admin/scripts/shutdown.sh >/dev/null 2>&1 
(crontab -l 2>/dev/null; echo "15 0 * * * sudo /Users/admin/scripts/shutdown.sh >/dev/null 2>&1 ") | crontab - admin

# Caps lock switch lang
# defaults write com.apple.TextInputMenuAgent "NSStatusItem Visible Item-0" -int 0

# Require password immediately after screen saver begins
# defaults write com.apple.screensaver askForPassword -int 1
# defaults write com.apple.screensaver askForPasswordDelay -int 0

# Enable two button mouse (right-click)
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode TwoButton

# Final step
echo "\n\n################################################"
echo "Do not forget to copy PCClient.app to /Applications/PCClient.app"
echo "and chmod 755"
echo "################################################\n\n"
echo "Some settings require a restart.\n"
