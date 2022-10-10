# Resolve all DNS names in a range

# Links user input with code
$scope = $args[0]
$serverIP = $args[1]

#generate IP addresses
For ($i = 0; $i-le 255; $i++){
$ip = $scope + ("." + $i)
Resolve-DnsName -DnsOnly $ip -Server $serverIP -ErrorAction Ignore
}


#for loop to cycle through IP addresses
