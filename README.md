# DNS Leak Test
## **A Job for NetworkManager dispatcher.d**

Network Manager dispatcher scripts - allows you to respond to events on network interfaces by implementing a simple interface and staging the scripts according to a certain pattern.

## How is it used?

After installing and configuring for an ssid on your machine, it runs automatically in the background by NetworkManager executing the configured scripts for us when the network events are received.

When you boot up and your computer establishes a connection with the outside world you will begin to hear a telephone dialing sound during the query to the bash.ws site. Upon receipt of the dnsleaktest results, one of three sounds are played indicating the results:
    
    1. A bell is played. A bright "ding" is played when the dnsleaktest results are that "DNS is not leaking".
    
    2. A dissonant shrill sound is played indicating that "DNS is probably leaking".

    3. A telephone dial tone is played indicating "No internet connection."

Based on this sound you can carry on as usual with your online session or take the appropriate action with your VPN connection etc. to ensure that you aren't leaking DNS for whatever reason. This was largely for making my current setup easier to work with. My setup will not alow any connected devices to have outside access until the VPN tunnel has been established, but I was still having to test the DNS leaking manually each time. Now I can just wait for the bell!   

## Install

```bash
# 1. clone the repo
git clone https://github.com/meads/dns-leak-test.git

# 2. change directory to the repo
cd dns-leak-test

# 3. (optional) update the lib/bash.ws.sh script
make update-lib

# 4. install a configuration using the provided menu.
make

# A menu will be displayed like below allowing a numeric choice for
# the interface we want to have the leak tests performed on each time
# we connect. Press 1 here for "House" ssid.

SELECT   NAME              UUID                                  TYPE  DEVICE    
1)       House             a0c725bd-958e-4057-a941-184f1f556257  wifi  wifi0    
2)       Guest             8c7d89d5-8216-4989-b972-ae890abc5c85  wifi  --        
```

**What is created is something like the following directory structure under /etc/NetworkManager/dispatcher.d**

```bash
# ubuntu@machine:/etc/NetworkManager/dispatcher.d$ tree dns*

# dns-leak-test-a0c725bd-958e-4057-a941-184f1f556257
# dns-leak-test-scripts-a0c725bd-958e-4057-a941-184f1f556257
# ├── bash.ws.sh -> /home/ubuntu/dev/dns-leak-test/lib/bash.ws.sh
# ├── dial-quitter.sh -> /home/ubuntu/dev/dns-leak-test/dial-quitter.sh
# ├── dnsleaktester.sh -> /home/ubuntu/dev/dns-leak-test/dnsleaktester.sh
# ├── down
# │   └── disconnect-sound -> /home/ubuntu/dev/dns-leak-test/down/disconnect-sound.sh
# └── up
#     └── dns-leaking-stat -> /home/ubuntu/dev/dns-leak-test/up/dns-leaking-stat.sh

# 2 directories, 5 files

# see also: man NetworkManager(1)
# then search for "dispatcher" in the manual to see the entry 
# on NetworkManager dispatcher scripts

```

## Remove

```bash
# This will remove any configurations currently under /etc/NetworkManager/dispatcher.d/ and will prompt for root password.
make clean
```

*Note: The intention is to allow for multiple configurations, hence the usage of the device UUID used throughout each configuration generated after running `make` and selecting a number from the menu. However usage of multiple configurations is experimental at the moment.*

