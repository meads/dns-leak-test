#!/usr/bin/env bash
  
set -e

declare LOG=$1

# create a named pipe for blocking until the background script has completed and written
declare dnsleaktester_pipe=/tmp/dnsleaktester_pipe

# create a named pipe for blocking until the background script has completed and written
declare sound_pipe=/tmp/sound_pipe

# Use a temp file for storing the multiline results from the dnsleaktest
declare DNSLEAKTEST_OUT=$(mktemp)

function on-exit {
  rm -f $dnsleaktester_pipe
  rm -f $sound_pipe
  rm -r $DNSLEAKTEST_OUT
}
trap on-exit EXIT

[[ ! -p $dnsleaktester_pipe ]] && mkfifo $dnsleaktester_pipe
[[ ! -p $sound_pipe ]] && mkfifo $sound_pipe


# Execute the initializing sound script in the background, which plays a synth melody in a loop waiting to receive a quit message on it's named sound_pipe.  
"${project_root}/audio/initializing-sound.sh" &

# Execute the dnsleaktester script which invokes the dnsleaktest script (provided by bash.ws site author), writing it's result to the named dnsleaktester_pipe on completion.
"${project_root}/dnsleaktester.sh" ${LOG} &


# Put a message in the sound_pipe, so that sound will play until the dnsleaktest result is written to the other named dnsleaktester_pipe   
echo >$sound_pipe


echo "Reading from the pipe in up script" >> ${LOG}
  
# Block until the dnsleaktest results are written to the pipe.
if cat $dnsleaktester_pipe >$DNSLEAKTEST_OUT; then
  echo "Data received on dnsleaktester_pipe in up script." >> ${LOG}

  # Put a quit message in the sound_pipe so that it will terminate.
  echo "quit" > $sound_pipe
fi


echo "Playing appropriate synth for DNSLEAKTEST_OUT status" >> ${LOG}
cat "$DNSLEAKTEST_OUT" >> ${LOG}

if grep -q 'DNS is not leaking' <<< "$(cat $DNSLEAKTEST_OUT)" ; then
  # play bell if dns is not leaking
  play -n synth 3 sin 960 vol 0.1 fade l 0 3 2.8

elif grep -q 'DNS may be leaking' <<< "$(cat $DNSLEAKTEST_OUT)" ; then
  # play dissonant sound if dns is leaking
  play -n -c1 synth sin %-0 sin %-1 fade h 0.1 1 0.1 

else
  # play dialtone if no internet
  play "${project_root}/audio/dtmf-dialtone.wav" repeat 20 

fi
