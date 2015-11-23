#!/bin/sh
# 2015/11/19

##############
# Useage:
# > ./test_func_cnct_check.sh <device id>
##############
HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

DEVID=${1}

# Set connection means
# BT -> 1, USB -> 2
CNCT="USB"
#CNCT="BT"
COM=2; if [ ${CNCT} = "BT" ]; then COM=1; fi

# Port# : <BT=1 or USB=2><DEVID>
PORT=${COM}${DEVID}

# only for local use
TMPLOGNAME=tmplog.txt

#############
# check return value of function.
#############
check_func_rtv()
{
    if [ ${PIPESTATUS[0]} -ne 0 ] ; then
	exit 1
    fi
}

#############
# function to test
#############
source  ./func_cnct_check.sh

#############
# main
#############
check_args ${ALL_ARGS} 2>&1 | tee ${TMPLOGNAME}
check_func_rtv

check_cnct ${HOST} ${PORT} | tee -a ${TMPLOGNAME}
check_func_rtv

exit 0

