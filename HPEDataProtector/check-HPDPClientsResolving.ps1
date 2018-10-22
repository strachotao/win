# check-hpdpClientsResolving; version 2015-05-14; strachotao
#   make sure the HP DataProtector clients are nslookable

Param (
    [Parameter(Mandatory = $true)] [string]$cellinfoPath
)

if ($PSVersionTable.PSVersion.Major -le 2) {
    Write-Host "PowerShell v3 or higher required!"
    Break
}

if (!(test-path $cellinfoPath)){
    Write-Host "Given cell_info path is not valid."
    Write-Host "Normally it's c:\ProgramData\OmniBack\Config\Server\cell\cell_info"
    $cellinfoPath = Read-Host "please enter valid cell_info file path"
    if (!(test-path $cellinfoPath)){
        Write-Host "Hm... still nothing, bye!"
        Break
    }
}

$cellcontent = Get-Content $cellinfoPath

foreach ($item in $cellcontent) {
    $hostname = ($item.split(" ")[1]) -replace '"',''

    try {
        $dnsout = [System.Net.Dns]::GetHostAddresses("$hostname")
        $ip = $dnsout.IPAddressToString
        Write-Host "$hostname = $ip"
    }

    catch {
        Write-Host "$hostname = not found, remove this host from HPDP clients"
    }
}
