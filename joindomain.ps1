$Domain = "lottefn.vn"
$password = ConvertTo-SecureString "12345a@" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("LOTTEFN\Administrator", $password)

function Set-Random-IP
{
$SubIP = Get-Random -Minimum 128 -Maximum 254
$IP = "10.10.10.$($SubIP)"
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$Gateway = "10.10.10.2"
$Dns = "10.10.10.10"
$IPType = "IPv4"
# Retrieve the network adapter that you want to configure
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
# Remove any existing IP, gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
 $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}
If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
 $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}
 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
 -AddressFamily $IPType `
 -IPAddress $IP `
 -PrefixLength $MaskBits `
 -DefaultGateway $Gateway
# Configure the DNS client server IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS
}

function Join-Domain
{
Add-Computer -DomainName $Domain -Restart -Force -Credential $Cred
}

function Show-Menu
{
    param (
        [string]$Title = 'Auto Join Domain - Author: *VU QUY HOA*'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' Setting random IP Address."
    Write-Host "2: Press '2' Auto Join Domain."
    Write-Host "Q: Press 'Q' to quit."
}

 do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
             Set-Random-IP
         } '2' {
             Join-Domain
         } 
     }
     pause
 }
 until ($selection -eq 'q')