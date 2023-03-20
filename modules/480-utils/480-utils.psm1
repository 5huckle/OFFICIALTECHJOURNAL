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

function VM-Cloner(){

    try{
        Write-Host Get-VM
        $vm = Read-Host "Enter name of the VM you would like to copy" 
        Get-VM -Name $vm

        $vmhost = Get-VMHost -Name "192.168.7.38"
        $ds = Get-DataStore -Name "datastore1"
        $snapshot = Get-Snapshot -VM $vm -Name "base"
        $linkedClone = $vm
        $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
        $newvmname = Read-Host "What would you like to name the new VM?"
        $newvm = New-VM -Name "$newVMName-base" -VM $linkedVM -VMHost $vmhost -Datastore $ds
        $newvm | New-Snapshot -Name "Base"

        #Post-Snapshots
        # This did not work
        # $newvmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName "480-WAN"

    }
    catch{
        Write-Host "Error: 404 (JK but still an error)"
        exit
    }
}