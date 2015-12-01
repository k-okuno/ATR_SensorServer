#!/bin/bash
################################
# setup the sensors
# setags 1 0 10 <1ms>, <no to display>, <write to memory, avg of 10>
# setgeo 0 0 0
# setpres 0 0 0
# setbatt 0 0
# setbuzvol 2
################################

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

# sleep time inbetween sending command in "expect+telnet"
# for setting up sensor, 1sec seems to work.
DURATION="1"

# device ID
DEVID=${1}

# Directory/Folder where the script is run.
EXE_DIR=`pwd`

# Directory/Folder to save data and log.
# 本当は、configファイルに抜き出して、共通化すべき設定。
EXP_DIR="./${DATE}_DEV${DEVID}"

# Set connection means
# BT -> 1, USB -> 2
#CNCT="USB"
CNCT="BT"
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi

# Port# : <BT=1 or USB=2><DEVID>
PORT=${COM}${DEVID}

LOGNAME=setup-${PORT}-${CNCT}-${NOW}.log


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


#############
# Useage:
# > ./if_configured <hostname> <port>
#############
function if_configured()
{
    echo "Checking configuration... "
 
    # apply and modify the 'func_check_cnct'?

    return 0
}


#############
# Useage:
# > ./configure_sensor <host name> <port>
#############
function configure_sensor()
{
    SETD_ARG=`date +%y%m%d%H%M%S000`

    ########    ########
    # 設定の説明が必要
    #
    # 
    ########    ########
#    SET_AGS="setags 1 0 1"
#    SET_AGS="setags 10 0 1"
    SET_AGS="setags 1 0 10"    
    SET_GEO="setgeo 0 0 0"
    SET_PRES="setpres 0 0 0"
    SET_BATT="setbatt 0 0"
    SET_D="setd ${SETD_ARG}"

    echo "Time stamp  : " ${NOW}       
    echo "Running     : " ${SCRIPT_NAME}
    echo "Device ID   : " ${DEVID}
    echo "Connetion   : " ${CNCT}
    echo "Port        : " ${PORT}  
    echo "Setup Log   : " ${LOGNAME}
    echo "Start Configuring and Checking."    

    # telnet
    # timeout -1 ; no timeout
    expect -c "
    set timeout -1
    spawn telnet ${HOST} ${PORT}; sleep 3
    expect \"\r\"     ; sleep ${DURATION}
    send \"${SET_D}\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"${SET_AGS}\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"${SET_GEO}\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"${SET_PRES}\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"${SET_BATT}\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"getd\r\"
    expect \"\r\"     ; sleep 0.1
    send \"getags\r\"
    expect \"\r\"     ; sleep 0.1
    send \"getgeo\r\"
    expect \"\r\"     ; sleep 0.1
    send \"getpres\r\"
    expect \"\r\"     ; sleep 0.1
    send \"memcount\r\"
    expect \"\r\"     ; sleep 0.1
    send \"getmemfreesize\r\"
    expect \"\r\"     ; sleep 0.1
    send \"getbattstatus\r\"
    expect \"\r\"     ; sleep 0.1
    send \"devinfo\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"\035\r\"
    expect \"telnet\>\"
    send \"quit\n\"
    " 
    return 0
}


###################
# main
###################
check_args ${@} 2>&1 | tee -a ${LOGNAME}
check_func_rtv
check_cnct ${HOST} ${PORT} 2>&1 | tee -a ${LOGNAME}
check_func_rtv

echo "OK. setting sensor up ...(It takes 10 sec)"
configure_sensor ${HOST} ${PORT}            | col -b 2>&1 | tee -a ${LOGNAME}
# if_configured ${HOST} ${PORT} | col -b 2>&1 | tee -a ${LOGNAME}

echo "OK! compeleted setting up sensor thr" ${CNCT}  2>&1 | tee -a ${LOGNAME}
echo "Device ID:" ${DEVID}                           2>&1 | tee -a ${LOGNAME} 
echo ""

echo "Now, Saving setup log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
