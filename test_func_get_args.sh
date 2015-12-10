#!/bin/bash

PROGNAME=$(basename $0)
VERSION="1.0"

# usage() {
#     echo "Usage: ${PROGNAME} [OPTIONS] <DEVICE_ID> ..." 1>&2
#     echo "Options:"
#     echo "  -h, --help"
#     echo "      --version"
#     echo "  -a, --long-a ARG"
#     echo "  -b, --long-b [ARG]"
#     echo "  -c, --long-c"
#     echo
#     echo "Usage: $PROGRAM [-y] [-h] [-c bt/usb] [-s sec] <DEVICE_ID> ..." 1>&2
#     echo "  --debug"            
#     echo "  -h, --help"
#     echo "  -y, --force-y"    
#     echo "  -c, --connection [bt/usb]"
#     echo "  -s, --sleep-time [sec]"        
#     echo
#     exit 1
# }

# # Usage:
# # > get_opts <ALL_ARGS>
# function get_opts()
# {
#     for OPT in "$@"
#     do
# 	case "$OPT" in
#             '-h'|'--help' )
# 		usage
# 		exit 1
# 		;;
#             '--version' )
# 		echo $VERSION
# 		exit 1
# 		;;
#             '-a'|'--long-a' )
# 		if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
#                     echo "$PROGNAME: option requires an argument -- $1" 1>&2
#                     exit 1
# 		fi
# 		ARG_A="$2"
# 		echo "ARG_A: ${ARG_A}"
# 		shift 2
# 		;;
#             '-b'|'--long-b' )
# 		if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
#                     shift
# 		else
# 		    ARG_B="$2"
# 		    echo "ARG_B: ${ARG_B}"
#                     shift 2
# 		fi
# 		;;
#             '-c'|'--long-c' )
# 		echo "-c true"
# 		shift 1
# 		;;
#             '--'|'-' )
# 		shift 1
# 		param+=( "$@" )
# 		break
# 		;;
#             -*)
# 		echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
# 		exit 1
# 		;;
#             *)
# 		if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
#                     #param=( ${param[@]} "$1" )
#                     param+=( "$1" )
# 		    echo "param: ${param}"
#                     shift 1
# 		fi
# 		;;
# 	esac
#     done

#     if [ -z $param ]; then
# 	echo "$PROGNAME: too few arguments" 1>&2
# 	echo "Try '$PROGNAME --help' for more information." 1>&2
# 	exit 1
#     fi
# }

###########################
# function/files to load
###########################
source ./func_get_args.sh

###########################
# main
###########################
get_opts $@

