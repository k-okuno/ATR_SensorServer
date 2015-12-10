#!/bin/bash
PROGNAME=$(basename $0)
VERSION="1.0"

###########################
# function/files to load
###########################
source ./func_get_args.sh
source ./func_if_num.sh

###########################
# main
###########################
get_opts $@

