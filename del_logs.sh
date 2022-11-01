#!/usr/bin/bash

# removes log files with size greater then 100Mb

find /var/log -size +100M -a -type f 2>/dev/null | xargs rm
