#!/bin/bash

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

DEVID=${1}
SCRIPT_NAME=${0}

# sleep time
DURATION="0.5"
# DL time to wait (sleep)
DLTIME="180" # for USB

WHICHDATA="1"


# Directory/Folder to save data and log.
EXP_DIR="./temp_${DATE}_DEV${DEVID}"

# Set connection means
# BT -> 1, USB -> 2
CNCT="USB"
#CNCT="BT"
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi

# Port# : <BT=1 or USB=2><DEVID>
PORT=${COM}${DEVID}


# only for local use
FILENAME=${PORT}-${NOW}-${WHICHDATA}.txt
LOGNAME=${PORT}-${NOW}-${WHICHDATA}.log

#############
# check return value of function.
#############
check_func_rtv()
{
if [ ${PIPESTATUS[0]} -ne 0 ] ; then
    exit 1
fi
}

#############
# function to test
#############
source ./func_dl_data.sh

#############
# load functions
# to check connection
# to check file dirctory to save data/log.
#############
#source ./func_cnct_check.sh
source ./func_save_data-log.sh


#############
# main
#############
echo "start $0"
# check_args ${@} 2>&1 | tee -a ${LOGNAME}
# check_func_rtv
# check_cnct ${HOST} ${PORT} | tee -a ${LOGNAME}
# check_func_rtv

#dl_data ${HOST} ${PORT} | col -b 2>&1 | tee -a ${FILENAME}
dl_data ${HOST} ${PORT} ${FILENAME} ${LOGNAME}


echo "OK! Completed DL from DEV" ${DEVID} "thr" ${CNCT} 2>&1 | tee -a ${LOGNAME}
#echo "OK. cd ../" 2>&1 | tee -a ${LOGNAME}
echo -n "Copleted time: " `date +%Y%m%d-%H%M_%S` 2>&1 | tee -a ${LOGNAME}
#date +%Y%m%d-%H%M_%S 2>&1 | tee -a ${LOGNAME}

echo "Saving DL data and log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
check_func_rtv
save_files ${EXP_DIR} ${LOGNAME} ${FILENAME}
check_func_rtv

exit 0

