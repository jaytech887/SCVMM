# This script will migrate servers from source standalone host to destination standalone HyperV host.
# This will include below steps - 
# Create a batch of 5 VMs at a time . This is done in order to ensure no extra load is performed over SCVMM server during migration.
# Shutdown 5 VMs
# Migrate VM to destination server
# Update VM version as well at destination server. Because destination host may have VMs at higher version.



# Set the source and destination Hyper-V hosts
$sourceHost = "SourceHost"
$destinationHost = "DestinationHost"

# Get the list of virtual machines to move
$vms = Get-SCVirtualMachine

# Set the maximum number of virtual machines to move at a time
$maxMoves = 5

# Loop through the list of virtual machines and move them in batches
for ($i = 0; $i -lt $vms.Count; $i += $maxMoves) {
    $batch = $vms[$i..($i + $maxMoves - 1)]
    foreach ($vm in $batch) {
        # Power off the virtual machine
        Stop-SCVirtualMachine -VM $vm -Shutdown -Force

        # Move the virtual machine to the destination host
        Move-SCVirtualMachine -VM $vm -VMHost $destinationHost

        # Update the configuration version of the virtual machine on the destination host
        Invoke-Command -ComputerName $destinationHost -ScriptBlock { Update-VMVersion -Name $vm.Name }
    }
}

