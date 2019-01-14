# new-userdir; version 2018-01-14; strachotao
# vytvori adresar uzivatele a nastavi mu ACL: SYSTEM(rwx), $username(rwx), Administrators(rwx)
# pokud uzivatelske jmeno neexistuje, vytvori jen adresar
#
# parametry:
# $username = jmeno uzivatele
# $path = cesta, ve ktere bude adresar $username vytvoren
#
# priklad: 
# .\new-userdir.ps1 -username novakj -path c:\temp
# vytvori adresar c:\temp\novakj a nastavi mu ACL: SYSTEM(rwx), novakj(rwx), Administrators(rwx)
#
# pouziti:
# .\new-userdir.ps1 -username osx -path c:\temp
#
# pouziti v cyklu pro vice uzivatelu najednou:
# foreach ($user in ('olie', 'petr', 'martin')) {.\new-userdir.ps1 -username $user -path c:\temp}

Param (
    [Parameter(Mandatory=$true)][string]$username,
    [Parameter(Mandatory=$true)][string]$path
)

$id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$p = New-Object System.Security.Principal.WindowsPrincipal($id)
if(!($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host "You must be an administrator!`nExit!" -Foreground Red
    Break
}

if (!(Test-Path $path)) {
    Write-Host "Given dir $path doesn't exist!" -Foreground Red
    Break
}

$fullPath = "$path\$username"

try {
    if (Test-Path $fullPath) {
        Write-Host "Directory $fullPath already exists =>" -ForegroundColor Green -NoNewline
    } else {
        New-Item -ItemType directory -Path $fullPath > $null
        Write-Host "Directory $fullPath created. " -ForegroundColor Green -NoNewline
    }
}

catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "Creating directory $fullPath failed! $ErrorMessage" -ForegroundColor Red
    Break
}

try {
    $acl = Get-Acl $fullPath
    $acl.SetAccessRuleProtection($True, $False)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("System","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$username","Modify, Synchronize", "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl $fullPath $acl
    Write-Host "ACL OK " -Foreground green
}

catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "Can't set ACL: $ErrorMessage" -ForegroundColor Red
}
