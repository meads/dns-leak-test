#!/usr/bin/env bash

set -e

declare LOG="${1}"
declare sound_pipe="${2}"

declare project_root="$(dirname $(dirname $0))"

while true; do
  play -n synth 0.1 sine 440 sine 480 channels 1 repeat 20

  if read line <"$sound_pipe"; then
  
    if [[ "$line" == 'quit' ]]; then
      echo "Read quit message from the pipe in $0" >> "${LOG}"      
      exit;
    fi 
  fi
  
  sleep 4
done
