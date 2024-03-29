function 480banner()
{
    Write-Host "Hello SYS480 Devops"
}

function 480Connect([string] $server){
    $conn = $global:DefaultVIServer
    #Checks to see if we are connected
    if ($conn){
        $msg = 'Already Connected to: {0}' -f $conn

        Write-Host -ForegroundColor Green $msg
    } else{
        $conn = Connect-VIServer -Server $server

    }
}

function Get-480Config([string] $config_path)
{
    Write-Host "Reading " $config_path
    $conf = $null
    if (Test-Path $config_path){
        $conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)
        $msg = "Using configuration at {0}" -f $config_path
        Write-Host -ForegroundColor "Green" $msg
    } else{
        Write-Host -ForegroundColor "Yellow" "No Configuration"
    }
    return $conf
}

function Select-VM([string] $folder)
{
    $selected_vm=$null
    try{
        $vms = Get-VM -Location $folder
        $index = 1
        foreach($vm in $vms){
            Write-Host [$index] $vm.name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        if($pick_index -ge $index){
            return "Error, selected VM does not exist. Please try again" 
        }        
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked " $selected_vm.name
        #note this is a full on vm object that we can interact with
        return $selected_vm
    }

    catch{
        Write-Host "Invalid Folder: $folder" -ForegroundColor "Red"
    }
}

function VM-FullCloner(){

    try{
        Get-Vm
        $vmname = Read-Host "Enter the name of the VM you would like to create a copy of" 
        Get-VM -Name $vmname
        $vmhost = Get-VMHost -Name "192.168.7.38"
        $ds = Get-DataStore -Name "datastore1"
        $snapshot = Get-Snapshot -VM $vmname -Name "Base"
        $newvmname = Read-Host 'What would you like to name the new VM'
        $newvm = New-VM -Name $newvmname -VM $vmname -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
        $newvm
        #New-Snapshot -vm $newvm -Name 'Base'
    }
    catch{
        Write-Host "This is quite embarrassing but something seems to have gone wrong... please try again"
    }
}

function VM-Cloner(){

    try{
        Get-VM
        $vm = Read-Host "Enter name of the VM you would like to copy" 
        $sourcevm = Get-VM -Name $vm

        $vmhost = Get-VMHost -Name "192.168.7.38"
        $ds = Get-DataStore -Name "datastore1"
        $snapshot = get-Snapshot -VM $vm -Name "Base"
        $newvmname = Read-Host "What would you like to name the new VM?"
        $linkedVM = New-VM -LinkedClone -Name $newvmname -VM $sourcevm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
        New-Snapshot -vm $linkedVM -Name "Base"

        # Post-Snapshots
        # This did not work
        # $newvmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "480-WAN"

    }
    catch{
        Write-Host "Error: 404 (JK but still an error)"
        exit
    }
}

function new-network(){
   try {
    $switchname = Read-Host "What is the name of the virtual switch you would like to create"
    $portgroupname = Read-Host "What is the name of the Portgroup you would like to create"

    New-VirtualSwitch -VMHost '192.168.7.38' -Name $switchname
    Get-VMHost '192.168.7.38' | Get-VirtualSwitch -name $switchname | New-VirtualPortGroup -name $portgroupname
    }
    catch {
        Write-Host " That did not work, please try again."
    }
}

function Get-IP(){
    try{
        Get-VM
        $vmname = Read-host "VM name"
        $ip = (Get-VM -Name $vmname).guest.ipaddress[0,1, 2,4]
        Get-NetworkAdapter -VM $vmname | Select-Object Name, MacAddress
        Write-Host "IP Address: ", $ip
    }
    catch{
        Write-Host "Sorry, that didn't work. Please try again."
    }
}

function vStart(){
    try {
        Get-VM
        $vm = Read-Host "Which VM would you like to start?"
        Start-VM -VM $vm -Confirm
    }
    catch {
        Write-Host "Error, your VM might already be on!"
    }
}

function vStop(){
    try {
        Get-VM
        $vm = Read-Host "Which VM would you like to stop?"
        Stop-VM -VM $vm -Confirm
    }
    catch {
        Write-Host "Error, your VM might already be off!"
    }
}

function Set-Network(){
    try{
        Get-VM
        $vm = Read-Host "Which VM would you like to select?"
        Get-VirtualNetwork
        $vmnetwork = Read-Host "Which network would you like to use?"
        Get-NetworkAdapter -VM $vm | Set-NetworkAdapter -NetworkName $vmnetwork
    }
    catch {
        Write-Host "That didn't work, please try again"
    }
}

function SetIP([string] $VMName, [string] $interfaceIndex, [string] $IPAddr, [string] $netmask, [string] $gateway, [string] $nameserver, [string] $guestUser, [string] $guestPass){ 
    Get-NetworkAdapter -VM $VMName | Set-NetworkAdapter -NetworkName "BLUE1-LAN"

    $guestPass = Read-Host -Prompt "Enter password"
    Write-Host $VMName
    Write-Host $interfaceIndex
    Write-Host $IPAddr
    Write-Host $netmask
    Write-Host $gateway
    Write-Host $nameserver
    Write-Host $guestUser
    Write-Host $guestPass
    
    $scriptIP = "netsh interface ip set address name='$interfaceIndex' static $IPAddr $netmask $gateway"
    Invoke-VMScript -VM $VMName -ScriptText $scriptIP -GuestUser $guestUser -GuestPassword $guestPass -ScriptType bat -WarningAction 0

    #$scriptIP = "netsh interface ip set address name='Ethernet0' static 10.0.5.7 255.255.255.0 10.0.5.2"
    #Invoke-VMScript -VM "dc-blue2" -ScriptText $scriptIP -GuestUser "deployer" -GuestPassword "Password123$" -ScriptType bat -WarningAction 0


    $scriptDNS1 = 'netsh interface ip set dns name=`"Ethernet0" static 10.0.5.2'
    Invoke-VMScript -VM $VMName -ScriptText $scriptDNS1 -GuestUser $guestUser -GuestPassword $guestPass -ScriptType bat -WarningAction 0

    #$scriptDNS2 = 'netsh interface ipv4 set dns name=`"Ethernet1" static 8.8.8.8'
    #Invoke-VMScript -VM $VMName -ScriptText $scriptDNS2 -GuestUser $guestUser -GuestPassword $guestPass -ScriptType bat -WarningAction 0
}
