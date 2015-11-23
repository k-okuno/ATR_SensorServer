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
    echo "Sending 'getbattstatus', 'clearmem',then 'start' command."
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
yes_or_no_while 2>&1 | tee -a ${LOGNAME}
if [ ${PIPESTATUS[0]} -eq 0 ] ; then
    start_sensor ${HOST} ${PORT} | col -b 2>&1 | tee -a ${LOGNAME}
    # 本当に計測が開始されたかのチェック,check_cnt.shと同じテク+loopで？
    echo "OK! started thr "${CNCT} 2>&1 | tee -a ${LOGNAME}
    echo "Device ID: " ${DEVID}    2>&1 | tee -a ${LOGNAME}
else
    echo "DID NOT start measuring."
    rm ${LOGNAME}
    exit 0
fi

echo "Saving start log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
