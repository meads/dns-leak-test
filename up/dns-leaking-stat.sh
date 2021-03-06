#!/usr/bin/env bash
  
set -ex

declare LOG="${1}"
declare connection_uuid="${2}"

# create a named pipe to read from when the background script has completed and written
declare dnsleaktester_pipe="/tmp/${connection_uuid}/dnsleaktester_pipe"

# create a named pipe for blocking until the background script has completed and written
declare sound_pipe="/tmp/${connection_uuid}/sound_pipe"

# Use a temp file for storing the multiline results from the dnsleaktest
declare DNSLEAKTEST_OUT=$(mktemp)

declare project_root="$(dirname $(dirname $0))"


function on-exit {
  rm -f "$dnsleaktester_pipe"
  rm -f "$sound_pipe"
  rm -f "$DNSLEAKTEST_OUT"
}

trap on-exit EXIT

mkdir -p "/tmp/${connection_uuid}" 

[[ ! -p "$dnsleaktester_pipe" ]] && mkfifo "$dnsleaktester_pipe"
[[ ! -p "$sound_pipe" ]] && mkfifo "$sound_pipe"

# Execute the initializing sound script in the background, which plays a synth melody in a loop waiting to receive a quit message on it's named sound_pipe.  
"${project_root}/dial-quitter.sh" "${LOG}" "${sound_pipe}" &

# Execute the dnsleaktester script which invokes the dnsleaktest script (provided by bash.ws site author), writing it's result to the named dnsleaktester_pipe on completion.
"${project_root}/dnsleaktester.sh" "${LOG}" "${dnsleaktester_pipe}" &


# Put a message in the sound_pipe, so that sound will play until the dnsleaktest result is written to the other named dnsleaktester_pipe   
echo >"$sound_pipe"


echo "Reading from the pipe in up script" >> "${LOG}"
  
# Block until the dnsleaktest results are written to the pipe.
if cat $dnsleaktester_pipe >$DNSLEAKTEST_OUT; then
  echo "Data received on dnsleaktester_pipe in up script." >> "${LOG}"

  # Put a quit message in the sound_pipe so that it will terminate.
  echo "quit" > "$sound_pipe"
fi


echo "Playing appropriate synth for DNSLEAKTEST_OUT status" >> "${LOG}"
cat "$DNSLEAKTEST_OUT" >> "${LOG}"

if grep -q 'DNS is not leaking' <<< "$(cat $DNSLEAKTEST_OUT)" ; then
  # play bell if dns is not leaking
  play -n synth 3 sin 960 vol 0.1 fade l 0 3 2.8

elif grep -q 'DNS may be leaking' <<< "$(cat $DNSLEAKTEST_OUT)" ; then
  # play dissonant sound if dns is leaking
  play -n -c1 synth sin %-0 sin %-1 fade h 0.1 1 0.1 

else
  # play dialtone if no internet
  play -n synth 0.1 sine 350 sine 440 channels 1 repeat 20 

fi
