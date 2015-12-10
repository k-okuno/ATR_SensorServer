#!/bin/bash

PROGNAME=$(basename $0)
VERSION="1.0"

PARM_MSG="OK"


#################################
# load functions from lib
#################################
source ./func_if_num.sh



#################################
# function to display usage.
#################################
function usage()
{
    echo "Usage: $PROGNAME [OPTIONS] FILE"
#    echo "  This script is ~."
    echo "Options:"
    echo "  --debug"            
    echo "  -h, --help"
    echo "  -y, --force-y"    
    echo "  -c, --connection [bt/usb]"
    echo "  -s, --sleep-time [sec]"    
    echo
    exit 1
}




#################################
# Usage:
# > ./get_args $@
#################################
function get_args()
{
    OPT=`getopt -o ab:c --long long-a,  long-b:,long-c -- "$@"`
    if [ $? != 0 ] ; then
	exit 1
    fi
    eval set -- "$OPT"

    while true
    do
	case "$1" in
	    -a | --long-a)
		# -a のときの処理
		shift
		;;
	    -b | --long-b)
		# -b のときの処理
		shift 2
		;;
	    -c | --long-c)
		# -c のときの処理
		shift
		;;
	    --)
		shift
		break
		;;
	    *)
		echo "Internal error!" 1>&2
		exit 1
		;;
	esac
    done
}

#################################
# Usage:
# > ./get_args $@
#################################
function get_args_1()
{
for OPT in "$@"
do
    case "$OPT" in
        '-h'|'--help' )
            usage
            exit 1
            ;;
        '--version' )
            echo $VERSION
            exit 1
            ;;
        '-y'|'--all-y' )
	    ALL_Y="TRUE"
	    echo "ALL_Y: " ${ALL_Y}
	    param="something"		
	    shift 
            ;;
        '--debug' )
	    DEBUG="TRUE"
	    echo "DEBUG: " ${DEBUG}
	    param="${PARM_MSG}"		
	    shift 1
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
        '-t'|'--dl-time' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1 [sec]" 1>&2
                exit 1		
	    else
		if_num ${2} 
		if [ $? -ne 0 ]; then
		    echo "Not Numeric: $1 [ARG = sec]" 1>&2
		    exit 1
		else
		    DLTIME=${2}
		    echo "DLTIME: " ${DLTIME}
		    param="${PARM_MSG}"
                    shift 2		    
		fi
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
done

if [ -z $param ]; then
    echo "$PROGNAME: too few arguments" 1>&2
    echo "Try '$PROGNAME --help' for more information." 1>&2
    exit 1
fi
}


##################################
# main
##################################
get_args_1 $@

