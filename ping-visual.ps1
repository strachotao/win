<#  ping-visual; verze 2018-03-18; strachotao
.Synopsis
    Visual ping
.DESCRIPTION
    Displays colored ping output in one line
.EXAMPLE
    .\ping-Visual -target server
.EXAMPLE    
    .\ping-Visual -target server -waitUntilNextCycle=10 -displayOKStatus=$false
#>

Param (
    [Parameter(Mandatory = $true)] [string]$target,
    [Parameter(Mandatory = $false)] [int]$waitUntilNextCycle=5,
    [Parameter(Mandatory = $false)] [boolean]$displayOKStatus=$true
)

$ping = New-Object System.Net.NetworkInformation.Ping
 
function Get-Timestamp {
    return [System.DateTime]::Now.ToString('HH:mm:ss')
}
 
if (!$displayOkStatus) {
    Write-Warning "Only connection errors are being displayed!"
}
 
while ($true) {
    Start-Sleep -Seconds $waitUntilNextCycle
    try {
        $res = $ping.send($target)
        $time = $res.RoundtripTime
        $status = $res.Status
        if ($status -ilike "Success") {
            if ($displayOkStatus) {
                Write-Host "[$(Get-Timestamp) OK t=$time]" -NoNewline -BackgroundColor DarkGreen -ForegroundColor White
            }
        } else {
            Write-Host "[$(Get-Timestamp) $status t=$time]" -NoNewline -BackgroundColor DarkRed -ForegroundColor White
        }
    }
    catch {
        Write-Host "[$(Get-Timestamp) DNS or network error]" -NoNewline -BackgroundColor Magenta -ForegroundColor White
    }
}
