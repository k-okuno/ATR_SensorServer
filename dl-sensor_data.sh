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

# Default: attempt to clear all memory.
CLEAR_MEM=TRUE

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
# function to clear all the data
# NO going back!
# Usage
# > clear_all_data <host> <port>
#############
function clear_all_data()
{
    local all_y="FALSE"
#    local all_y="TRUE"
    
    local duration=0.5
    local host=${1}
    local port=${2}
    local logname=clear_all_data-${port}-${NOW}.log
    
    echo ""
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!! WARNNING !!!    !!! WARNNING !!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Memory will be cleared completly!"
    echo ""
    echo "NO going back!"
    echo ""
    if [ ${all_y} != "TRUE" ];then
	echo "OK to clear *ALL* the Data?"
	echo -n "Press Enter(Y) or Ctrl-c(No) > "
	read INPUT
    else
	echo "OK, about to clear *ALL* the Data."
    fi    


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
    " | col -b 2>&1 | tee -a ${logname}

    echo "OK. sent command to clear ALL the data."
    check_file_dir ${EXP_DIR}
    save_files ${EXP_DIR} ${logname} 
    return 0
}

##########################
# print usage
##########################
usage() {
    echo
    echo "Usage: $PROGRAM [-y] [-i] [-h] [-m clear/keep] [-d which_data ] [-c bt/usb] <DEVICE_ID> "
    echo "  --debug. not implemented yet."            
    echo "  -h, --help"
    echo "  -y, --force-y"
    echo "  -i, --interactive-mode"
    echo "  -m, --clear-mem [clear/keep]"
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
        '-m'|'--clear-mem' )
	    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "ERROR: $PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
	    fi
	    if [ ${2} = "clear" ]; then
		CLEAR_MEM="TRUE"
	    elif [ ${2} = "keep" ]; then
		CLEAR_MEM="FALSE"
	    else
		echo "ERROR: -m 'celar or keep'."
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
FILENAME=data-${PORT}-${NOW}-${WHICHDATA}.csv
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
if [ ${CLEAR_MEM} = "TRUE" ]; then
    clear_all_data ${HOST} ${PORT}
    check_func_rtv
else
    # never here....
    echo "Memory/Data kept on the device."
fi

exit 0
