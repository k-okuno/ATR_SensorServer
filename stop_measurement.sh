#!/bin/sh

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

DURATION="0.5"

DEVID=${1}

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

LOGNAME=stop-${NOW}-${PORT}-${CNCT}.log


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
# > ./start_sensor <host name> <port>
#############
function stop_sensor()
{
    echo "Time stamp  : " ${NOW}       
    echo "Running     : " ${SCRIPT_NAME}
    echo "Device ID   : " ${DEVID}
    echo "Connetion   : " ${CNCT}
    echo "Port        : " ${PORT}  
    echo "            = <USB=20000>,<BT=10000> + <DEV ID>"
    echo "Log         : " ${LOGNAME}
    echo ""
    echo "Sending 'stop' command."
    ( echo open ${HOST} ${PORT}
      sleep 3
      echo getmemfreesize
      sleep ${DURATION}
      echo getbattstatus
      sleep ${DURATION}
      echo stop
      sleep 1
    ) | telnet #| col -b 2>&1 | tee -a ${LOGNAME}
}


###################
# main
###################
check_args ${@} 2>&1 | tee -a ${LOGNAME}
check_func_rtv
# check_cnct ${HOST} ${PORT} 2>&1 | tee -a ${LOGNAME}
# check_func_rtv

echo "OK. stop measuring..."
stop_sensor ${HOST} ${PORT} | col -b 2>&1 | tee -a ${LOGNAME}
# 本当に計測が開始されたかのチェック,check_cnt.shと同じテク+loopで？
echo "OK! stoped thr "${CNCT} 2>&1 | tee -a ${LOGNAME}
echo "Device ID: " ${DEVID}   2>&1 | tee -a ${LOGNAME}

echo "Saving stop log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
