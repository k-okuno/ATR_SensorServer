#!/bin/bash

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

DURATION="0.5"

DEVID=${1}

# Directory/Folder to save data and log.
# this should be shared with other related function in separate text.
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
# > ./if_stopped <host> <port>
#############
function if_stopped()
{
    local host=${1}
    local port=${2}
    local dev_id=$(( ${port} % 10000))
    local tmpfile="tmpfile.txt"
    local status=-1
    local bt_no_measurement=2

    echo "Confirming if measurment stopped ..."
    ( echo open ${host} ${port}
      sleep 3; echo "status"
      sleep 1
    ) | telnet | col -b 2>&1 | tee ${tmpfile}
    
    if [ ! -f ${tmpfile} ] ; then
	echo "ERROR: " ${tmpfile} "does not exist." 
	return 1
    else
	local ct=1
	while read line; do
	    if [ ${ct} -eq 4 ]; then
		status=${line}
		break
	    fi
	    ct=$((ct + 1))
	done < ${tmpfile}
    fi

    if [ ${status} -eq ${bt_no_measurement} ]; then
	echo "OK. confimred stopped measurement."
	echo "OK. Device ID:" ${dev_id}
	rm ${tmpfile}	
	return 0
    else
	echo "ERROR: measurement NOT stopped."
	echo "Device ID:" ${dev_id}
	echo "CHECK 'Device ID' 'Power ON/OFF' 'Connection'  and 'SensorServer.exe'"
	rm ${tmpfile}
	return 1
    fi
}


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

echo "OK. stopping measuring ..."

while true; do
    stop_sensor ${HOST} ${PORT}    | col -b 2>&1 | tee -a ${LOGNAME}
    if_stopped  ${HOST} ${PORT}             2>&1 | tee -a ${LOGNAME}
    if [ ${PIPESTATUS[0]} -eq 0 ] ; then
	echo "OK! stopped thr "${CNCT}      2>&1 | tee -a ${LOGNAME}
	echo "Device ID: " ${DEVID}         2>&1 | tee -a ${LOGNAME}	
	break 
    else
	echo "NOT stopped!"                 2>&1 | tee -a ${LOGNAME}
	echo "Re-trying ...(in 3 sec)"      2>&1 | tee -a ${LOGNAME}
	sleep 3
    fi
done 


echo "Saving stop log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
