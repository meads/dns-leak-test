all:
	./install.sh
clean:
	sudo rm -rf /etc/NetworkManager/dispatcher.d/dns-leak-test-*
logs:
	tail -f /var/log/NetworkManager/dns-leak-test.d.log
update-lib:
	curl https://raw.githubusercontent.com/macvk/dnsleaktest/master/dnsleaktest.sh -o lib/bash.ws.sh && chmod 755 lib/bash.ws.sh