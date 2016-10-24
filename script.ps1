#OU aanmaken

Import-CSV C:\personeel.csv -Delimiter ";" |
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

Import-CSV C:\personeel.csv -Delimiter ";" |
Select Account, Voornaam, Naam, @{n='OU'; e={
    if($_.Manager -eq "X"){ "Manager" } ;
    if($_.IT -eq "X"){"IT"} ;
    if($_.Boekhouding -eq "X"){ "Boekhouding" } ;
    if($_.Logistiek -eq "X"){ "Logistiek" };
    if($_.ImportExport -eq "X"){ "ImportExport" } ;
    }} |
Export-CSV C:\personeel1.csv -Delimiter ";"














#Add the users
Import-CSV C:\personeel1.csv -Delimiter ";" |
Foreach-Object {
    try{
        $profilepath = "\\SRV1\UserProfiles\" + $_.Account
        $homedirectory = "\\SRV1\UserFolders\" + $_.Account
        New-ADUser -Name $_.Account -AccountPassword (ConvertTo-SecureString "Wachtwoord123" -AsPlainText -force) -Enabled 1 -DisplayName $_.Account -SurName $_.Naam -GivenName $_.Voornaam
        $HomeDrive=’U:’
        $UserRoot=’\\SRV1\UserFolders\’
        $HomeDirectory=$UserRoot+$_.Account
        SET-ADUSER $_.Account –HomeDrive $HomeDrive –HomeDirectory $HomeDirectory
        NEW-ITEM –path $HomeDirectory -type directory -force
    }
    catch {

    }
}

#Add groups

Import-CSV C:\personeel1.csv -Delimiter ";" |
ForEach-Object {
    $ousingle,$group = $_.OU.split(" ",2)
    $ou = "OU=" + $ousingle + ", DC=smg31,DC=be"
    $grouploc = "OU=" +$group + ", DC=smg31,DC=be"
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

Import-CSV C:\personeel.csv -Delimiter ";" |
Get-Member -MemberType NoteProperty|
where { $_.name -ne "Voornaam" -And $_.name -ne "Naam" -and $_.name -ne "Account" } |
foreach{
    $filter = "(name=" + $_.name +")"
    $filter1 = "OU=" + $_.name + ",DC=smg31,DC=be"
    Get-ADObject -LDAPFilter $filter | where { $_.ObjectClass -eq "group" } |
    Move-ADObject -TargetPath $filter1
}

#Add members to groups and managers
Import-CSV C:\personeel1.csv -Delimiter ";" |
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

Import-CSV C:\personeel1.csv -Delimiter ";" |
ForEach-Object {
    $ousingle,$group = $_.OU.split(" ",2)
    $ou = "OU=" + $ousingle + ", DC=smg31,DC=be"
    $grouploc = "OU=" +$group + ", DC=smg31,DC=be"

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
