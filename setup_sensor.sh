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

PROGNAME=$(basename $0)
SCRIPT_NAME=$(basename $0)
HOST="localhost"
ALL_ARGS=$@

# sleep time inbetween sending command in "expect+telnet"
# for setting up sensor, 1 sec does not seem to work.
DURATION="2"

# Default device ID
DEVID="-1"

# Default: non-interactive mode.
ALL_Y=TRUE

# Directory/Folder where the script is run.
EXE_DIR=`pwd`

# Set connection means
# BT -> 1, USB -> 2
# Defualt is "BT"
CNCT="BT"
#CNCT="USB"


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
#    SET_AGS="setags 1 0 10"
    SET_AGS="setags 1 0 4"        
    SET_GEO="setgeo 0 0 0"
    SET_PRES="setpres 0 0 0"
    SET_BATT="setbatt 0 0"
    SET_D="setd ${SETD_ARG}"

    echo "Time stamp  : " ${NOW}       
    echo "Program     : " ${SCRIPT_NAME}
    echo "Device ID   : " ${DEVID}
    echo "Port        : " ${PORT}
    echo "Connetion   : " ${CNCT}
    echo "Setup Log   : " ${LOGNAME}
    echo "Start Configuring and Checking. (take a while)"    

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


##########################
# print usage
##########################
usage() {
    echo
    echo "Usage: $PROGRAM [-y] [-h] [-c bt/usb] <DEVICE_ID> "
    echo "  --debug. not implemented yet."            
    echo "  -h, --help"
    echo "  -y, --force-y"    
    echo "  -c, --connection [bt/usb]"
    echo "  -s, --sleep-time [sec]"
    echo
    exit 1
}

###############################
# Check args and Set options
###############################
for OPT in "$@"	   
do
    case "$OPT" in
        '-h'|'--help' )
	    usage
	    exit 1
	    ;;
        '-c'|'--connection' )
	    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "ERROR: $PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
	    fi
	    cnct="$2"
	    if [ ${cnct} = "usb" ]; then
		CNCT="USB"
	    elif [ ${cnct} = "bt" ]; then
		CNCT="BT"
	    else
		echo "ERROR: -c 'bt or usb'."
		usage
	    fi
	    shift 2		
	    ;;
        '-y'|'--force-y' )
	    ALL_Y=TRUE
	    echo "ALL_Y: ${ALL_Y}"
	    shift 1
	    ;;
	'-s'|'--sleep-time' )
	    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "ERROR: $PROGNAME: option requires an argument -- $1" 1>&2
		usage
	    fi
	    if_num ${2} # this works only for "integer"
	    if [ $? -ne 0 ]; then
		echo "ERROR: not Numeric: $1 <= [Integer]" 1>&2
		usage
		exit 1
	    else		
		DURATION=${2}
		echo "sleep time: ${DURATION}"
	    fi
	    shift 2		
	    ;;	
        -*)
	    echo "ERROR: $PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
	    usage
	    exit 1
	    ;;
        *)
	    if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                #param=( ${param[@]} "$1" )
                param+=( "$1" )
		if_num ${param}
		if [ $? -ne 0 ]; then
		    echo "ERROR: not Numeric: $1 <= [Integer]" 1>&2
		    usage
		    exit 1
		else
		    DEVID=${param}
		    echo "DEVID: ${DEVID}"
		    shift 1
		fi
	    fi
	    ;;
    esac
done

if [ -z $param ]; then
    echo "ERROR: $PROGNAME: too few arguments" 1>&2
    usage
    exit 1
fi

COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi		    
PORT=${COM}${DEVID}
# LOG file name
LOGNAME=setup-${PORT}-${CNCT}-${NOW}.log
# Directory/Folder to save data and log.
# 本当は、configファイルに抜き出して、共通化すべき設定。
EXP_DIR="./${DATE}_DEV${DEVID}"

###################
# main
###################
#check_cnct ${HOST} ${PORT} ${ALL_Y} 2>&1 | tee -a ${LOGNAME}
#check_func_rtv

echo "Host        : ${HOST}"
echo "Port        : ${PORT}"
echo "Default Conn: BT" 
echo "Connection  : ${CNCT}"
echo "OK. setting sensor up ...(It takes 10 sec)"
configure_sensor ${HOST} ${PORT}            | col -b 2>&1 | tee -a ${LOGNAME}
# if_configured ${HOST} ${PORT} | col -b 2>&1 | tee -a ${LOGNAME}

echo "OK! compeleted setting up sensor thr" ${CNCT}  2>&1 | tee -a ${LOGNAME}
echo "Device ID:" ${DEVID}                           2>&1 | tee -a ${LOGNAME} 
echo ""

echo "Now, Saving setup log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
