#!/bin/bash
#

crontab /borg/scheduler.txt
crond -l2 -f
