#!/usr/bin/env bash

set -e

declare LOG='/var/log/NetworkManager_dispatcher.d.log'
declare sound_pipe='/tmp/sound_pipe'
declare project_root=$(dirname $(dirname $0))

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
