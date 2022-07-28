#!/bin/bash

for _home in $(grep -E '/bin/(c|tc|p|sc|ba|z|)sh' /etc/passwd | grep -v /var/lib | awk -F ":" '{print $6}' | grep -v /root)
do
    test -e "$_home"/.ssh/authorized_keys && chattr +i "$_home"/.ssh/authorized_keys
done
