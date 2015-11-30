#!/bin/bash


PROGNAME=$(basename $0)
VERSION="1.0"
PARM_MSG="OK"

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

ALL_ARGS=$@

# duration to sleep between command while uisng telnet
DURATION="0.5"

# first ARG is device ID.
DEVID=${1}

# Directory/Folder to save data and log.
# this should be shared with other related function in separate text.
EXP_DIR="./${DATE}_DEV${DEVID}"

# Set connection means
# BT -> 1, USB -> 2
#CNCT="USB"
CNCT="BT"

# need to go after functino get_args()............
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi

# Port# : <BT=1 or USB=2><DEVID>
PORT=${COM}${DEVID}

LOGNAME=sensor_settings-${NOW}-${PORT}-${CNCT}.log



#############
# load functions
# to check connection
# to check file dirctory to save data/log.
#############
source ./func_cnct_check.sh
source ./func_save_data-log.sh
source ./func_if_num.sh

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
# Useage:
# > ./start_sensor <host name> <port>
#############
function get_sensor_setting()
{
    echo "Time stamp  : " ${NOW}       
    echo "Running     : " ${PROGNAME}
    echo "Device ID   : " ${DEVID}
    echo "Connetion   : " ${CNCT}
    echo "Port        : " ${PORT}  
    echo "Log         : " ${LOGNAME}

    echo "Sensor settings:"
    echo ""

    # telnet
    # timeout -1 ; no timeout
    expect -c "
    set timeout -1
    spawn telnet ${hostname} ${port}; sleep 1
    expect \"\r\"
    send \"echo getd\"
    expect \"\r\"
    send \"echo devinfo\"
    expect \"\r\"
    send \"echo getags\"
    expect \"\r\"
    send \"echo getgeo\"
    expect \"\r\"
    send \"echo getpres\"
    expect \"\r\"
    send \"echo getbatt\"
    expect \"\r\"
    send \"echo getbattinfo\"
    expect \"\r\"
    send \"echo getbattstatus\"
    expect \"\r\"
    send \"echo getmemfreesize\"
    expect \"\r\"
    send \"\035\r\"
    expect \"telnet\>\"
    send \"quit\n\"
    " # | col -b 2>&1 | tee -a ${LOGNAME}

    return 0
}


###################
# main
###################
check_args ${@} 2>&1 | tee -a ${LOGNAME}
check_func_rtv

echo "OK. retrieving sensor settings..."
get_sensor_setting ${HOST} ${PORT}    | col -b 2>&1 | tee -a ${LOGNAME}

echo "Saving sensor_setting log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
