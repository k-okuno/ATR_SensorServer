#!/bin/bash
################################
# templates
# getopts
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
# getopts.sh
##############################
#!/bin/bash


usage_exit() {
        echo "Usage: $0 [-a] [-d dir] item ..." 1>&2
        exit 1
}

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


################################
# template
# getopt
################################
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

