#!/system/bin/sh

TARGET_DIR="/data/misc/wifi/wifi_cfg/"
HNOUC_DIR="/data/cota/para/wifi/wifi_cfg/"
VERSION_FILE="version.txt"
DEFAULT_VERSION=`getprop ro.vendor.wifi.cfg_version`
DEFAULT_VERSION=${DEFAULT_VERSION:="1.0.0.0"}

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }

if [ ! -f ${HNOUC_DIR}${VERSION_FILE} ]; then
  exit 0
else
  HNOUC_VERSION=`grep version ${HNOUC_DIR}${VERSION_FILE}`
  HNOUC_VERSION=${HNOUC_VERSION:8}
fi

if [ -z "${HNOUC_VERSION}" ]; then
  exit 0
fi

if [ ! -f ${TARGET_DIR}${VERSION_FILE} ]; then
  LOCAL_VERSION=""
else
  LOCAL_VERSION=`grep version ${TARGET_DIR}${VERSION_FILE}`
  LOCAL_VERSION=${LOCAL_VERSION:8}
fi

if ([ -z "$LOCAL_VERSION" ] && version_gt $HNOUC_VERSION $DEFAULT_VERSION) || \
   ([ -n "$LOCAL_VERSION" ] && version_gt $HNOUC_VERSION $LOCAL_VERSION); then
    mkdir -p ${TARGET_DIR}
    cp -rf ${HNOUC_DIR}* ${TARGET_DIR}
    chmod -R 774 ${TARGET_DIR}
fi

