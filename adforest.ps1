function Set-Static-IP
{
### Setting static IP Address and DNS ###
$IP = "10.10.10.10"
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$Gateway = "10.10.10.2"
$Dns = "10.10.10.10" # DNS it-self
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

function AD-Promote
{
### Promote to ADDSForest ###
$dsrmPassword = (ConvertTo-SecureString -AsPlainText -Force -String "Pa$$w0rd123")
# Install ADDS Role
Install-WindowsFeature -Name AD-Domain-Services
# Add Remote ADDS Tools
ADD-WindowsFeature RSAT-ADDS-Tools
# Install ADDS Forest
#Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold" -DomainName "lottefn.vn" -DomainNetbiosName "LOTTEFN" -ForestMode "WinThreshold" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -SafeModeAdministratorPassword $dsrmPassword -Confirm:$false -Force:$true
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "lottefn.vn" `
-DomainNetbiosName "LOTTEFN" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-SafeModeAdministratorPassword $dsrmPassword `
-Confirm:$false `
-Force:$true
}
 
function Import-Bulk-Users
{  
### Import data to Active Directory ###
# Import active directory module for running AD cmdlets
Import-Module activedirectory
# Create LFVN OU
$NewOU = "LFVN"
$ConvertToDN = "OU=$NewOU,DC=lottefn,DC=vn"
if (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $ConvertToDN})
{
    Write-Warning "A $NewOU OU already exist in Active Directory"
}
Else
{
New-ADOrganizationalUnit -Name $NewOU -Path "DC=lottefn,DC=vn"
}
#Download CSV Files 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget https://raw.githubusercontent.com/qhoa/adds/master/bulk_users1.csv -OutFile bulk_users1.csv
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv .\bulk_users1.csv

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$Username 	= $User.username
	$Password 	= $User.password
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
	$OU 		= $User.ou #This field refers to the OU the user account is to be created in
    $email      = $User.email
    $streetaddress = $User.streetaddress
    $city       = $User.city
    $zipcode    = $User.zipcode
    $state      = $User.state
    $country    = $User.country
    $telephone  = $User.telephone
    $jobtitle   = $User.jobtitle
    $company    = $User.company
    $department = $User.department
    $Password = $User.Password


	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@lottefn.vn" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -City $city `
            -Company $company `
            -State $state `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
            
	}
}
}

function Show-Menu
{
    param (
        [string]$Title = 'AD DS Automation Tools - Author: *VU QUY HOA*'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' Setting static IP Address."
    Write-Host "2: Press '2' Promote AD New Forest."
    Write-Host "3: Press '3' Import Bulk Users."
    Write-Host "Q: Press 'Q' to quit."
}

 do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
             Set-Static-IP
         } '2' {
             AD-Promote
         } '3' {
             Import-Bulk-Users
         }
     }
     pause
 }
 until ($selection -eq 'q')