#! /bin/bash
#==========================================================
#
#          FILE: cold_migration.sh
#   DESCRIPTION: migrate vm
#  ORGANIZATION: XXX
#       CREATED: 2016/04/11
#        AUTHOR: honglei
#=========================================================

BASEPATH=`cd $(dirname "$0"); pwd`

#ERROR_NO_VDISK_NUM=101
#ERROR_NO_DIR_NOT_EXIST=102
#ERROR_NO_PARAMETER=103

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#----------------------------------------------------------------------------------------------------------------------
usage() {
    cat << EOT

  Usage :  cold_migration.sh -I <instancd id> -S <SRC_HOSTNAME> -D <DES_HOSTNAME>

  Examples:
    - cold_migration.sh -I 6af986ff-ece5-416b-a6eb-5c9cfe9e5357 -S osnode0000020 -D osnode0000021

  Options:
  -h  Display this message
  -I  instancd id. 
  -S  source host name.
  -D  destination host name.
EOT
}   # ----------  end of function usage  ----------

while getopts ":hI:S:D:" opt
do
  case "${opt}" in

    h )  usage; exit 0                          ;;
    I )  INSTANCE_ID=$OPTARG                    ;;
    S )  SRC_HOSTNAME=$OPTARG                   ;;
    D )  DES_HOSTNAME=$OPTARG                   ;;
    \?)  echo
         echoerror "Option does not exist : $OPTARG"
         usage
         exit 1
         ;;

  esac    # --- end of case ---
done
shift $((OPTIND-3)) >/dev/null 2>&1 || { usage; exit ${ERROR_NO_PARAMETER}; }

#check vm status

#check resource

#migrate vm

#check vm status
