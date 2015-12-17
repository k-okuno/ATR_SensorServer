#!/bin/bash

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}


HOST="localhost"
SCRIPT_NAME=${0}
ALL_ARGS=$@

# for start measuring, 0.5 seems to work.
DURATION="0.5"

# DEVID as the arg.
DEVID=${1}

# Directory/Folder to save data and log.
# this should be shared with other fucntion with an external config file.
EXP_DIR="./${DATE}_DEV${DEVID}"

# Set connection means
# BT -> 1, USB -> 2
#CNCT="USB"
CNCT="BT"
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi

# Port# : <BT=1 or USB=2><DEVID>
PORT=${COM}${DEVID}

LOGNAME=if_started-${NOW}-${PORT}-${CNCT}.log


#############
# load functions
# to check file dirctory to save data/log.
#############
source ./func_save_data-log.sh

#############
# Useage:
# > ./if_started <host> <port>
# in future
# > ./if_started <host> <port> <key_line>
#############
function if_started()
{
    local host=${1}
    local port=${2}
    local dev_id=$(( ${port} % 10000))
    local tmpfile="tmpfile.log"
    local status=-1
    local key_line=7

    echo "Confirming if measurment stared ..."
    # telnet
    # timeout -1 ; no timeout
    expect -c "
    set timeout -1
    spawn telnet ${HOST} ${PORT}; sleep 3
    expect \"\r\"     ; sleep ${DURATION}
    send \"status\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"\035\r\"
    expect \"telnet\>\"
    send \"quit\r\"
    " | col -b 2>&1 | tee ${tmpfile}

    # ( echo open ${host} ${port}
    #   sleep 3; echo "status"
    #   sleep 1
    # ) | telnet | col -b 2>&1 | tee ${tmpfile}
        
    if [ ! -f ${tmpfile} ] ; then
	echo "ERROR: " ${tmpfile} "does not exist." 
	return 1
    else
	local ct=1
	while read line; do
	    if [ ${ct} -eq ${key_line} ]; then
		status=${line} # read 'key_line' as 'status'
		break
	    fi
	    ct=$((ct + 1))
	done < ${tmpfile}
    fi

    if [ ${status} -eq 3 ]; then
	echo "status: ${status}"
	echo "OK. confimred starting measurement."
	echo "OK. Device ID:" ${dev_id}
	rm ${tmpfile}	
	return 0
    else
	echo "ERROR: measurement NOT started."
	echo "Device ID:" ${dev_id}
	echo "CHECK 'Device ID' 'Power ON/OFF' 'Connection'  and 'SensorServer.exe'"
#	rm ${tmpfile}
	return 1
    fi
}



####################
# main
####################

while true; do
    if_started ${HOST} ${PORT}               2>&1 | tee -a ${LOGNAME}
    if [ ${PIPESTATUS[0]} -eq 0 ] ; then
	echo "OK! started thr "${CNCT}       2>&1 | tee -a ${LOGNAME}
	break 
    else
	echo "NOT started!"                  2>&1 | tee -a ${LOGNAME}
	echo "Re-trying ...(in 3 sec)"       2>&1 | tee -a ${LOGNAME}
	sleep 3
    fi
done

    # echo "DID NOT start measuring."
    # rm ${LOGNAME}
    # exit 1


echo "Saving start log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
