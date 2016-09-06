# Variables which need to be adjusted depending on the VM which is being deployed.
# You can use - Get-Cluster Cluster1 | Get-Datastore -Name *GOLD* | Where-Object {$_.FreeSpaceGB -gt "500"} - to find a gold LUN with enough capacity, then modify the $datastore variable below
#
 
 
$template = "WIN_2012R2"
$customspec = "IT_CustSpec"
$resoucepool = Read-Host "What is the cluster?"             # "Cluster1"
Get-Cluster $resoucepool | Get-Datastore -Name *GOLD* | Where-Object {$_.FreeSpaceGB -gt "500"}
$datastore = Read-Host "What is the datastore?"             # "LUN11-GOLD"
$storageformat = "EagerZeroedThick"
$2ndnetwork = Read-Host "What is the port group?"           # "Prod-VLAN"
$location = Read-Host "What is the folder destination?"     # "SQL Clusters"
$tag = Read-Host "What is the tag? (Prod/Dev/Test)"         # "Prod"
$cattag = Read-Host "What is the category? (SQL/App/etc)"   # "SQL"
$strDescription = Read-Host "What is the description?"      # "SQL Cluster Node 1"
$VMName = Read-Host "What is the VM name?"                  # "VMPRODSQL01"

New-VM -Name $VMName -Template $template -Datastore $datastore -ResourcePool $resoucepool -DiskStorageFormat $storageformat -Location $location
Sleep -Seconds 5

#Get-VM $VMName | New-HardDisk -CapacityGB 1 | New-ScsiController -Type ParaVirtual -BusSharingMode Physical
#sleep -Seconds 2
#Get-VM $VMName | Remove-HardDisk -DeletePermanently
#sleep -Seconds 3
#Get-VM $VMName | New-HardDisk -DiskPath "[datastore1]" | New-ScsiController -Type ParaVirtual -BusSharingMode Physical
 
 
#Customize OS
Set-VM -VM $VMName -OSCustomizationSpec $customspec -Confirm:$false
Sleep -Seconds 2
 
#Add 2nd NIC adapter
Get-VM $VMName | New-NetworkAdapter -Type Vmxnet3 -StartConnected -NetworkName $2ndnetwork
Sleep -Seconds 10
 
#Disable memory hot add
$vmview = Get-VM $VMName | Get-View
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$extra = New-Object VMware.Vim.optionvalue
$extra.Key="mem.hotadd"
$extra.Value="false"
$vmConfigSpec.extraconfig += $extra
$vmview.ReconfigVM($vmConfigSpec)
sleep -Seconds 2
 
#Disable CPU hot add
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$extra = New-Object VMware.Vim.optionvalue
$extra.Key="vcpu.hotadd"
$extra.Value="false"
$vmConfigSpec.extraconfig += $extra
$vmview.ReconfigVM($vmConfigSpec)
sleep -Seconds 2
 
Start-VM -VM $VMName -Confirm:$false
