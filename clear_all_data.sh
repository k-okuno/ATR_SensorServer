#!/bin/bash

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

PROGNAME=$(basename $0)
SCRIPT_NAME=$(basename $0)

# Default device ID
DEVID="-1"

# Directory/Folder where the script is run.
EXE_DIR=`pwd`

# default sleep time
DURATION="1"

# Set connection means
# CNCT=USB or CNCT=BT
# Defualt is "USB"
CNCT="USB"
#CNCT="BT"


#############
# load functions
#############
source ./func_if_num.sh
source ./func_save_data-log.sh

##########################
# print usage
##########################
usage() {
    echo
    echo "Usage: $PROGRAM [-y] [-h] [-c bt/usb] <DEVICE_ID> "
    echo "  --debug. not implemented yet."            
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


# setting up port.
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi		    
PORT=${COM}${DEVID}
# setting up log file name
LOGNAME=clear_all_data-${PORT}-${NOW}.log
# Directory/Folder to save data and log.
EXP_DIR="./${DATE}_DEV${DEVID}"


########################
# function to clear all data
# Usage
# > clear_all_data.sh <host> <port> <sleep-time>
########################
function clear_all_data()
{
    local host=${1}
    local port=${2}
    local duration=${3}
    
    echo ""
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!! WARNNING !!!    !!! WARNNING !!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Memory will be cleared completly!"
    echo ""
    echo "NO going back!"
    echo ""
    echo "OK to clear *ALL* the Data?"
    echo -n "Press Enter(Y) or Ctrl-c(No) > "
    read INPUT

    # telnet
    # timeout -1 ; no timeout
    expect -c "
    set timeout -1
    spawn telnet ${host} ${port}; sleep 3
    expect \"\r\"      ; sleep ${duration}
    send \"clearmem\r\"
    expect \"\r\"      ; sleep ${duration}
    send \"getmemfreesize\r\"
    expect \"\r\"      ; sleep 1
    send \"\035\r\"
    expect \"telnet\>\"
    send \"quit\r\"
    " | col -b 2>&1 | tee -a ${LOGNAME}
    return 0
}


###############
# main
###############
clear_all_data ${HOST} ${PORT} ${DURATION} 
echo "OK, sent clear all data comnand."
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} 
exit 0
