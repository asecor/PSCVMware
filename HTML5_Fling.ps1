$flingip = Write-Host
$flingcred = Get-Credential #default install its root/demova
$ntpserver = Write-Host

#download server config to c drive
wget https://download3.vmware.com/software/vmw-tools/vsphere_html_client/server-configure.bat -OutFile "C:\server-configure.bat"

#execute 

#check if Posh-SSH module is installed otherwise install it
if (Get-Module -ListAvailable -Name Posh-SSH) {
    Write-Host "Posh-SSH is installed"
} else {
    Write-Host "Installing"
    iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev") #for v3+
}

#connect to fling
New-SSHSession -ComputerName $flingip -Credential $flingcred

#give it some time to connect
Start-Sleep -Seconds 3

#create folders
Invoke-SSHCommand -SessionId 0 -Command "mkdir /etc/vmware/vsphere-client/; mkdir /etc/vmware/vsphere-client/config/; mkdir /etc/vmware/vsphere-client/vsphere-client/"

#copy files 
New-SFTPSession -ComputerName $flingip -Credential $flingcred
Start-Sleep -Seconds 2
Set-SFTPFile -SessionId 0 -LocalFile "C:\webclient.properties" -RemotePath "/etc/vmware/vsphere-client/vsphere-client/webclient.properties"
Start-Sleep -Seconds 2
Set-SFTPFile -SessionId 0 -LocalFile "C:\ds.properties" -RemotePath "/etc/vmware/vsphere-client/config/ds.properties"
Start-Sleep -Seconds 2
Set-SFTPFile -SessionId 0 -LocalFile "C:\store.jks" -RemotePath "/etc/vmware/vsphere-client/store.jks"
Start-Sleep -Seconds 2

#set NTP 
Invoke-SSHCommand -Index 0 -Command "/etc/init.d/vsphere-client ntp_servers $ntpserver"

#cleanup 
