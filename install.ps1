Write-Output "[container] waiting for network"
While (((Get-NetIPAddress | ? AddressFamily -eq IPv4 | ? IPAddress -ne 127.0.0.1).SuffixOrigin -ne "Manual") -and ((Get-NetIPAddress | ? AddressFamily -eq IPv4 | ? IPAddress -ne 127.0.0.1).SuffixOrigin -ne "Dhcp"))
{
    Sleep -Milliseconds 10
}

$tempdir = Join-Path -Path $env:temp -ChildPath "$(Get-Date -format 'yyyyMMddhhmmss')"
# nodejs 6 not working in container
# $sourceuri = 'https://nodejs.org/dist/v6.3.1/node-v6.3.1-x64.msi'
$sourceuri = 'https://nodejs.org/dist/v5.12.0/node-v5.12.0-x64.msi'
$installer = Join-Path $tempdir (Split-Path $sourceuri -Leaf)
$installerpath = Join-Path -Path $tempdir -ChildPath $installer
$log = Join-Path -Path $tempdir -ChildPath "$(Split-Path $sourceuri -Leaf).log"

If (-not (Test-Path $tempdir))
{
    Write-Output "[container] Creating Temp directory $tempdir"
    New-Item -Path $tempdir -ItemType Directory | Out-Null
}
New-Item -Path (Join-Path -Path $env:SystemDrive -ChildPath "log") -ItemType Directory | Out-Null

# Wait for IP address - either manually assigned (e.g. through NAT) or via DHCP server
Write-Output "[container] Waiting for network"
While (((Get-NetIPAddress | ? AddressFamily -eq IPv4 | ? IPAddress -ne 127.0.0.1).SuffixOrigin -ne "Manual") -and ((Get-NetIPAddress | ? AddressFamily -eq IPv4 | ? IPAddress -ne 127.0.0.1).SuffixOrigin -ne "Dhcp")) {Sleep -Milliseconds 10}

Write-Output "[container] Downloading sources from $sourceuri"
Invoke-WebRequest -Uri $sourceuri -OutFile $installer -UseBasicParsing
    

# run installer
Write-Output "[container] Running installer: msiexec /i $installer /qn /l*v $log"
Start-Process -FilePath msiexec -ArgumentList "/i $installer","/qn","/l*v $log" -NoNewWindow -Wait

# wait for msiexec
If (Get-Process msiexec -EA 0)
{
    Write-Output "[container] Waiting for msiexec to finish"
    # If msiexec is still running, wait for all msiexec processes to finish.
    Wait-Process msiexec
}

# remove sources
Write-Output "[container] Removing $tempdir"
Remove-Item -Path $tempdir -Recurse -Force