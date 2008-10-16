
get_api5_arguments() {
  TEMP=`getopt -o o:n:i:b:s: -n '$0' -- "$@"`
  if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
  # Note the quotes around `$TEMP': they are essential!
  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -i|-n) instance=$2; shift 2;;

      -o) old_name=$2; shift 2;;

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

get_api10_arguments() {
  if [ -z "$INSTANCE" -o -z "$HYPERVISOR" -o -z "$DISK_COUNT" ]; then
    echo "Missing OS API Variable"
    exit 1
  fi
  instance=$INSTANCE
  if [ $DISK_COUNT -lt 1 -o -z "$DISK_0_PATH" ]; then
    echo "At least one disk is needed"
    exit 1
  fi
  blockdev=$DISK_0_PATH
  if [ "$0" = "rename" -a -z "$NEW_INSTANCE_NAME" ]; then
    echo "Missing OS API Variable"
  fi
  new_name=$NEW_INSTANCE_NAME
}

if [ -z "$OS_API_VERSION" -o "$OS_API_VERSION" = "5" ]; then
  OS_API_VERSION=5
  get_api5_arguments
elif [ "$OS_API_VERSION" = "10" ]; then
  get_api10_arguments
  if [ $0 = "import" -o $0 = "export" ]; then
    echo "import/export still not compatible with API version 10"
    exit 1
  fi
else
  echo "Unknown OS API VERSION $OS_API_VERSION"
  exit 1
fi
