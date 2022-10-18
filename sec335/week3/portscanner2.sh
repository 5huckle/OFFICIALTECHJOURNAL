#!/bin/bash 
echo "host=$1, port=$2"
for i in {1..254}
	do echo "$1.$i, $2" && sudo nmap -Pn -sV -sT $1.$i -p $2
done





