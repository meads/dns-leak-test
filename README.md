# DNS Leak Test
## **A Job for NetworkManager dispatcher.d**


Network Manager dispatcher scripts - allows you to respond to events on network interfaces by implementing a simple interface and staging the scripts according to a certain pattern.





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
      
  
  

