#!/bin/bash

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

PROGNAME=$(basename $0)
HOST="localhost"

ALL_ARGS=$@

# Default sleep time between command while uisng telnet
DURATION="0.2"

# Default device ID
DEVID="-1"

# Set connection means
# Default: BT
CNCT="BT"

#############
# load functions
# to check connection
# to check file dirctory to save data/log.
#############
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
	'-s'|'--sleep-time' )
	    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "ERROR: $PROGNAME: option requires an argument -- $1" 1>&2
		usage
	    fi
	    #if_num ${2} # this works only for "integer"
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
# LOG file name.
LOGNAME=sensor_settings-${NOW}-${PORT}-${CNCT}.log
# Directory/Folder to save data and log.
EXP_DIR="./${DATE}_DEV${DEVID}"
echo "OK. args checked."

#############
# Usage:
# > ./start_sensor <hostname> <port>
#############
function get_sensor_setting()
{
    
    echo "Time stamp  : " ${NOW}       
    echo "Program     : " ${PROGNAME}
    echo "Device ID   : " ${DEVID}
    echo "Port        : " ${PORT}
    echo "Connetion   : " ${CNCT}   
    echo "Log         : " ${LOGNAME}
    echo "Retrieving sensor settings...(it takes 8 sec)"
    echo 

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
    "  #| col -b 2>&1 | tee -a ${LOGNAME}

    return 0
}


###################
# main
###################
echo "Host        : ${HOST}"
echo "Port        : ${PORT}"
echo "Default Conn: BT" 
echo "Connection  : ${CNCT}"
echo
get_sensor_setting ${HOST} ${PORT}  | col -b 2>&1 | tee -a ${LOGNAME}

echo "Saving sensor_setting log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
