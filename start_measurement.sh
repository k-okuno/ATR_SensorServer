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

LOGNAME=start-${NOW}-${PORT}-${CNCT}.log


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
# to get input yes or no
#############
yes_or_no_while()
{
    while true;do
        echo
        echo "Type 'yes' or 'no'."
        read answer
        case $answer in
            yes)
                echo -e "OK, start in a few seconds.\n"
                return 0
                ;;
            no)
                echo -e "NO.\n"		
                return 1
                ;;
            *)
                echo -e "you need to type 'yes', otherwise taken as 'no'.\n"
		return 1
                ;;
        esac
    done
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
# > ./if_started <host> <port>
# in future
# > ./if_started <host> <port> <key_line>
#############
function if_started()
{
    local host=${1}
    local port=${2}
    local dev_id=$(( ${port} % 10000))
    local tmpfile="tmpfile.txt"
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
	echo "OK. confimred starting measurement."
	echo "OK. Device ID:" ${dev_id}
	return 0
    else
	echo "ERROR: measurement NOT started."
	echo "Device ID:" ${dev_id}
	echo "CHECK 'Device ID' 'Power ON/OFF' 'Connection'  and 'SensorServer.exe'"
#	rm ${tmpfile}
	return 1
    fi
}


#############
# Useage:
# > ./start_sensing <host name> <port>
#############
function start_sensing()
{
    echo "Time stamp  : " ${NOW}       
    echo "Running     : " ${SCRIPT_NAME}
    echo "Device ID   : " ${DEVID}
    echo "Connetion   : " ${CNCT}
    echo "Port        : " ${PORT}  
    echo "            = <USB=20000>,<BT=10000> + <DEV ID>"
    echo "Log         : " ${LOGNAME}
    echo ""
    echo "Sending 'getags', 'getbattstatus', 'clearmem', 'getmemfreesize'"
    echo "then 'start' command."
    
    # telnet
    # timeout -1 ; no timeout
    expect -c "
    set timeout -1
    spawn telnet ${HOST} ${PORT}; sleep 3
    expect \"\r\"      ; sleep ${DURATION}
    send \"getags\r\"
    expect \"\r\"      ; sleep ${DURATION}
    send \"getbattstatus\r\"
    expect \"\r\"      ; sleep ${DURATION}
    send \"clearmem\r\"
    expect \"\r\"      ; sleep ${DURATION}
    send \"getmemfreesize\r\"
    expect \"\r\"      ; sleep ${DURATION}
    send \"start\r\"
    expect \"\r\"      ; sleep 1
    send \"\035\r\"
    expect \"telnet\>\"
    send \"quit\r\"
    "        
    return 0
}


###################
# main
###################
check_args ${@} 2>&1 | tee -a ${LOGNAME}
check_func_rtv
#check_cnct ${HOST} ${PORT} 2>&1 | tee -a ${LOGNAME}
#check_func_rtv

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! WARNNING !!!    !!! WARNNING !!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo 
echo "Memory will be cleared completly!"
echo "OK ? "
###############################################
# Type "yes" to start measuring.
# All data will be cleared prior to the measurement
###############################################
yes_or_no_while 2>&1 | tee -a ${LOGNAME}

if [ ${PIPESTATUS[0]} -eq 0 ] ; then
    while true; do
	start_sensing ${HOST} ${PORT}   | col -b 2>&1 | tee -a ${LOGNAME}
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
else
    echo "DID NOT start measuring."
    rm ${LOGNAME}
    exit 1
fi

echo "Saving start log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
