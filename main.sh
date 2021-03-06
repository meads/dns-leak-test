#!/usr/bin/env bash

DEVICE=${1}
STATE=${2}
CWD=$(dirname "$0")

LOG='/var/log/NetworkManager/dns-leak-test.d.log'

[[ -z ${CONNECTION_UUID} ]] && exit 0

# DEBUG
echo "$(date +"%F %T") Called with ($*) and connection uuid is: ${CONNECTION_UUID}" >> "${LOG}"

# Needed only if you need to display notification popups
#export DISPLAY=:0.0
#export $(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep session)/environ)

for FILE in ${CWD}/dns-leak-test-scripts-${CONNECTION_UUID}/${STATE}/*
do
  #DEBUG
  echo "$(date +"%F %T") Running ${FILE}" >> "${LOG}"

  ${FILE} "${LOG}" "${CONNECTION_UUID}"
done

