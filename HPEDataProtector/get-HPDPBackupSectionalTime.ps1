# get-HPDPBackupSectionalTime; version 2015-02-09; strachotao
#   vygrepuje z logu session ulozene rucne do souboru
#   doby trvani dilcich zaloh; prakticke pri hledani v logu
#   kde je 10+ serveru v jedne backup session
Param (
    [Parameter(Mandatory = $true)][string]$SourceFile
)

$rawData = Get-Content $SourceFile
$lines = Select-String $SourceFile -Pattern "STARTING" -CaseSensitive

foreach ($line in $lines.LineNumber) { 
    $line2index = $line-1
    $line1index = $line-2
    Write-host "$($rawData[$line1index])`n$($rawData[$line2index])`n"
}

Write-Host "count of STARTING Disk Agent: $($lines.Count)"
