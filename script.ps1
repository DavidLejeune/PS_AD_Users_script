#OU aanmaken

Import-CSV personeel.csv -Delimiter ";" |
Get-Member -MemberType NoteProperty |
Where-Object{$_.name -ne "Voornaam" -and $_.name -ne "Naam" -and $_.name -ne "Account" } |
ForEach-Object {
    try{
        New-ADOrganizationalUnit $_.name
    }
    catch
    {
        "OU already exists, not made anymore"
    }
}

#Merging OU and Accounts in CSV file

Import-CSV personeel.csv -Delimiter ";" |
Select Account, Voornaam, Naam, @{n='OU'; e={
    if($_.Directie -eq "X"){ "Directie" } ;
    if($_.Administratie -eq "X"){"Administratie"} ;
    if($_.Automatisering -eq "X"){ "Automatisering" } ;
    if($_.Productie -eq "X"){ "Productie" };
    if($_.Staf -eq "X"){ "Staf" } ;
    }} |
Export-CSV personeel1.csv -Delimiter ";"



#Add the users
Import-CSV personeel1.csv -Delimiter ";" |
ForEach-Object {
  try{
      $profilepath = "\\DLSV1\UserProfiles\" + $_.Account
      $homedirectory = "\\DLSV1\UserFolders\" + $_.Account
      New-ADUser -Name $_.Account -AccountPassword (ConvertTo-SecureString "Wachtwoord123" -AsPlainText -force) -Enabled 1 -DisplayName $_.Account -SurName $_.Naam -GivenName $_.Voornaam
      $HomeDrive="F:"
      $UserRoot="\\DLSV1\UserFolders\"
      $HomeDirectory=$UserRoot+$_.Account
      SET-ADUSER $_.Account –HomeDrive $HomeDrive –HomeDirectory $HomeDirectory
      #NEW-ITEM –path $HomeDirectory -type directory -force
  }
  catch {
    'Dont know what to do with the user'
  }
}



#Add groups

Import-CSV personeel1.csv -Delimiter ";" |
ForEach-Object {
    $ousingle,$group = $_.OU.split(" ",2)
    $ou = "OU=" + $ousingle + ",OU=PFAfdelingen, DC=POLIFORMADL,DC=COM"
    $grouploc = "OU=" +$group + ",OU=PFAfdelingen, DC=POLIFORMADL,DC=COM"
    try {
        New-ADGroup $ousingle DomainLocal
        New-ADGroup $group  DomainLocal
    }
    catch
    {
        "Group already exists, not made anymore"
    }
}






#move groups to OU

Import-CSV personeel.csv -Delimiter ";" |
Get-Member -MemberType NoteProperty|
where { $_.name -ne "Voornaam" -And $_.name -ne "Naam" -and $_.name -ne "Account" } |
foreach{
    $filter = "(name=" + $_.name +")"
    $filter1 = "OU=" + $_.name + ",DC=POLIFORMADL,DC=COM"
    Get-ADObject -LDAPFilter $filter | where { $_.ObjectClass -eq "group" } |
    Move-ADObject -TargetPath $filter1
}

#Add members to groups and managers
Import-CSV personeel1.csv -Delimiter ";" |
ForEach-Object {
    $users = Get-ADUser $_.Account -Properties MemberOf
    foreach ($user in $users) {
        $userDN = $user.DistinguishedName
        Get-ADGroup -LDAPFilter "(member=$UserDN)" |
        ForEach-Object{
            Remove-ADGroupMember $_.name $userDN -Confirm:$false
        }

    }

}

Import-CSV personeel1.csv -Delimiter ";" |
ForEach-Object {
    $ousingle,$group = $_.OU.split(" ",2)
    $ou = "OU=" + $ousingle + ", DC=POLIFORMADL,DC=COM"
    $grouploc = "OU=" +$group + ", DC=POLIFORMADL,DC=COM"

    try{
        Add-ADGroupMember -Identity $group -Members $_.Account

    }
    catch
    {
        "Member has no second group"
    }
    try {
        Add-ADGroupMember -Identity $ousingle -Members $_.Account
    }
    catch
    {
        "Member not added to group"
    }

    #put user in correct ou

    Get-ADUser $_.Account |
    Move-ADObject -TargetPath $ou

    #managers

    try{
        Set-ADGroup $group -ManagedBy $_.Account
        Set-ADGroup manager -ManagedBy RobertH
    }
    catch {
        "User is no manager"
    }

 }
