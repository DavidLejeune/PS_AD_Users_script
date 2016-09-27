break

#List of all domain controllers
Get-ADDomainController -Filter * | Format-Table Name, Domain, Forest, Site, IPv4Address, OperatingSystem

#Account unlock
Read-Host "Enter the user account to unlock" | Unlock-ADAccount

#Password reset
Set-ADAccountPassword (Read-Host 'User') -Reset

