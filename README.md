# mac-laboratory
notes and scripts for setting up laboratory macs for many users. This is a work in progress.



## Purpose
Create a mac with the following characteristics:
- Allow login using AD user
- Print through a network Papercut printer
- Do not display welcome wizards on first login
- Shut down mac daily, ignoring any logged-in users
- Clear existing user profiles on boot
- Boot daily @ 07:30
- Shut down daily @ 00:15

## Assumptions
- The local administrator user is ```admin```

## Execution
1. Clone or download repository
2. Edit ```configure.sh``` and set you desired print server and print queue ```smb://<print_server>/<print_queue>```
3. Edit profiles/activeDirectoryPayload.mobileconfig and replace ```YOUR_DOMAIN```, ```YOUR_NETWORK_USERNAME```,  ```YOUR_NETWORK_USERNAME``` and ```YOUR_ORG_OU```. Your AD administrator will provide you with these information.
4. Execute with ```sudo ./configure.sh```
