################################
# templates of 
# getopts/getopt
################################

##############################
# getopt.sh
##############################
set -- 'getopt ad: $*'
if [ $? != 0 ]; then
    echo "Usage: $0 [-a] [-d dir]" 1>&2
    exit 1
fi
for OPT in $*
do
    case $OPT in
        -a) A_FLAG=1
            shift
            ;;
        -d) B_ARG=$2
            shift 2
            ;;
        --) shift
            break
            ;;
    esac
done



##############################
# another template
# getopt.sh
##############################
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

##############################
# getopts.sh
##############################
function usage_exit()
{
        echo "Usage: $0 [-a] [-d dir] item ..." 1>&2
        exit 1
}

function get_opts()
{
    while getopts ad:h OPT
    do
	case $OPT in
            a)  FLAG_A=1
		;;
            d)  VALUE_D=$OPTARG
		;;
            h)  usage_exit
		;;
            \?) usage_exit
		;;
	esac
    done

    shift $((OPTIND - 1))
}

