Import-Module ActiveDirectory
Get-ADUser -SearchBase "OU=PFAfdelingen,dc=POLIFORMADL,dc=COM" -Filter * -properties * -ResultSetSize 5000 | select CN ,SAMAccountName, Department, Description , Title,UserPrincipalName, DistinguishedName, HomeDirectory, ProfilePath, Office, OfficePhone, Manager    | convertto-html | out-file C:\Users\Administrator\Desktop\ADUsers.html
Get-ADUser -SearchBase "OU=PFAfdelingen,dc=POLIFORMADL,dc=COM" -Filter * -properties * -ResultSetSize 5000 | select CN ,SAMAccountName, Department, Description , Title,UserPrincipalName, DistinguishedName, HomeDirectory, ProfilePath, Office, OfficePhone, Manager ,Path
Get-ADUser -SearchBase "OU=PFAfdelingen,dc=POLIFORMADL,dc=COM" -Filter * -properties * -ResultSetSize 5000
pause