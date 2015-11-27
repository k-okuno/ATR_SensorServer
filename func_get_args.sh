# this is the function: get arg
# it is more like a template.

usage()
{
    echo "Usage: $PROGNAME [OPTIONS] FILE"
    echo "  This script is ~."
    echo
    echo "Options:"
    echo "  -h, --help"
    echo "      --version"
    echo "  -a, --long-a ARG"
    echo "  -b, --long-b [ARG]"
    echo "  -c, --long-c"
    echo
    exit 1
}


for OPT in "$@"
do
    case "$OPT" in
        '-h'|'--help' )
            usage
            exit 1
            ;;
        '--version' )
            echo $VERSION
            exit 1
            ;;
        '-a'|'--long-a' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            ARG_A="$2"
	    echo "arg_a" ${ARG_A}
	    param="something"
            shift 2
            ;;
        '-b'|'--long-b' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                shift
            else
		ARG_B="$2"
		echo "arg_b: " ${ARG_B}
		param="something"
                shift 2
            fi
            ;;
        '-c'|'--long-c' )
            shift 1
            ;;
        '--'|'-' )
            shift 1
            param+=( "$@" )
	    echo "DEBUG param 1 : " ${param}
            break
            ;;
        -*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                #param=( ${param[@]} "$1" )
                param+=( "$1" )
		echo "DEBUG param 2 : " ${param}
                shift 1
            fi
            ;;
    esac
done

if [ -z $param ]; then
    echo "$PROGNAME: too few arguments" 1>&2
    echo "Try '$PROGNAME --help' for more information." 1>&2
    exit 1
fi

