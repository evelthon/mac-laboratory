# mac-laboratory
notes and scripts for setting up laboratory macs for many users

## Purpose
Create a mac with the following characteristics:
- Allow login using AD user
- Print through a network Papercut printer
- Do not display welcome wizard on first login
- Shut down mac daily, ignoring any logged-in users
- Clear existing user profiles on boot
- Boot daily @ 07:30
- Shut down daily @ 00:15

## Join AD
```dsconfigad -add domain -username value [-computer value] [-force] [-password value] [-ou dn] [-preferred server] [-localuser value] [-localpassword value]```
