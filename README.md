# Oracle XE backup scripts

This repo contains scripts to perform hot backup of Oracle XE database.


## Installation

### Turning on ARCHIVELOG mode in Oracle XE

You need to enable ARCHIVELOG mode in Oracle so it would archive redo-log files after switching.

To do this do the following:

1. Connect to terminal as oracle user:

        $ sudo su oracle

2. Login to sqlplus:

        $ sqlplus / as sysdba

        SQL*Plus: Release 11.2.0.2.0 Production on Sun Nov 10 13:30:30 2013
        Copyright (c) 1982, 2010, Oracle.  All rights reserved.
        Connected to:
        Oracle Database 11g Express Edition Release 11.2.0.2.0 - Production

3. Check archive log mode

        SQL> archive log list

        Database log mode              No Archive Mode
        Automatic archival             Disabled
        Archive destination            USE_DB_RECOVERY_FILE_DEST
        Oldest online log sequence     90
        Current log sequence           91

4. If you're in No Archive Mode then enable by stopping database and starting it again:

        SQL> shutdown immediate;

        Database closed.
        Database dismounted.
        ORACLE instance shut down.

        SQL> startup mount

        ORACLE instance started.

        Total System Global Area 1071769376 bytes
        Fixed Size                  1339352 bytes
        Variable Size             626295792 bytes
        Database Buffers          435767616 bytes
        Redo Buffers                4981616 bytes
        Database mounted.

5. Enable ARCHIVELOG mode and open database:

        SQL> alter database archivelog;
        Database altered.

        SQL> alter database open;
        Database altered.

        SQL> archive log list;

        Database log mode              Archive Mode
        Automatic archival             Enabled
        Archive destination            USE_DB_RECOVERY_FILE_DEST
        Oldest online log sequence     90
        Next log sequence to archive   91
        Current log sequence           91

6. To display actual location of archived logs use:

        SQL> show parameter recover;

        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- -----------------------------------
        db_recovery_file_dest                string      /u01/app/oracle/fast_recovery_area
        db_recovery_file_dest_size           big integer 10G
        db_unrecoverable_scn_tracking        boolean     TRUE
        recovery_parallelism                 integer     0


### Installation of backup process

We will install the following backup process - weekly to take full snapshot and the rest 6 days - incremental snapshots.

Clone this repository somewhere on a filesystem, I'd do this right into `$HOME` of `oracle` user, `cd` there.

Run (we're still under `oracle` user):

        $ ./backup.sh 0 xe_incr

Here 0 is mode (full snapshot) and `xe_incr` is a tag for our backups. It would start backup process and create logfile at `$HOME/fast_recovery_area/xe_backup.log` and about 1.5G of backups under `$HOME/fast_recovery_area/backupset`. Further backups will be much smaller (depending on your workload of course, but if you're using Oracle XE is shouldn't be high).

Add this lines to crontab file (edit it using `crontab -e`):

        #--------------------------------------------------------------------------------------------------
        #Min     Hour    Day     Month   Weekday Command
        #--------------------------------------------------------------------------------------------------
        0        3       *       *       0       cd /path/to/oracle-xe-backup/folder; ./backup.sh 0 xe_incr
        0        3       *       *       1-6     cd /path/to/oracle-xe-backup/folder; ./backup.sh 1 xe_incr

This one would run full backup each sunday at 03:00 AM and incremental backups from monday to saturday at 03:00 AM.
