#!/bin/bash
################################
# setup the sensors
# setags 1 0 1 <1ms>, <no to display>, <write to memory>
# setgeo 0 0 0
# setpres 0 0 0
# setbatt 0 0
# setbuzvol 2
################################
# h
################################

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

#DURATION="0.5"
DURATION="1.0"

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
    echo "            = <USB=20000>,<BT=10000> + <DEV ID>"
    echo "Setup Log   : " ${LOGNAME}
    echo ""
    echo "Commands to send: (in order)"
    echo "${SET_D}"
    echo "${SET_AGS}"
    echo "${SET_GEO}"
    echo "${SET_PRES}"
    echo "${SET_BATT}"
    echo "memcount"
    echo "getmemfreesize"
    echo "getbattstatus"
    echo "getd"
    echo "devinfo"
    echo ""
    echo "Start Configuring and Checking."
    ( echo open ${HOST} ${PORT}
      sleep 3
      echo ${SET_D}
      sleep ${DURATION}
      echo ${SET_AGS}
      sleep ${DURATION}
      echo ${SET_GEO}
      sleep ${DURATION}
      echo ${SET_PRES}
      sleep ${DURATION}
      echo ${SET_BATT}
      sleep ${DURATION}
      echo getd
      sleep ${DURATION}
      echo getags
      sleep ${DURATION}
      echo getgeo
      sleep ${DURATION}
      echo getpres
      sleep ${DURATION}      
      echo memcount
      sleep ${DURATION}
      echo getmemfreesize
      sleep ${DURATION}
      echo getbattstatus
      sleep ${DURATION}
      echo devinfo
      sleep ${DURATION}
    ) | telnet #| col -b 2>&1 | tee -a ${LOGNAME}
}


###################
# main
###################
check_args ${@} 2>&1 | tee -a ${LOGNAME}
check_func_rtv
check_cnct ${HOST} ${PORT} 2>&1 | tee -a ${LOGNAME}
check_func_rtv

echo "OK. ready for the next step...(It takes 8 sec)"
configure_sensor ${HOST} ${PORT}  | col -b 2>&1 | tee -a ${LOGNAME}

# if_configured ${HOST} ${PORT} | col -b 2>&1 | tee -a ${LOGNAME}

echo "OK! compeleted setup using" ${CNCT}  2>&1 | tee -a ${LOGNAME}
echo "Device ID:" ${DEVID}                 2>&1 | tee -a ${LOGNAME} 
echo ""

echo "Now, Saving setup log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
