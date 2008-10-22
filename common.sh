
SCRIPT_NAME=$(basename $0)

for dir in /lib/udev /sbin; do
  if [ -f $dir/vol_id -a -x $dir/vol_id ]; then
    VOL_ID=$dir/vol_id
  fi
done

if [ -z "$VOL_ID" ]; then
    echo "vol_id not found, please install udev"
    exit 1
fi

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
  if [ "$SCRIPT_NAME" != "export" -a -z "$swapdev"  ]; then
    echo "Missing OS API Argument"
    exit 1
  fi
  if [ "$SCRIPT_NAME" = "rename" -a -z "$new_name"  ]; then
    echo "Missing OS API Argument"
    exit 1
  fi
}

get_api10_arguments() {
  if [ -z "$INSTANCE_NAME" -o -z "$HYPERVISOR" -o -z "$DISK_COUNT" ]; then
    echo "Missing OS API Variable"
    exit 1
  fi
  instance=$INSTANCE_NAME
  if [ $DISK_COUNT -lt 1 -o -z "$DISK_0_PATH" ]; then
    echo "At least one disk is needed"
    exit 1
  fi
  blockdev=$DISK_0_PATH
  if [ "$SCRIPT_NAME" = "rename" -a -z "$OLD_INSTANCE_NAME" ]; then
    echo "Missing OS API Variable"
  fi
  old_name=$OLD_INSTANCE_NAME
}

if [ -z "$OS_API_VERSION" -o "$OS_API_VERSION" = "5" ]; then
  OS_API_VERSION=5
  get_api5_arguments
elif [ "$OS_API_VERSION" = "10" ]; then
  get_api10_arguments
  if [ $SCRIPT_NAME = "import" -o $SCRIPT_NAME = "export" ]; then
    echo "import/export still not compatible with API version 10"
    exit 1
  fi
else
  echo "Unknown OS API VERSION $OS_API_VERSION"
  exit 1
fi
