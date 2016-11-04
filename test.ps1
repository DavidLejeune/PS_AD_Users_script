$Count=0
$UserpathOU="Directie"
$SearchBase = "OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
$Users = Get-ADUser -filter * -SearchBase $SearchBase -Properties MemberOf
ForEach($User in $Users){
    if ($User.Enabled -eq $True) {
      Write-Host "enabled"
    }
    $User.MemberOf | Remove-ADGroupMember -Member $User -Confirm:$false
    $Count=$Count+1
}
