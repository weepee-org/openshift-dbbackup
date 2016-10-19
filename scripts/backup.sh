#!/bin/bash

function backupDB {

    # move to backup folder
    cd /data/backup;

    # dump DB
    if [[ $DB_TYPE -eq 'MYSQL' ]]
    then
        MYSQL_PWD=$DB_PASSWORD mysqldump -u $DB_USER -h $MYSQL_SERVICE_HOST $DB_NAME | gzip -c > $(date +%Y-%m-%d-%H.%M.%S).sql.gz;
    else
        PGPASSWORD=$DB_PASSWORD pg_dump -h $POSTGRESQL_SERVICE_HOST -Fc $DB_NAME > $(date +%Y-%m-%d-%H.%M.%S).dump
    fi

    #count files
    NMBFILES=$(ls | wc -l);

    #delete oldest backup file
    if [[ $NMBFILES > 1 ]]
    then
        rm "$(ls -t | tail -1)";
    fi

    echo "`date`: Took DB backup"
}

function checkTimeAndBackupIfMatched {
    CUR_HOUR=$(date +"%H");
    CUR_MIN=$(date +"%M");

    #split time in array
    set -- "$TIME";
    IFS=":"; declare -a REQUESTED_TIME=($*);

    if [[ ${REQUESTED_TIME[0]} -eq CUR_HOUR && ${REQUESTED_TIME[1]} -eq CUR_MIN ]]
    then
        backupDB;
    fi

    sleep 1m;
}

function backupAndSetSleep {
    backupDB;
    sleep "$TIME"m;
}

# cron stuf
while true
do
    if [[ $DAILY_BACKUP == 1 ]]
    then
        checkTimeAndBackupIfMatched;
    else
        backupAndSetSleep;
    fi
done