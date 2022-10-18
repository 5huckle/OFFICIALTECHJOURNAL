#!/bin/bash

# This code takes a network prefix and a specified DNS server to do a lookup on a range of IPs

echo "DNS resolution for $1 network"
for i in {1..254}
	do sudo nslookup $1.$i $2 | grep "name"
done

