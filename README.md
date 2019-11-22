# mac-laboratory
notes and scripts for setting up laboratory macs for many users. This is a work in progress.
![image1](./images/Mac_lab.png)


##### License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)


## Purpose
Create a mac with the following characteristics:
- Set desired computer name
- Restart on freeze
- Disable sleep command in Apple Menu
- Allow login using AD user
- Print through a network Papercut printer
- Do not display welcome wizards on first login
- Shut down mac daily, ignoring any logged-in users
- Clear existing user profiles on boot
- Boot daily @ 07:30
- Shut down daily @ 00:15

![image3](./images/example.gif)

## Assumptions
- The local administrator user is ```admin```
- You can add and/or remove mobileconfig profiles as you see fit.

## Execution
1. Clone or download repository
2. Edit ```configure.sh``` and set you desired print server and print queue ```smb://<print_server>/<print_queue>```
3. Edit profiles/activeDirectoryPayload.mobileconfig and replace ```YOUR_DOMAIN```, ```YOUR_NETWORK_USERNAME```,  ```YOUR_NETWORK_USERNAME``` and ```YOUR_ORG_OU```. Your AD administrator will provide you with these information. Note: YOUR_DOMAIN requires the server's fqdn.
4. Execute with ```sudo ./configure.sh```

A confirmation will pop-up during execution about Terminal trying to administer your computer. This is expected. Click OK.

![image1](./images/Terminal_admin.png)
