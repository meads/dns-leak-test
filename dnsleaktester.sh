#!/usr/bin/env bash

set -e

declare project_root=$(dirname $0)
declare dnsleaktester_pipe=/tmp/dnsleaktester_pipe

if [[ ! -p $dnsleaktester_pipe ]]; then
    echo "Reader not running" >> ${LOG}
    exit 1
fi

# Querying bash.ws to see if we are open to transparent proxies, if we are using the same ip for dns and internet access and in general if we are leaking dns.
echo "Querying bash.ws to see if we are leaking DNS, then writing results to the dnsleaktester_pipe." >> ${LOG}

"$project_root/bash.ws.sh"  >$dnsleaktester_pipe

