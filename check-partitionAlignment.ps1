# check-partitionAlignment; version 2014-05-27, strachotao
#  dok: https://cs.wikipedia.org/wiki/Zarovn%C3%A1n%C3%AD_odd%C3%ADlu

Param (	[Parameter(Mandatory=$false, ValueFromPipeline=$true)]
	[string]$ComputerName = $env:COMPUTERNAME
)

$PhysicalDevices = Get-WmiObject Win32_DiskDrive -ComputerName $ComputerName

foreach ($Device in $PhysicalDevices) {
    $DiskIndex = $Device.Index
    $DeviceModel = $Device.Model
    $DeviceSize = [math]::truncate($Device.Size / 1GB)
    Write-Host "`nDISK $DiskIndex $DeviceModel [$DeviceSize GB]"
    $Partitions = Get-WmiObject Win32_DiskPartition -ComputerName $ComputerName | Where-Object {$_.DiskIndex -eq $DiskIndex}
    foreach ($Partition in $Partitions) {
        $ID = $Partition.Index
        $Offset = $Partition.StartingOffset
        $PartitionSize = [math]::truncate($Partition.Size / 1GB)
        if ($Offset % 4096) {
            Write-Host "+ PARTITION $ID [$PartitionSize GB] is not correctly aligned, offset is $Offset bytes"`
            -BackgroundColor DarkRed 
        } else {
            Write-Host "+ PARTITION $ID [$PartitionSize GB] is correctly aligned, offset is $Offset bytes"
        }
    }              
}
