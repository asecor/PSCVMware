$vmhost = Connect-VIServer 10.0.0.114 -User root -Password Password1 #connect to esxi host
$ntpserver = (Read-Host "Enter NTP Server")
[array]$dnsserver = (Read-Host "Enter DNS Servers comma separated")
[array]$vswitch0nics = (Read-Host "Enter vSwitc0 NICs - comma separated") #specify (read-host) vswitch0 nics
[array]$vswitch1nics = (Read-Host "Enter vSwitc1 NICs - comma separated") #specify (read-host) vswitch1 nics

$vMotionPG = (Read-Host "Enter vMotion PortGroup Name")
$vMotionIP = (Read-Host "Enter vMotion IP")
$vMotionSN = (Read-Host "Enter vMotion Subnet Mask")

#$sshserviceport = Get-VMHostFirewallException -Name "SSH Server", "SSh Client" -VMHost $vmhost
#Get-VMHostService | Where-Object {$_.Running -like "False" -and $_.Key -eq "TSM-SSH"} | 

Get-VMHostService | Where-Object {$_.Key -eq "TSM-SSH"} | Set-VMHostService -Policy On | Start-VMHostService #Turn SSH service policy on & start it

Get-AdvancedSetting -Entity $vmhost -Name UserVars.SuppressShellWarning | Set-AdvancedSetting -Value 1 #Disable SSH warning message in vSphere

Add-VMHostNtpServer $ntpserver #Add NTP server
Set-VMHostNetwork -DnsAddress $dnsserver #Add DNS entries


#Configure LoadBalancing by IP Hash
$policy = Get-VirtualSwitch -VMHost $vmhost -Name vSwitch1 | Get-NicTeamingPolicy
$policy | Set-NicTeamingPolicy -LoadBalancingPolicy LoadBalanceIP


#Configure vMotion switch - vmotion portgroup has to already exist
New-VMHostNetworkAdapter -VMHost $vmhost -VirtualSwitch vSwitch1 -PortGroup $vMotionPG -IP $vMotionIP -SubnetMask $vMotionSN -VMotionEnabled $true

<#
$vswitch = Get-VirtualSwitch | Select -Property name #get vswitches
[array]$vswitch0nics = (Read-Host "Enter vSwitc0 NICs - comma separated")#.Split(",") | %{$_.Trim()} #specify (read-host) vswitch0 nics
[array]$vswitch1nics = (Read-Host "Enter vSwitc1 NICs - comma separated")#.Split(",") | %{$_.Trim()} #specify (read-host) vswitch1 nics

do {$vswitch -match "vSwitch0
#> 
