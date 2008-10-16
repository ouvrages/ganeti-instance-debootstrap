
get_api5_arguments() {
  TEMP=`getopt -o o:n:i:b:s: -n '$0' -- "$@"`
  if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
  # Note the quotes around `$TEMP': they are essential!
  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -i|-o) instance=$2; shift 2;;

      -n) new_name=$2; shift 2;;

      -b) blockdev=$2; shift 2;;

      -s) swapdev=$2; shift 2;;

      --) shift; break;;

      *)  echo "Internal error!"; exit 1;;
    esac
  done
  if [ -z "$instance" -o -z "$blockdev" ]; then
    echo "Missing OS API Argument"
    exit 1
  fi
  if [ "$0" != "export" -a -z "$swapdev"  ]; then
    echo "Missing OS API Argument"
    exit 1
  fi
  if [ "$0" = "rename" -a -z "$new_name"  ]; then
    echo "Missing OS API Argument"
    exit 1
  fi
}

get_api5_arguments

