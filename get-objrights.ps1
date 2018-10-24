# get-objrights; verze 2018-06-11 1649; strachotao
#  vypise opravneni na kazdem objektu do souboru $outfile
#   
#  pouziti
#
#  vypise prava vsech objektu z adresare c:\temp
#    .\soubory-prava.ps1 -dir c:\temp
#
#  vypise prava objektu nalezici uzivateli *admin* (wildcard maska)
#    .\soubory-prava.ps1 -dir c:\temp -user admin
#  
Param (
    [Parameter(Mandatory=$false)][string]$user="all",
    [Parameter(Mandatory=$true)][string]$dir  
)

$ErrorActionPreference = 'SilentlyContinue'
$tik = [System.DateTime]::Now.ToString("yyyyMMdd-HHmmss")
$outfile = "c:\temp\prava-$($user)-$($tik).csv"

Write-Progress -Activity "Nacitam seznam souboru..."
$dirList = Get-ChildItem "$dir" -Recurse -ErrorAction SilentlyContinue

$filesCount = $dirList.Length

$counter = 0

Add-Content -Path $outfile "adresar;uzivatel;pravo;typ;zdedeno"

function Writer() {
    Add-Content -Path $outfile "$($file.fullname);$($item.IdentityReference);$($item.FileSystemRights);$($item.AccessControlType);$($item.IsInherited)"
}

foreach ($file in $dirList) {

    Write-Progress -Activity "Nacitam opravneni" -status "$file" -percentComplete ($counter/$filesCount*100)

    $Acl = (Get-Acl -Path $file.fullname -Verbose)
    $rawData = $acl.GetAccessRules($true, $true, [System.Security.Principal.NTAccount])            

    foreach ($item in $rawData) {
        if ($user -eq 'all') {
            Writer
        }        
        elseif ($($item.IdentityReference) -ilike "*$user*") {            
            Writer
        }
    }    
    $counter++
}

Write-Host "hotovo, vystup je v $outfile"
