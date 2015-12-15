#!/bin/bash

DATE=`date +%Y%m%d`
TIME=`date +%H%M_%S`
NOW=${DATE}-${TIME}

HOST="localhost"

PROGNAME=$(basename $0)
SCRIPT_NAME=$(basename $0)

ALL_ARGS=$@

# Default: non-interactive mode
ALL_Y=TRUE
# Default: interactive mode
#ALL_Y=FALSE

# sleep time
DURATION="0.2"

# Default device ID
DEVID="-1"

# Directory/Folder where the script is run.
EXE_DIR=`pwd`


# Set connection means
# CNCT=USB or CNCT=BT
# Defualt is "USB"
CNCT="USB"
#CNCT="BT"

# Data entry # to DL.
# Default: 1
WHICHDATA="1"
#WHICHDATA="2"


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
source ./func_dl_data.sh
source ./func_if_num.sh

#############
# confirmation of clearing all the data by "yes or no"
#############
function yes_or_no_clear_data()
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
# function to clear all the data
# NO going back!
#############
function clear_all_data()
{
    local duration=0.5
    
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
    spawn telnet ${HOST} ${PORT}; sleep 3
    expect \"\r\"      ; sleep ${duration}
    send \"clearmem\r\"
    expect \"\r\"      ; sleep ${duration}
    send \"getmemfreesize\r\"
    expect \"\r\"      ; sleep 1
    send \"\035\r\"
    expect \"telnet\>\"
    send \"quit\r\"
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
    echo "  -i, --interactive-mode"    
    echo "  -c, --connection [bt/usb]"
    echo "  -s, --sleep-time [sec]"
    echo "  -d, --data-entry [1-40]"    
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
        '-i'|'--interactive-mode' )
	    ALL_Y=FALSE
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
	'-d'|'--data-entry' )
	    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "ERROR: $PROGNAME: option requires an argument -- $1" 1>&2
		usage
	    fi
	    if_num ${2} # this works only for "integer"
	    if [ $? -ne 0 ]; then
		echo "ERROR: not Numeric: $1 = [1-40]" 1>&2
		usage
		exit 1
	    else		
		WHICHDATA=${2}
		echo "WHICH_DATA: ${WHICHDATA}"
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
# setting up File name
FILENAME=${PORT}-${NOW}-${WHICHDATA}.csv
LOGNAME=${PORT}-${NOW}-${WHICHDATA}.log
# Directory/Folder to save data and log.
EXP_DIR="./${DATE}_DEV${DEVID}"

##########################
# main
##########################
check_cnct ${HOST} ${PORT} ${ALL_Y} 2>&1 | tee -a ${LOGNAME}
check_func_rtv

#dl_data ${HOST} ${PORT} | col -b 2>&1 | tee -a ${FILENAME}
dl_data-expect ${HOST} ${PORT} ${FILENAME} ${LOGNAME}
echo -n "OK. Copleted timestamp: " `date +%Y%m%d-%H%M_%S` 2>&1 | tee -a ${LOGNAME}
echo "Saving DL data and log to: ${EXP_DIR}/"
check_file_dir ${EXP_DIR}
save_files ${EXP_DIR} ${LOGNAME} ${FILENAME}

#yes_or_no_clear_data
clear_all_data
check_func_rtv
echo ""
echo "OK, sent command to clear ALL the data."

exit 0
