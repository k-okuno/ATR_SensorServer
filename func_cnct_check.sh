
function print_usage()
{
    echo "-USEAGE- " #2>&1 | tee -a ${LOGNAME}
    echo "> ${SCRIPT_NAME} <DEVICE ID> "  #2>&1 | tee -a ${LOGNAME}
    echo ""
}


###############################
# get_argsにしたい。Default値とかを設定したり、--port等を使って設定したい
# getopt, getopts
# 参考: http://shellscript.sunone.me/parameter.html
# これは不使用にすべき。良くない。
# Usage:
# check_args $@
###############################
function check_args()
{
    local port=${1}
    local dev_id=$((${port} % 10000))

    if [ $# -ne 1 ] ; then
	echo "ERROR: a Device ID required as the argument"
	echo "     : # of arg     : 1" 
	echo "     : the arg is   :  <DEVICE ID>" 
	print_usage
	return 1
    else
	echo "OK. # of argument checked"
	echo "OK. Port      :" ${port}
	echo "OK. Device ID :" ${dev_id}  
	return 0
    fi
}


###################################
# Function to check connection.
# Usage:
# > ./check_cnct <host> <port> <all_y>
###################################
function check_cnct()
{
    local host=${1}
    local port=${2}
    local all_y=${3}
    local TMPFILE=temp.txt
    local dev_id=$(( ${port} % 10000))
    
    echo "OK. Checking connection (expection ${CNCT}) ..." 
    echo ""

    ( echo open ${host} ${port}
      sleep 3; echo "status"
      sleep 1
    ) | telnet | col -b 2>&1 | tee ${TMPFILE}
    
    if [ ! -f ${TMPFILE} ] ; then
	echo "ERROR: " ${TMPFILE} "does not exist" 
	return 1
    else
	ct=1
	STATUS=-1
	while read line; do
	    if [ ${ct} -eq 4 ]; then
		STATUS=${line}
		break
	    fi
	    ct=$((ct + 1))
	done < ${TMPFILE}
    fi

    echo "" 
    echo "Expecting Connection                  : " ${CNCT}   
    echo "Status (USB接続=0, BT接続=2, 計測中=3): " ${STATUS} 


    if [ ${STATUS} -eq 0 ] && [ ${CNCT} = "USB" ]; then
	echo ""
	echo "OK. USB connection comfirmed." 
    elif [ ${STATUS} -eq 2 ] && [ ${CNCT} = "BT" ]; then
	echo ""
	echo "OK. BT connection comfirmed."
	echo "OK. Port     :" ${port}
	echo "OK. Device ID:" ${dev_id}
    else
	echo ""
	echo "ERROR: NO CONNECTION !!"
	echo "Port     :" ${port}
	echo "Device ID:" ${dev_id}
	echo ""
	echo "CHECK 'Device ID' 'Power' 'BT,USB' 'SensorServer.exe'"
	echo "then Re-run the program!"
	echo ""
	rm ${TMPFILE}
	return 1
    fi

    if [ ${all_y} != "TRUE" ];then
	echo ""
	echo -n "Ready? press enter (Y) > "
	read INPUT
    else
	echo "OK. start in a moment."
	echo ""
    fi
    rm ${TMPFILE}
    return 0
}
