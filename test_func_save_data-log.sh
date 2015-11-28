#!/bin/bash

DATE=`date +%Y%m%d`T

IME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

SCRIPT_NAME=${0}
ALL_ARGS=$@

#DEVID="1691"
DEVID=${1}

# Directory/Folder where the script is run.
EXE_DIR=`pwd`

# Directory/Folder to save data and log.
EXP_DIR="./temp_${DATE}_DEV${DEVID}"


# Set connection means
# CNCT=USB or CNCT=BT
CNCT="USB"
#CNCT="BT"
# COM: BT -> 1, USB -> 2
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi

# Port# : <BT=1 or USB=2><DEVID>
PORT=${COM}${DEVID}

# File name
FILENAME=${PORT}-${NOW}.txt
LOGNAME=${PORT}-${NOW}.log

check_func_rtv()
{
    if [ ${PIPESTATUS[0]} -ne 0 ] ; then
	echo "ERROR: error retuned from the function"
	exit 1
    fi
}

# load functions to check dir, save data/log.
source ./func_save_data-log.sh

# creat dummy files
touch ${FILENAME}
touch ${LOGNAME}
touch temp.txt


echo "Saving DL data and log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
check_func_rtv
save_files ${EXP_DIR} ${LOGNAME} ${FILENAME} temp.txt
check_func_rtv
