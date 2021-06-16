#!/usr/bin/env bash

set -e

export uuid_to_dispatch_events_for=''
declare device_uuid_directory=''
declare has_chosen_uuid=1
declare has_selection_error=1

# Show a menu of devices that the user can select the UUID for and automatically symlink the required up/down scripts to perform the 
# DNS leak tests and play the sounds indicating such result statuses.

while [ $has_chosen_uuid -eq 1 ] ; do
  # banner
  
  if [ $has_selection_error -eq 0 ] ; then
    tput setaf 1
    echo "Invalid choice, choose a value from SELECT column."
    tput sgr0
  fi  
  echo "Choose a numeric value associated with a network device interface to dispatch events for, allowing detection of dns leakage."
  echo
  
  # Get output from the network manager cli and parse for menu data
  connection_info=$(nmcli connection show)

  # Draw a menu derived from the NetworkManager output and add a numbered SELECT column allowing for selection by n.
  awk -F '\t' 'BEGIN { OFS = FS }
     NR == 1 { printf "%-8s %s %s %s %s\n", "SELECT", $1, $2, $3, $4 }
     NR > 1  { printf "\033[33m%-8s \033[32m%s %s %s %s\n", NR-1 ")", $1, $2, $3, $4 }' <<< ${connection_info@E}

  # Get second column "UUID" as an array to allow indexing after menu selection.
  net_mngr_output=( $(echo "${connection_info@E}" | awk 'NR > 1 { print $2 }') )

  # If there are no errors and the selection has been made allow the screen to be redrawn above^
  if [ $has_selection_error -eq 1 ] && [ ${#uuid_to_dispatch_events_for} -gt 0 ] ; then
    has_chosen_uuid=0
    device_uuid_directory="/etc/NetworkManager/dispatcher.d/dns-leak-test-scripts-${uuid_to_dispatch_events_for}"
    
    # Create the directory for the selected UUID of the interface we are scripting events on.
    if [ -e "${device_uuid_directory}" ] ; then
        sudo rm -r "${device_uuid_directory}"/*
    fi
    sudo mkdir -p "${device_uuid_directory}"/{up,down}

    # create the main executable from "main.sh" template, that defers to the underlying script as events are received. e.g. "up", "down" etc.
    cat main.sh > dns-leak-test-${uuid_to_dispatch_events_for}

    # set required permissions and user/group ownership for dispatcher to execute it
    sudo chown root:root dns-leak-test
    sudo chmod 755 dns-leak-test

    # Move the executable created earlier into the root directory of the dispatcher.d.
    sudo mv dns-leak-test /etc/NetworkManager/dispatcher.d/

    # Symlink the up script
    sudo ln -s "$(pwd)/up/dns-leaking-stat.sh" "${device_uuid_directory}/up/dns-leaking-stat"

    # Symlink the down script
    sudo ln -s "$(pwd)/down/disconnect-sound.sh" "${device_uuid_directory}/down/disconnect-sound"

  else
    read -sn1 selection

    # If the user hits 'esc' or 'q' then bail out
    case $selection in
      $'\e') exit 0 ;;
        'q') exit 0 ;;
    esac

    # Make sure the selection is within the bounds of the data used to draw the menu.
    ((ubound=${#net_mngr_output[@]}+1))
    if [ $selection -gt 0 ] && [ $selection -lt $ubound ] ; then
      ((selection--))
      uuid_to_dispatch_events_for="${net_mngr_output[$selection]}"
      has_selection_error=1
    else
      has_selection_error=0
    fi
    clear
  fi

done

	