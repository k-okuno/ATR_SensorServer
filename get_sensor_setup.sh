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
DURATION="0.1"

# first ARG is device ID.
DEVID=${1}
#echo "Default DEV ID: ${DEVID}"

# Directory/Folder to save data and log.
# this should be shared with other related function in separate text.
EXP_DIR="./${DATE}_DEV${DEVID}"

# Set connection means
# BT -> 1, USB -> 2
# Default: BT
CNCT="BT"
#CNCT="USB"

# LOG file name.
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


#################################
# function to display usage.
#################################
function usage()
{
    echo "Usage: $PROGNAME [OPTIONS] <Device ID>"
    echo
    echo "Options:"
    echo "  -h, --help"
    echo "  -c, --connection [bt/usb]"
    echo "  -s, --sleep-time [sec]"    
    echo
    exit 1
}



#################################
# this part is a template.
# Usage:
# > ./get_args $@
#################################
function get_args()
{
for OPT in "$@"
do
    case "$OPT" in
        '-h'|'--help' )
            usage
            exit 1
            ;;
        '-c' |'--connection' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1 [bt/usb]" 1>&2
                exit 1		
	    elif [[ "$2" = "bt" ]] || [[ "$2" = "usb" ]]; then
		CNCT="$2"
		echo "CNCT: " ${CNCT}
		param="${PARM_MSG}"
                shift 2		
	    else		
		echo "$PROGNAME: option requires an argument -- $1 [bt/usb]" 1>&2
                exit 1		
            fi	    		
            ;;
        '-s'|'--sleep-time' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1 [sec]" 1>&2
                exit 1		
	    else
		if_num ${2} 
		if [ $? -ne 0 ]; then
		    echo "Not Numeric: $1 [ARG = sec]" 1>&2
		    exit 1
		else
		    DURATION=${2}
		    echo "SLEEP_T: " ${DURATION}
		    param="${PARM_MSG}"
                    shift 2		    
		fi
            fi  
            ;;	
        '--'|'-' )
            shift 1
            param+=( "$@" )
	    echo "DEBUG param 1 : " ${param}
            break
            ;;
        -*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                #param=( ${param[@]} "$1" )
                param+=( "$1" )
		echo "DEBUG param 2 : " ${param}
                shift 1
            fi
            ;;
    esac
DEVID=${1}
echo "in: devid: ${DEVID}"    
done


DEVID=${1}
echo "in2: devid: ${DEVID}"    
if [ -z $param ]; then
    echo "$PROGNAME: too few arguments" 1>&2
    echo "Try '$PROGNAME --help' for more information." 1>&2
    exit 1
fi

DEVID=${1}
echo "out: devid: ${DEVID}"
}



#############
# Useage:
# > ./start_sensor <hostname> <port>
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

    # telnet
    # timeout -1 ; no timeout
    expect -c "
    set timeout -1
    spawn telnet ${HOST} ${PORT}; sleep 3
    expect \"\r\"     ; sleep ${DURATION}
    send \"getd\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"devinfo\r\"; sleep ${DURATION}
    expect \"\r\"     ; sleep ${DURATION}
    send \"getags\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"getgeo\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"getpres\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"getbatt\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"getbattstatus\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"getmemfreesize\r\"
    expect \"\r\"     ; sleep ${DURATION}
    send \"\035\r\"
    expect \"telnet\>\"
    send \"quit\n\"
    "  | col -b 2>&1 | tee -a ${LOGNAME}

    return 0
}


###################
# main
###################
# get_args $@  #2>&1 | tee -a ${LOGNAME}
# echo "out: CNCT: ${CNCT}"
# echo "out2: devid: ${DEVID}"
# exit 0
#check_func_rtv

# assigning 1 or 2 for 1st digit of <port>.
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi
# Port# : <BT=1 or USB=2><DEVID>
PORT=${COM}${DEVID}


check_args ${@} 2>&1 | tee -a ${LOGNAME}
check_func_rtv


echo "host: ${HOST}"
echo "port: ${PORT}"
echo "OK. retrieving sensor settings..."
echo
get_sensor_setting ${HOST} ${PORT}   # | col -b 2>&1 | tee -a ${LOGNAME}

echo "Saving sensor_setting log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
