#!/bin/sh

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

DURATION="0.5"

# specific <key word> for checking a log
KEY="sens start"

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
# > ./if_cmd_exec <hostname> <port> <log file> <key word>
#############
function if_cmd_exec()
{
    ##########################################
    # TMP #
    echo "function will be ready soon..."
    exit 1
    ##########################################

    
    local host=${1}
    local port=${2}
    local logfile=${3}
    local dev_id=$(( ${port} % 10000))

    local key=${$}     
    local line_num="8"
    
    echo "Confirming if command was exectued correctly ..." 
    echo ""

    ct=1
    MSG=-1    
    while read line; do
	if [ ${ct} -eq ${line_num} ]; then
	    MSG=${line}
	    break
	fi
	ct=$((ct + 1))
    done < ${logfile}

    if [ ${MSG} = ${KEY} ]; then
	echo ""
	echo "OK. measurement started"
	echo "OK. Port     :" ${port}
	echo "OK. Device ID:" ${dev_id}
	return 0    
    else
	echo ""
	echo "ERROR: NOT started "
	echo "Port     :" ${port}
	echo "Device ID:" ${dev_id}
	echo ""
	echo "CHECK 'Device ID' 'Power ON/OFF' 'Connection'  and 'SensorServer.exe'"
#	echo "then Re-run the program!"
	echo ""
	return 1
    fi

    echo "OK... success if_cmd_exec()"
    return 0    
}

#############
# Useage:
# > ./start_sensor <host name> <port>
#############
function start_sensor()
{
    echo "Time stamp  : " ${NOW}       
    echo "Running     : " ${SCRIPT_NAME}
    echo "Device ID   : " ${DEVID}
    echo "Connetion   : " ${CNCT}
    echo "Port        : " ${PORT}  
    echo "            = <USB=20000>,<BT=10000> + <DEV ID>"
    echo "Log         : " ${LOGNAME}
    echo ""
    echo "Sending 'getbattstatus', 'clearmem', 'getmemfreesize',then 'start' command."
    ( echo open ${HOST} ${PORT}
      sleep 3
      echo getbattstatus
      sleep ${DURATION}
      echo clearmem
      sleep ${DURATION}
      echo getmemfreesize
      sleep ${DURATION}
      echo start
      sleep 1
    ) | telnet #| col -b 2>&1 | tee -a ${LOGNAME}
}


###################
# main
###################
check_args ${@} 2>&1 | tee -a ${LOGNAME}
check_func_rtv

# no need of this?
check_cnct ${HOST} ${PORT} 2>&1 | tee -a ${LOGNAME}
check_func_rtv

echo "OK. ready to start measuring..."
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! WARNNING !!!    !!! WARNNING !!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "Memory will be cleared completly!"
echo ""

echo "OK? (yes/no). (start in a few seconds)"

# Type "yes" to start measuring.
# All data will be cleared prior to the measurement
yes_or_no_while 2>&1 | tee -a ${LOGNAME}

if [ ${PIPESTATUS[0]} -eq 0 ] ; then
    #NOT_STARTED="TRUE"
    while true; do
	start_sensor ${HOST} ${PORT}         | col -b 2>&1 | tee -a ${LOGNAME}    
	
	if_cmd_exec ${HOST} ${PORT} ${LOGNAME} ${KEY} 2>&1 | tee -a ${LOGNAME}
	check_func_rtv    
	if [ ${PIPESTATUS[0]} -eq 0 ] ; then
	    echo "OK! started thr "${CNCT}            2>&1 | tee -a ${LOGNAME}
	    echo "Device ID: " ${DEVID}               2>&1 | tee -a ${LOGNAME}
	    return 0 #this will get out of the loop?
	else
	    echo "NOT started!"                       2>&1 | tee -a ${LOGNAME}
	    echo "Re-trying...."                      2>&1 | tee -a ${LOGNAME}
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
