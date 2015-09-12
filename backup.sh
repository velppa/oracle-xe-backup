#!/bin/bash
. /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh
level=$1
tag=$2
rman CMDFILE=backup.ctl USING $level $tag APPEND LOG $HOME/fast_recovery_area/xe_backup.log
