
#################################
# Function to Download data from a sensor
# Useage:
# > ./dl_data <hostname> <port> <data_filename> <logname>
#################################
function dl_data-expect()
{
    local hostname=${1}
    local port=${2}
    local data_file=${3}
    local logfile_name=${4}

    echo "OK. DL data will be saved at: ${EXP_DIR}/" #2>&1 | tee -a ${logfile_name}
    echo "Time stamp : " ${NOW}         2>&1 | tee -a ${logfile_name}
    echo "Run script : " ${SCRIPT_NAME} 2>&1 | tee -a ${logfile_name}
    echo "Device ID  : " ${DEVID}       2>&1 | tee -a ${logfile_name}
    echo "Connection : " ${CNCT}        2>&1 | tee -a ${logfile_name}
    echo "Port       : " ${PORT}        2>&1 | tee -a ${logfile_name}
    echo "           = <USB=20000>,<BT=10000> + <DEV ID>" 2>&1 | tee -a ${logfile_name}
    echo "File name  : " ${data_file}    2>&1 | tee -a ${logfile_name}
    echo "Log name   : " ${logfile_name}     2>&1 | tee -a ${logfile_name}
    echo "Data entry# to DL : " ${WHICHDATA} 2>&1 | tee -a ${logfile_name}
    echo "" 
    echo "Download data: (start in a moment)"  2>&1 | tee -a ${logfile_name}
    echo "" 2>&1 | tee -a ${logfile_name}

    # telnet
    # timeout -1 ; no timeout
    expect -c "
    set timeout -1
    spawn telnet ${hostname} ${port}; sleep 1
    expect \"\r\"       ; sleep ${DURATION}
    send \"getd\r\"
    expect \"\r\"       ; sleep ${DURATION}
    send \"devinfo\r\"
    expect \"\r\"       ; sleep ${DURATION}
    send \"getmemfreesize\r\"
    expect \"\r\"       ; sleep ${DURATION}
    send \"getbattstatus\r\"
    expect \"\r\"       ; sleep ${DURATION}
    send \"getags\r\"
    expect \"\r\"       ; sleep ${DURATION}
    send \"memcount\r\"
    expect \"\r\"       ; sleep ${DURATION}
    send \"getmementry ${WHICHDATA}\r\"
    expect \"\r\"       ; sleep ${DURATION}
    send \"getmementryinfo ${WHICHDATA}\r\"
    expect \"\r\"       ; sleep ${DURATION}
    send \"readmemdata ${WHICHDATA}\r\"
    expect \"EOF\"      ; sleep ${DURATION}
    send \"\035\r\"
    expect \"telnet\>\" ; sleep ${DURATION}
    send \"quit\n\"
    " | col -b 2>&1 | tee -a ${data_file}
#    " | col -b 2>&1 > ${data_file}
    
    echo "OK. Completed DL data" 2>&1 | tee -a ${logfile_name}
    return 0
}






