#############
# Check/creat folder/dir to save DL data.
# It should be executed before the connection check.
# Useage:
#       :> check_file_dir <dir_name>
#############
function check_file_dir()
{
    if [ ! -d "${EXP_DIR}" ]; then
	mkdir ${1}
	if [ $? -eq 0 ]; then
	    echo "OK. created folder '${EXP_DIR}/"
	else
	    echo "ERROR: failed to creat folder '${EXP_DIR}/" 
	    return 1
	fi
    fi
    return 0
}


#############
# Check/creat folder/dir to save DL data.
# It should be executed before the connection check.
# Useage:
#       :> check_file_dir <dir_name> <file_name 1> <file_name 2> ......
#############
function save_files()
{
    local dir=$1

    echo "Dir/Folder to save files : ${dir}"
    shift
    while [ -n "$1" ]
    do
	mv ./${1} ${dir}
	if [ $? -eq 0 ]; then
	    echo "OK. mv ./${1} ${dir}/"
	else
	    echo "ERROR: mv ./${1} ${dir}/"
	    return 1
	fi
	shift
    done
    
    return 0
}
