#!/bin/bash

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

# sleep time
DURATION="0.2"

#DEVID="1691"
DEVID=${1}

# Directory/Folder where the script is run.
EXE_DIR=`pwd`

# Directory/Folder to save data and log.
EXP_DIR="./${DATE}_DEV${DEVID}"

# Set connection means
# CNCT=USB or CNCT=BT
CNCT="USB"
#CNCT="BT"

# COM: BT -> 1, USB -> 2
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi

# Port# : <BT=1 or USB=2><DEVID>
PORT=${COM}${DEVID}

# Data entry # to DL.
WHICHDATA="1"
#WHICHDATA="2"

# File name
FILENAME=${PORT}-${NOW}-${WHICHDATA}.csv
LOGNAME=${PORT}-${NOW}-${WHICHDATA}.log


#############
# function to check return value of a function.
#############
check_func_rtv()
{
    if [ ${PIPESTATUS[0]} -ne 0 ] ; then
	echo "ERROR: error retuned from the function"
	rm ${LOGNAME}
	exit 1
    fi
}


#############
# load functions
# to check connection
# to check file dirctory to save data/log.
#############
source ./func_cnct_check.sh
source ./func_save_data-log.sh
source ./func_dl_data.sh


##########################
# main
##########################
check_args ${@} 2>&1 | tee -a ${LOGNAME}
check_func_rtv

check_cnct ${HOST} ${PORT} | tee -a ${LOGNAME}
check_func_rtv

#dl_data ${HOST} ${PORT} | col -b 2>&1 | tee -a ${FILENAME}
dl_data-expect ${HOST} ${PORT} ${FILENAME} ${LOGNAME}
echo -n "OK. Copleted timestamp: " `date +%Y%m%d-%H%M_%S` 2>&1 | tee -a ${LOGNAME}
echo "Saving DL data and log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} ${FILENAME}

exit 0
