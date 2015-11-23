
###########
# Function to Download data from a sensor
# Useage:
# > ./dl_data <hostname> <port> <filename> <logname>
###########
function dl_data()
{
    local hostname=${1}
    local port=${2}
    local data_file=${3}
    local logfile_name=${4}
    
    echo "OK. DL data will be saved at: ${EXP_DIR}/" #2>&1 | tee -a ${logfile_name}
    echo ""
    echo "Time stamp : " ${NOW}         2>&1 | tee -a ${logfile_name}
    echo "Run script : " ${SCRIPT_NAME} 2>&1 | tee -a ${logfile_name}
    echo "Device ID  : " ${DEVID}       2>&1 | tee -a ${logfile_name}
    echo "Connection : " ${CNCT}        2>&1 | tee -a ${logfile_name}
    echo "Port       : " ${PORT}        2>&1 | tee -a ${logfile_name}
    echo "           = <USB=20000>,<BT=10000> + <DEV ID>" 2>&1 | tee -a ${logfile_name}
    echo "File name  : " ${data_file}    2>&1 | tee -a ${logfile_name}
    echo "Log name   : " ${logfile_name}     2>&1 | tee -a ${logfile_name}
    echo "Data entry# to DL : " ${WHICHDATA} 2>&1 | tee -a ${logfile_name}
    echo "DL_TIME(sleep)    : " ${DLTIME}    2>&1 | tee -a ${logfile_name}
    echo "" 

    echo "Download data: (start in 7 sec)"  2>&1 | tee -a ${logfile_name}
    echo "" 2>&1 | tee -a ${logfile_name}

    ( echo open ${hostname} ${port}
      sleep 3
      echo devinfo
      sleep ${DURATION}
      echo getd
      sleep ${DURATION}
      echo getmemfreesize
      sleep ${DURATION}
      echo getbattstatus
      sleep ${DURATION}
      echo getags
      sleep ${DURATION}
      echo memcount
      sleep ${DURATION}
      echo getmementry ${WHICHDATA}
      sleep ${DURATION}
      echo getmementryinfo ${WHICHDATA}
      sleep ${DURATION}
      echo readmemdata ${WHICHDATA} 
      sleep ${DLTIME}
      #) | telnet | col -b > ${data_file}
    ) | telnet | col -b 2>&1 | tee -a ${data_file}
    echo "OK. Completed DL data" 2>&1 | tee -a ${logfile_name}
}
