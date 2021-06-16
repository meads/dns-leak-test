#!/usr/bin/env bash

set -e

declare LOG="${1}"
declare connection_uuid="${2}"

declare sound_pipe="/tmp/${connection_uuid}/sound_pipe"
declare project_root="$(dirname $(dirname $0))"

while true; do
  play "${project_root}/audio/dtmf-rbt-US.wav" repeat 20
  
  echo "Reading from pipe in initialize_sound" >> ${LOG} 
  if read line <$sound_pipe; then
  
    if [[ "$line" == 'quit' ]]; then
      echo "Read quit message from the pipe in $0" >> ${LOG}      
      exit;
    fi 
  fi
done
