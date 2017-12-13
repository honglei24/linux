#! /bin/bash
#==============================================================================
#
#          FILE: blkiotune.sh
#   DESCRIPTION: Set or remove blkio parameters
#       CREATED: 2017/11/24
#        AUTHOR: honglei
#==============================================================================

set -e

SCRTIP_NAME=$(basename $0)
exec 5>>/tmp/${SCRTIP_NAME/.sh/}.log

#---  FUNCTION  ---------------------------------------------------------------
#          NAME:  echolog
#   DESCRIPTION:  Echo log information to stdout.
#------------------------------------------------------------------------------
echolog() {
  printf "[`date "+%Y/%m/%d %H:%M:%S"`]: %s\n" "$@";
}

#---  FUNCTION  ---------------------------------------------------------------
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#------------------------------------------------------------------------------
usage() {
    cat << EOT

  Usage :  ./blkiotune.sh <-D domain> [-d <string>] [-r <number>] [-w <number>] [-R <number>] [-W <number>]

  Examples:
  1. Set blkio parameters for specific device.
    - ./blkiotune.sh -D e3d28339-8ea9-4d12-869b-02fb542cd74d -d /dev/mapper/vg_os-volume--5161ed36--e0ae--42e9--989f--54632fbbbc65 -W 1024000
  2. Remove blkio parameters for specific device.
    - ./blkiotune.sh -D e3d28339-8ea9-4d12-869b-02fb542cd74d -d /dev/mapper/vg_os-volume--5161ed36--e0ae--42e9--989f--54632fbbbc65
  3. Set blkio parameters for domain.
    - ./blkiotune.sh -D e3d28339-8ea9-4d12-869b-02fb542cd74d -W 1024000
  4. Remove blkio parameters for domain.
    - ./blkiotune.sh -D e3d28339-8ea9-4d12-869b-02fb542cd74d

  Options:
  -h  Display this message
  -D  <string> domain name, id or uuid. 
  -d  <string> in the form of /path/to/device. 
  -r <number>  per-device read I/O limit per second
  -w <number>  per-device write I/O limit per second
  -R <number>  per-device bytes read per second
  -W <number>  per-device bytes wrote per second
EOT
}   # ----------  end of function usage  ----------

echolog "${SCRTIP_NAME} START." >&5
while getopts ":hD:d:r:w:R:W:" opt
do
  case "${opt}" in

    h )  usage; exit 0                        ;;
    D )  domain=$OPTARG                       ;;
	d )  device=$OPTARG                       ;;
    r )  read_iops_sec=$OPTARG                ;;
    w )  write_iops_sec=$OPTARG               ;;
    R )  read_bytes_sec=$OPTARG               ;;
    W )  write_bytes_sec=$OPTARG              ;;
    \?)  echo
         echolog "Option does not exist : $OPTARG"
         usage
         exit 1
         ;;

  esac    # --- end of case ---
done

echolog "check parameter"  >&5
[ "x" = "x${domain}" ] && { usage; exit 1; }
read_iops_sec=${read_iops_sec:-0}
write_iops_sec=${write_iops_sec:-0}
read_bytes_sec=${read_bytes_sec:-0}
write_bytes_sec=${write_bytes_sec:-0}

if [ "x" = "x${device}" ]; then
  for device in $(virsh -q domblklist ${domain} | grep '/dev/mapper/vg_os' | awk '{print $2}')
  do
    echolog "tuning ${domain}'s ${device}" >&5
    virsh blkiotune ${domain} --device-read-iops-sec ${device},${read_iops_sec} --device-write-iops-sec ${device},${write_iops_sec} --device-read-bytes-sec ${device},${read_bytes_sec} --device-write-bytes-sec ${device},${write_bytes_sec} --live >&5
  done
else
  echolog "tuning ${domain}'s ${device}" >&5
  virsh blkiotune ${domain} --device-read-iops-sec ${device},${read_iops_sec} --device-write-iops-sec ${device},${write_iops_sec} --device-read-bytes-sec ${device},${read_bytes_sec} --device-write-bytes-sec ${device},${write_bytes_sec} --live >&5
fi

echolog "${SCRTIP_NAME} END." >&5
exit 0
