# DNS Leak Test
## **A Job for NetworkManager dispatcher.d**


Network Manager dispatcher scripts - allows you to respond to events on network interfaces by implementing a simple interface and staging the scripts according to a certain pattern.



In a nutshell:

  all dispatcher scripts are located in /etc/NetworkManager/dispatcher.d/
  all embedded shell scripts (music/initializing-sound.sh and net/dnsleaktester.sh) are located starting from ~/homer/dev/

```bash
  88-Master-Dispatcher (<-- dispatcher script)
  |
  |
  /[event name]/dns-leaking-stat.sh (<-- dispatcher script)
  |
  |
  |____ initializing-sound.sh (<-- embedded script)
  |
  |
  |____ dnsleaktester.sh (<-- embedded script)


  /etc/NetworkManager/dispatcher.d/
  ├── 01-ifupdown
  ├── 0cae10dc-2207-4cba-a4b1-e95cdaca22f6
  │   ├── down
  │   │   └── disconnect -> /home/ubuntu/homer/dev/music/disconnect-sound.sh
  │   └── up
  │       └── dns-leaking-stat -> /home/ubuntu/homer/dev/music/dns-leaking-stat.sh
  ├── 88-Master-Dispatcher
  ├── no-wait.d
  ├── ntp 
  ├── pre-down.d
  └── pre-up.d


Example:

  /etc/NetworkManager/dispatcher.d/88-Master-Dispatcher # loops over each executable found in ${CWD}/${CONNECTION_UUID}/${STATE}/* and sources it.
    /etc/NetworkManager/dispatcher.d/0cae10dc-2207-4cba-a4b1-e95cdaca22f6/up/dns-leaking-stat.sh # gets executed when connection uuid "0cae10dc-2207-4cba-a4b1-e95cdaca22f6" has STATE "up"
                                                                                                 # also plays sounds while the dns leak tests are being performed finally notifying via
                                                                                                 # specific melodies which state the dns is in. (Not leaking, Leaking, No Internet)
      /home/ubuntu/homer/dev/music/initializing-sound.sh # play specific melodies while reading non quit messages on the named pipe for sound playing communications between the parent script 'dns-leaking-stat.sh'.
      
      /home/ubuntu/homer/dev/net/dnsleaktester.sh # calls out to the bash.ws for dns leak queries writing the results to a named pipe for relaying the information back to the parent script 'dns-leaking-stat.sh'.


see also: man NetworkManager(1)
```



BUGS:
  Scenario:
    NOTE: kind of two bugs here...
    When the modem is down prior to establishing a connection we experience a dialtone as expected however,
    upon powering up the modem and establishing an actual connecton, subsequent attempts to disconnect and
    reconnect using NetworkManager are successful but still play sound synth associated with dialtone aka No Internet.

  Reproduce Steps:
        
  1.  Modem State: powered down
      Router State: powered up and broadcasting
      NIC State: disconnected
      Action: activate connection through NetworkManager 
      Expected Result: dialtone
      Actual Result: dialtone
  
  2.  Modem State: powered down
      Router State: powered up and broadcasting
      NIC State: connected
      Action: power up modem 
      Expected Result: ringing tone is played (initializing-sound.sh)
      Actual Result: dialtone
  
  3.  Modem State: powered up
      Router State: powered up and broadcasting
      NIC State: connected
      Action: disconnect ssid with NetworkManager 
      Expected Result: dialtone is played
      Actual Result: dialtone
      
  4.  Modem State: powered up
      Router State: powered up and broadcasting
      NIC State: disconnected
      Action: connect to wifi with NetworkManager 
      Expected Result: ringing tone is played (initializing-sound.sh)
      Actual Result: dialtone
      
  
  

