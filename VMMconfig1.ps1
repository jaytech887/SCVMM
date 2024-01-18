# Import the SCVMM module
Import-Module -Name VirtualMachineManager

# Network Configuration consist of multiple settings including below - 
# Logical Networks
# MAC Address pools
# Load Balancers  - Skipped, since not commonly used. 
# VIP Templates   - Skipped, since not commonly used. 
# Logical Switches
# Port Profiles
# Port Classifications
# Network Services

################## Pre-information to gather source and destination SCVMM server #################

# Connect to the source and destination SCVMM servers
$sourceServer = Get-SCVMMServer -ComputerName "SourceServerName"
$destinationServer = Get-SCVMMServer -ComputerName "DestinationServerName"

#################### Step 1: Lets Replicate Logical Network configuration first at destination VMM server #####################

# Get all the logical networks from the source server
$logicalNetworks = Get-SCLogicalNetwork -VMMServer $sourceServer

# Loop through each logical network and create it on the destination server
foreach ($logicalNetwork in $logicalNetworks) {
    $newLogicalNetwork = New-SCLogicalNetwork -VMMServer $destinationServer -Name $logicalNetwork.Name -Description $logicalNetwork.Description

    # Get all the logical network definitions for the current logical network
    $logicalNetworkDefinitions = Get-SCLogicalNetworkDefinition -LogicalNetwork $logicalNetwork -VMMServer $sourceServer

    # Loop through each logical network definition and create it on the destination server
    foreach ($logicalNetworkDefinition in $logicalNetworkDefinitions) {
        $newLogicalNetworkDefinition = New-SCLogicalNetworkDefinition -VMMServer $destinationServer -LogicalNetwork $newLogicalNetwork -Name $logicalNetworkDefinition.Name -SubnetVLan $logicalNetworkDefinition.SubnetVLans -VMHostGroup $logicalNetworkDefinition.HostGroups

        # Get all the IP address pools for the current logical network definition
        $ipPools = Get-SCStaticIPAddressPool -LogicalNetworkDefinition $logicalNetworkDefinition -VMMServer $sourceServer

        # Loop through each IP address pool and create it on the destination server
        foreach ($ipPool in $ipPools) {
            New-SCStaticIPAddressPool -VMMServer $destinationServer -LogicalNetworkDefinition $newLogicalNetworkDefinition -Name $ipPool.Name -Description $ipPool.Description -Subnet $ipPool.Subnet -Vlan $ipPool.VLanID -IPAddressRangeStart $ipPool.IPAddressRangeStart -IPAddressRangeEnd $ipPool.IPAddressRangeEnd -VIPAddressSet $ipPool.VIPAddressSet -DNSServer $ipPool.DNSServers -DNSSuffix $ipPool.DNSSuffix -NetworkRoute $ipPool.NetworkRoute -IPAddressReservedSet $ipPool.IPAddressReservedSet -WINSServer $ipPool.WINSServers -EnableNetBIOS $ipPool.EnableNetBIOS | Out-Null
        }
    }

    # Get all the VM networks for the current logical network
    $vmNetworks = Get-SCVMNetwork -LogicalNetwork $logicalNetwork -VMMServer $sourceServer

    # Loop through each VM network and create it on the destination server
    foreach ($vmNetwork in $vmNetworks) {
        New-SCVMNetwork -VMMServer $destinationServer -Name $vmNetwork.Name -LogicalNetwork $newLogicalNetwork -IsolationType $vmNetwork.IsolationType -Description $vmNetwork.Description | Out-Null
    }
}

#################### Step 2: Lets Replicate MAC address Pool configuration first at destination VMM server #####################


# Get all the MAC address pools from the source server
$macAddressPools = Get-SCMACAddressPool -VMMServer $sourceServer

# Loop through each MAC address pool and create it on the destination server
foreach ($macAddressPool in $macAddressPools) {
    New-SCMACAddressPool -VMMServer $destinationServer -Name $macAddressPool.Name -Description $macAddressPool.Description -StartMACAddress $macAddressPool.StartMACAddress -EndMACAddress $macAddressPool.EndMACAddress | Out-Null
}


#################### Step 3: Lets Replicate Logical Switches configuration first at destination VMM server #####################

# Get all the logical switches from the source server
$logicalSwitches = Get-SCLogicalSwitch -VMMServer $sourceServer

# Loop through each logical switch and create it on the destination server
foreach ($logicalSwitch in $logicalSwitches) {
    New-SCLogicalSwitch -VMMServer $destinationServer -Name $logicalSwitch.Name -Description $logicalSwitch.Description -SwitchType $logicalSwitch.SwitchType -AllowManagementOS $logicalSwitch.AllowManagementOS -AllowRdma $logicalSwitch.AllowRdma -AllowTeaming $logicalSwitch.AllowTeaming -AllowMigrateToPhysicalNetwork $logicalSwitch.AllowMigrateToPhysicalNetwork -AllowArp $logicalSwitch.AllowArp -AllowIeeePriorityTag $logicalSwitch.AllowIeeePriorityTag -AllowDhcp $logicalSwitch.AllowDhcp -AllowBroadcast $logicalSwitch.AllowBroadcast -AllowUnknownUnicast $logicalSwitch.AllowUnknownUnicast -AllowResourcePoolQos $logicalSwitch.AllowResourcePoolQos -AllowSriov $logicalSwitch.AllowSriov -AllowDataCenterBridging $logicalSwitch.AllowDataCenterBridging -AllowIeee8021x $logicalSwitch.AllowIeee8021x -AllowIPsecOffload $logicalSwitch.AllowIPsecOffload -AllowSingleRootIOVirtualization $logicalSwitch.AllowSingleRootIOVirtualization -AllowSwitchEmbeddedTeaming $logicalSwitch.AllowSwitchEmbeddedTeaming -AllowRemoteDirectMemoryAccess $logicalSwitch.AllowRemoteDirectMemoryAccess -AllowSoftwareDefinedNvGRE $logicalSwitch.AllowSoftwareDefinedNvGRE -AllowSoftwareDefinedVXLAN $logicalSwitch.AllowSoftwareDefinedVXLAN -AllowSoftwareDefinedGRE $logicalSwitch.AllowSoftwareDefinedGRE -AllowSoftwareDefinedRdma $logicalSwitch.AllowSoftwareDefinedRdma -AllowSoftwareDefinedQos $logicalSwitch.AllowSoftwareDefinedQos -AllowSoftwareDefinedNetworkVirtualization $logicalSwitch.AllowSoftwareDefinedNetworkVirtualization -AllowSoftwareDefinedSwitchExtension $logicalSwitch.AllowSoftwareDefinedSwitchExtension -AllowSoftwareDefinedSwitchExtensionQos $logicalSwitch.AllowSoftwareDefinedSwitchExtensionQos -AllowSoftwareDefinedSwitchExtensionMetering $logicalSwitch.AllowSoftwareDefinedSwitchExtensionMetering -AllowSoftwareDefinedSwitchExtensionACL $logicalSwitch.AllowSoftwareDefinedSwitchExtensionACL -AllowSoftwareDefinedSwitchExtensionRouting $logicalSwitch.AllowSoftwareDefinedSwitchExtensionRouting -AllowSoftwareDefinedSwitchExtensionLoadBalancing $logicalSwitch.AllowSoftwareDefinedSwitchExtensionLoadBalancing -AllowSoftwareDefinedSwitchExtensionGateway $logicalSwitch.AllowSoftwareDefinedSwitchExtensionGateway -AllowSoftwareDefinedSwitchExtensionRemoteDirectMemoryAccess $logicalSwitch.AllowSoftwareDefinedSwitchExtensionRemoteDirectMemoryAccess -AllowSoftwareDefinedSwitchExtensionIPsecOffload $logicalSwitch.AllowSoftwareDefinedSwitchExtensionIPsecOffload -AllowSoftwareDefinedSwitchExtensionSingleRootIOVirtualization $logicalSwitch.AllowSoftwareDefinedSwitchExtensionSingleRootIOVirtualization -AllowSoftwareDefinedSwitchExtensionEmbeddedTeaming $logicalSwitch.AllowSoftwareDefinedSwitchExtensionEmbeddedTeaming -AllowSoftwareDefinedSwitchExtensionDataCenterBridging $logicalSwitch.AllowSoftwareDefinedSwitchExtensionDataCenterBridging -AllowSoftwareDefinedSwitchExtensionIeee8021x $logicalSwitch.AllowSoftwareDefinedSwitchExtensionIeee8021x -AllowSoftwareDefinedSwitchExtensionIPsec $logicalSwitch.AllowSoftwareDefinedSwitchExtensionIPsec -AllowSoftwareDefinedSwitchExtensionIPsecSiteToSite $logicalSwitch.AllowSoftwareDefinedSwitchExtensionIPsecSiteToSite -Allow



#################### Step 4: Lets Replicate Port Profiles configuration first at destination VMM server #####################


# Get all the port profiles from the source server
$portProfiles = Get-SCPortProfile -VMMServer $sourceServer

# Loop through each port profile and create it on the destination server
foreach ($portProfile in $portProfiles) {
    New-SCPortProfile -VMMServer $destinationServer -Name $portProfile.Name -Description $portProfile.Description -Switch $portProfile.Switch -VLANEnabled $portProfile.VLANEnabled -VLANID $portProfile.VLANID | Out-Null
}

