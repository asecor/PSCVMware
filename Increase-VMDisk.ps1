$vm = IISDEVVM01
$disk = "Hard disk 1"

Get-HardDisk -vm $vm | Where {$_.Name -eq $disk} | Set-HardDisk -CapacityGB 100 -Confirm:$false

Invoke-Command -ComputerName $vm -ScriptBlock {
$size = Get-PartitionSupportedSize -DriveLetter C 
Resize-Partition -DriveLetter C -Size $size.SizeMax
}
