#!/bin/sh

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

# sleep time
DURATION="0.5"

#DEVID="1691"
DEVID=${1}

# Directory/Folder where the script is run.
EXE_DIR=`pwd`

# Directory/Folder to save data and log.
EXP_DIR="./${DATE}_DEV${DEVID}"

# DL time; sleep time to complete downloading data.
# USB w/o tee : 2 min per connection.
# USB w/  tee : 3 min per connection.
# TB w/, w/o tee : 7-15 min (900sec) per 1-4 connection.
#DLTIME="180" # for USB
DLTIME="120" # for BT

# Set connection means
# CNCT=USB or CNCT=BT
#CNCT="USB"
CNCT="BT"
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
dl_data ${HOST} ${PORT} ${FILENAME} ${LOGNAME}
echo -n "OK. Copleted time: " `date +%Y%m%d-%H%M_%S` 2>&1 | tee -a ${LOGNAME}
echo ""
echo "Saving DL data and log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} ${FILENAME}

#if [ $? -ne 0 ]; then echo "ERROR: failed to creat dir ${EXP_DIR}"; fi
#if [ $? -ne 0 ]; then echo "ERROR: failed to save data ${LOGNAME} and ${FILENAME}"; fi
