#!/bin/sh
# 2015/11/19
##############
# Useage:
# > ./test_func_cnct_check.sh <device id>
##############
PROGNAME=$(basename $0)
SCRIPT_NAME=$(basename $0)

HOST="localhost"
ALL_ARGS=$@

# Default device ID
DEVID="-1"

# Default: interactive mode.
ALL_Y=FALSE

# Set connection means
# BT -> 1, USB -> 2
CNCT="USB"
#CNCT="BT"

# only for local use
TMPLOGNAME=tmplog.txt


#############
# function to test
#############
source ./func_cnct_check.sh
source ./func_if_num.sh

#############
# check return value of function.
#############
check_func_rtv()
{
    if [ ${PIPESTATUS[0]} -ne 0 ] ; then
	exit 1
    fi
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

#############
# main
#############

check_cnct ${HOST} ${PORT} ${ALL_Y}| tee -a ${TMPLOGNAME}
#check_cnct -y ${HOST} ${PORT} | tee -a ${TMPLOGNAME}
check_func_rtv

exit 0

