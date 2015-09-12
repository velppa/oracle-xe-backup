#!/bin/bash
#!/bin/bash
. /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh
rman CMDFILE=backup_updated.ctl APPEND LOG=$HOME/fast_recovery_area/xe_backup.log
