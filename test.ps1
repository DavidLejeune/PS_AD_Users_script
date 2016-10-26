Import-Module ActiveDirectory

Write-Host "Removing all users from groups"
Write-Host "------------------------------"
Write-Host ""

#Choose Organizational Unit
$Count=0
$UserpathOU="Directie"
$SearchBase = "OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
$Users = Get-ADUser -filter * -SearchBase $SearchBase -Properties MemberOf
ForEach($User in $Users){
    $User.MemberOf | Remove-ADGroupMember -Member $User -Confirm:$false
    $Count=$Count+1
}
Write-Host "Removed $($Count) user(s) from $($UserpathOU)"


#Choose Organizational Unit
$Count=0
$UserpathOU="Administratie"
$SearchBase = "OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
$Users = Get-ADUser -filter * -SearchBase $SearchBase -Properties MemberOf
ForEach($User in $Users){
    $User.MemberOf | Remove-ADGroupMember -Member $User -Confirm:$false
    $Count=$Count+1
}
Write-Host "Removed $($Count) user(s) from $($UserpathOU)"


#Choose Organizational Unit
$Count=0
$UserpathOU="Automatisering"
$SearchBase = "OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
$Users = Get-ADUser -filter * -SearchBase $SearchBase -Properties MemberOf
ForEach($User in $Users){
    $User.MemberOf | Remove-ADGroupMember -Member $User -Confirm:$false
    $Count=$Count+1
}
Write-Host "Removed $($Count) user(s) from $($UserpathOU)"


#Choose Organizational Unit
$Count=0
$UserpathOU="Productie"
$SearchBase = "OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
$Users = Get-ADUser -filter * -SearchBase $SearchBase -Properties MemberOf
ForEach($User in $Users){
    $User.MemberOf | Remove-ADGroupMember -Member $User -Confirm:$false
    $Count=$Count+1
}
Write-Host "Removed $($Count) user(s) from $($UserpathOU)"

#Choose Organizational Unit
$Count=0
$UserpathOU="Staf"
$SearchBase = "OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
$Users = Get-ADUser -filter * -SearchBase $SearchBase -Properties MemberOf
ForEach($User in $Users){
    $User.MemberOf | Remove-ADGroupMember -Member $User -Confirm:$false
    $Count=$Count+1
}
Write-Host "Removed $($Count) user(s) from $($UserpathOU)"
