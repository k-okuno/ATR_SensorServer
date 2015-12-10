#!/bin/bash
# 2015/11/19

##############
# Useage:
# > ./test_func_cnct_check.sh <device id>
##############

PROGNAME=$(basename $0)
HOST="localhost"

SCRIPT_NAME=${0}
ALL_ARGS=$@

# defualt: NO "force/all yes"
ALL_Y=FALSE

# device ID
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


###########################
# function/files to load
###########################
source ./func_cnct_check.sh
source ./func_get_args.sh
source ./func_if_num.sh


#############
# main
#############
#check_args ${ALL_ARGS} 2>&1 | tee ${TMPLOGNAME}
get_opts $@
check_func_rtv


check_cnct ${HOST} ${PORT} | tee -a ${TMPLOGNAME}
check_func_rtv

exit 0

