
log_error() {
  echo "$@" >&2
}

SCRIPT_NAME=$(basename $0)

for dir in /lib/udev /sbin; do
  if [ -f $dir/vol_id -a -x $dir/vol_id ]; then
    VOL_ID=$dir/vol_id
  fi
done

if [ -z "$VOL_ID" ]; then
    log_error "vol_id not found, please install udev"
    exit 1
fi

get_api5_arguments() {
  TEMP=`getopt -o o:n:i:b:s: -n '$0' -- "$@"`
  if [ $? != 0 ] ; then log_error "Terminating..."; exit 1 ; fi
  # Note the quotes around `$TEMP': they are essential!
  eval set -- "$TEMP"
  while true; do
    case "$1" in
      -i|-n) instance=$2; shift 2;;

      -o) old_name=$2; shift 2;;

      -b) blockdev=$2; shift 2;;

      -s) swapdev=$2; shift 2;;

      --) shift; break;;

      *)  log_error "Internal error!" >&2; exit 1;;
    esac
  done
  if [ -z "$instance" -o -z "$blockdev" ]; then
    log_error "Missing OS API Argument (-i, -n, or -b)"
    exit 1
  fi
  if [ "$SCRIPT_NAME" != "export" -a -z "$swapdev"  ]; then
    log_error "Missing OS API Argument -s (swapdev)"
    exit 1
  fi
  if [ "$SCRIPT_NAME" = "rename" -a -z "$old_name"  ]; then
    log_error "Missing OS API Argument -o (old_name)"
    exit 1
  fi
}

get_api10_arguments() {
  if [ -z "$INSTANCE_NAME" -o -z "$HYPERVISOR" -o -z "$DISK_COUNT" ]; then
    log_error "Missing OS API Variable:"
    log_error "(INSTANCE_NAME HYPERVISOR or DISK_COUNT)"
    exit 1
  fi
  instance=$INSTANCE_NAME
  if [ $DISK_COUNT -lt 1 -o -z "$DISK_0_PATH" ]; then
    log_error "At least one disk is needed"
    exit 1
  fi
  if [ "$SCRIPT_NAME" = "export" ]; then
    if [ -z "$EXPORT_DEVICE" ]; then
      log_error "Missing OS API Variable EXPORT_DEVICE"
    fi
    blockdev=$EXPORT_DEVICE
  elif [ "$SCRIPT_NAME" = "import" ]; then
    if [ -z "$IMPORT_DEVICE" ]; then
       log_error "Missing OS API Variable IMPORT_DEVICE"
    fi
    blockdev=$IMPORT_DEVICE
  else
    blockdev=$DISK_0_PATH
  fi
  if [ "$SCRIPT_NAME" = "rename" -a -z "$OLD_INSTANCE_NAME" ]; then
    log_error "Missing OS API Variable OLD_INSTANCE_NAME"
  fi
  old_name=$OLD_INSTANCE_NAME
}

if [ -z "$OS_API_VERSION" -o "$OS_API_VERSION" = "5" ]; then
  OS_API_VERSION=5
  get_api5_arguments
elif [ "$OS_API_VERSION" = "10" ]; then
  get_api10_arguments
else
  log_error "Unknown OS API VERSION $OS_API_VERSION"
  exit 1
fi
