# Description
# -----------
# Active Directory Management tool
# Created for Task1 Operating Systems Windows 2 @ Vives
#
# Author : David Lejeune
# Created : 27/09/2016
# School : Vives
# Course : Operating Systems Windows 2
# Class : 3PB-ICT
# Group : 2
#
# Task goals
# ----------
# Manage an Active Directory on Windows Server 2012 R2
# 1)Bulk create users based on csv (OK)
# 2)Update users based on weekly csv updates (TBD)



#------------------------------------------------------------------------------
#Imports

Import-Module ActiveDirectory

#------------------------------------------------------------------------------
#Script Variables
$DC1 = "Cynalco"
$DC2 = "be"

$Menu = ""
$Menu1 = "Create new OU";
$Menu2 = "New User"
$Menu3 = "Bulk Usermanagement based on CSV"
$Menu4 = "Check User existence"
$Menu5 = "Bulk delete User from CSV"
$Menu6 = "Show all users"
$Menu7 = "Delete a user"
$Menu99 = "Show Description"


#------------------------------------------------------------------------------
#Functions
function Show-Description()
{
  #feeding the narcistic beast
  Write-Host "# Description" -ForegroundColor white
  Write-Host "# -----------" -ForegroundColor white
  Write-Host "# Active Directory Management tool" -ForegroundColor yellow
  Write-Host "# Created for Task1 Operating Systems Windows 2 @ Vives" -ForegroundColor yellow
  Write-Host ""
  Write-Host "# Author : David Lejeune" -ForegroundColor magenta
  Write-Host "# Created : 27/09/2016" -ForegroundColor magenta
  Write-Host "# School : Vives" -ForegroundColor magenta
  Write-Host "# Course : Operating Systems Windows 2" -ForegroundColor magenta
  Write-Host "# Class : 3PB-ICT" -ForegroundColor magenta
  Write-Host "# Group : 2" -ForegroundColor magenta
  Write-Host ""
  Write-Host "# Task goals" -ForegroundColor red
  Write-Host "# ----------" -ForegroundColor red
  Write-Host "# Manage an Active Directory on Windows Server 2012 R2" -ForegroundColor gray
  Write-Host "# 1)Bulk create users based on csv (OK - Tested)" -ForegroundColor darkgreen
  Write-Host "# 2)Update users based on weekly csv updates (1/2 OK - TBTested)" -ForegroundColor darkcyan
  Write-Host ""
}

function Create-OU()
{
    #create top level OU (needs to worked out further for depth)
    $OUname = Read-Host -Prompt '> OU name ';
    New-ADOrganizationalUnit $OUname ;
}

function Create-User()
{
    #Create user based on user input
    $UserFirstname = Read-Host -Prompt '> given name ';
    $UserLastname = Read-Host -Prompt '> surname ';
    $Displayname = $UserFirstname + " " + $UserLastname;
    $SAM = Read-Host -Prompt '> SAM account name ';
    $UserpathOU = Read-Host -Prompt '> OU ';
    $UPN = "$($SAM)@Cynalco.be"
    $pathOU = "ou=$($UserpathOU),ou=CMAfdelingen,dc=Cynalco,dc=be"
    New-ADUser -Department:"$($UserpathOU)" -DisplayName:"$($Displayname)" -GivenName:"$($UserFirstname)" -Name:"$($Displayname)" -Path:"OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -SamAccountName:"$($SAM)" -Server:"CrispyMcBacon.Cynalco.be" -Surname:"$($UserLastname)" -Type:"user" -UserPrincipalName:"$($SAM)@Cynalco.be" -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) -Enabled $true
}

function Delete-User()
{
    Show-Users
    #Delete user based on user input
    $SAM = Read-Host -Prompt '> SAM account name ';

    #Check user existence
    if (dsquery user -samid $SAM)
    {
      "Found user"
      remove-aduser -identity $SAM #-confirm:$false
      Show-Users
      if (dsquery user -samid $SAM){"User unsuccesfully deleted"}
      else {"User succesfully deleted"}
    }
    else
    {
      "Did not find user"
    }
}

function Show-Users()
{
    $sw = [Diagnostics.Stopwatch]::StartNew()
    #log users and show them
    Get-ADUser -SearchBase "OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select identity ,CN ,SAMAccountName, Department, Description , Title,UserPrincipalName, DistinguishedName, HomeDirectory, ProfilePath, Office, OfficePhone, Manager    | convertto-html | out-file ADUsers.html
    Get-ADUser -SearchBase "dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select DistinguishedName,SAMAccountName, Department | format-table -autosize
}

function Check-UserExistence()
{
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $SAM = Read-Host -Prompt '> Enter SamAccountName ';
    if (dsquery user -samid $SAM){"Found user"}
    else {"Did not find user"}
}

function Bulk-UserDelete()
{
  $sw = [Diagnostics.Stopwatch]::StartNew()

  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  #header of table
  Write-Host "Get ready for the magic ...`n" -ForegroundColor Gray
  Write-Host "Deleting users`n" -ForegroundColor white
  Write-Host "SAM      `tExists?      `t`tAction     `t`t`tOU" -ForegroundColor Yellow
  Write-Host "---      `t-------   `t`t------     `t`t`t--" -ForegroundColor Yellow

  #loop through all users
  foreach ($User in $Users)
  {
      #get csv Variables
      $Displayname = $User.Voornaam + " " + $User.Naam
      $UserFirstname = $User.Naam
      $UserLastname = $User.Voornaam
      $UserAccount = $User.Account
      $SAM = $UserAccount
      $UPN = "$($SAM)@Cynalco.be"
      $OU = ""
      $DistinguishedName = "CN=" + $Displayname + ","

      #find the department
      $Manager = $User.Manager
      $IT = $User.IT
      $Boekhouding =  $User.Boekhouding
      $Logistiek = $User.Logistiek
      $ImportExport = $User.ImportExport
      $UserpathOU = ""

      if ($Manager -eq "X")
      {
        $UserpathOU = "Management"
        $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
      }
      else
      {
          if ($ImportExport -eq "X")
          {
            $UserpathOU = "ImportExport"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($Logistiek -eq "X")
          {
            $UserpathOU = "Logistiek"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($Boekhouding -eq "X")
          {
            $UserpathOU = "Boekhouding"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($IT -eq "X")
          {
            $UserpathOU = "IT"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
      }
      $DistinguishedName = "$($DistinguishedName)OU=CMAfdelingen,DC=Cynalco,dc=be,"

        $Result = ""
        $Result2 = ""
        if (dsquery user -samid $SAM)
        {
          $Result = "User Found"
          remove-aduser -identity $SAM -confirm:$false

          #Check after deletion if user exists now
          if (dsquery user -samid $SAM)
          {
            $Result2 =  "Unsuccesfull in deleting user"
          }
          else
          {
            $Result2 =  "User succesfully deleted"
          }
        }
        else
        {
          $Result = "User not found"
          $Result2 =  "No action required"
        }
        Write-Host $SAM"      `t"$Result"`t`t"$Result2"      `t"$UserpathOU  -ForegroundColor Red
  }

  Write-Host ""
  Write-Host " *** Finished bulk deleting users *** " -ForegroundColor blue
}

function Bulk-UserManagement()
{

  # first diable the user not found in csv
  Remove-UnfoundUser
  #main task
  #create users based on csv date
  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  Write-Host "`nCrunching data like a boss"  -ForegroundColor red
  Write-Host "Get ready for the magic ...`n"  -ForegroundColor red
  Write-Host "Creating users`n" -ForegroundColor white
  Write-Host "SAM      `tExists?      `t`tAction     `t`t`tOU`t`t     `tSubgroup"  -ForegroundColor yellow
  Write-Host "---      `t-------   `t`t------     `t`t`t--`t`t     `t--------" -ForegroundColor yellow

  #loop through all users
  foreach ($User in $Users)
  {
      $Displayname = $User.Voornaam + " " + $User.Naam
      $UserFirstname = $User.Naam
      $UserLastname = $User.Voornaam
      $UserAccount = $User.Account
      $SAM = $UserAccount
      $UPN = "$($SAM)@Cynalco.be"
      $OU = ""
      $DistinguishedName = ""
      $BossName = ""

      $Manager = $User.Manager
      $IT = $User.IT
      $Boekhouding =  $User.Boekhouding
      $Logistiek = $User.Logistiek
      $ImportExport = $User.ImportExport

      $UserpathOU = ""
      if ($Manager -eq "X")
      {
        $UserpathOU = "Management"
        $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
      }
      else
      {
          if ($ImportExport -eq "X")
          {
            $UserpathOU = "ImportExport"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($Logistiek -eq "X")
          {
            $UserpathOU = "Logistiek"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($Boekhouding -eq "X")
          {
            $UserpathOU = "Boekhouding"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($IT -eq "X")
          {
            $UserpathOU = "IT"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
      }

        $DistinguishedName = "$($DistinguishedName)OU=CMAfdelingen,DC=Cynalco,dc=be,"

        $Result = ""
        $Result2 = ""

        if (dsquery user -samid $SAM)
        {
          $Result = "User Found   "

          # if user exists remove them from groups and retarget so an update puts them in the correct path
          $user = "CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be"
          Get-ADPrincipalGroupMembership -Identity $user | where {$_.Name -ne "Domain Users"} | % {Remove-ADPrincipalGroupMembership -Identity $user -MemberOf $_}
          # retarget to catch updates
          Get-ADUser $SAM| Move-ADObject -TargetPath "OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be"
          # rename department
          Get-ADUser $SAM| Set-ADUser -Department $UserpathOU

          #making sure if a former user (disabled) is found that he is set active again
          $ActiveUser = Get-ADUser -Identity $SAM
          if ($ActiveUser.Enabled -eq $False)
          {
              Enable-ADAccount -Identity $SAM
              $Result2 =  "Reactivated former user      "
          }
          else{

              $Result2 =  "Update user                  "
          }

        }
        else
        {
          $Result = "User not found"

          #create the user and assign to OU
          New-ADUser -ChangePasswordAtLogon:$true -Department:"$($UserpathOU)" -DisplayName:"$($Displayname)" -GivenName:"$($UserFirstname)" -Name:"$($Displayname)" -Path:"OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -SamAccountName:"$($SAM)" -Server:"CrispyMcBacon.Cynalco.be" -Surname:"$($UserLastname)" -Type:"user" -UserPrincipalName:"$($SAM)@Cynalco.be" -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) -Enabled $true

          #Check after creation if user exists now
          if (dsquery user -samid $SAM)
          {
            $Result2 = "User succesfully created     "
          }
          else
          {
            $Result2 = "Unsuccesfull in creating user"
          }

          ##################################################################
          # BLOCK THAT HELPS DISPLAY ALL THE BEAUTIFUL STUFF but only for new users
           #assign to the correct principal group
           $UserpathOU = ""
           $Boss = "False"
           $countDepartments = 0
           if ($Manager -eq "X")
           {
             $UserpathOU = "Management"
             $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
             $Boss = "True"
             Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
           }
           else
           {
               if ($ImportExport -eq "X")
               {
                 $UserpathOU = "ImportExport"
                 $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
                 $countDepartments = $countDepartments + 1
               }
               if ($Logistiek -eq "X")
               {
                 $UserpathOU = "Logistiek"
                 $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
                 $countDepartments = $countDepartments + 1
               }
               if ($Boekhouding -eq "X")
               {
                 $UserpathOU = "Boekhouding"
                 $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
                 $countDepartments = $countDepartments + 1
               }
               if ($IT -eq "X")
               {
                 $UserpathOU = "IT"
                 $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
                 $countDepartments = $countDepartments + 1
               }
               Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
           }

           #assigning to possible (sub) groups
           $UserpathOU = ""
           $Boss = "False"
           $SubOU = ""
           if ($Manager -eq "X")
           {
             $UserpathOU = "Management"
             $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
             $Boss = "True"
             Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
             $countDepartments = $countDepartments + 1

             if ($ImportExport -eq "X")
             {
               $SubOU = "ImportExport"
               $DistinguishedName = "OU=$($UserpathOU),"
               Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
               $countDepartments = $countDepartments + 1
               #Set-ADGroup -Identity:"CN=Manager,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
               Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
             }
             if ($Logistiek -eq "X")
             {
               $SubOU = "Logistiek"
               $DistinguishedName = "OU=$($UserpathOU),"
               Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
               $countDepartments = $countDepartments + 1
               Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
             }
             if ($Boekhouding -eq "X")
             {
               $SubOU = "Boekhouding"
               $DistinguishedName = "OU=$($UserpathOU),"
               Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
               $countDepartments = $countDepartments + 1
               Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
             }
             if ($IT -eq "X")
             {
               $SubOU = "IT"
               $DistinguishedName = "OU=$($UserpathOU),"
               Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
               $countDepartments = $countDepartments + 1
               Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
             }
           }
           else
           {

               if ($ImportExport -eq "X")
               {
                 $UserpathOU = "ImportExport"
                 $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
               }
               if ($Logistiek -eq "X")
               {
                 $UserpathOU = "Logistiek"
                 $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
               }
               if ($Boekhouding -eq "X")
               {
                 $UserpathOU = "Boekhouding"
                 $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
               }
               if ($IT -eq "X")
               {
                 $UserpathOU = "IT"
                 $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
               }
               Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
           }

           #used to see if the big boss exists ($boss true and count 1)
           if ($Manager -eq "X")
           {
             if ($countDepartments -eq 1)
               {
                 $SubOU = "Management"
                 Set-ADGroup -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
                 #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Replace:'manager'="CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
                 #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"
                 #Get-ADUser -SearchBase "OU=$($UserpathOU),dc=Cynalco,dc=be" -Filter * -ResultSetSize 5000 | Select Name,SamAccountName
                 #Write-Host "Setting manager $($Displayname) for users in $($SubOU) "
                 #Get-ADUser -SearchBase "OU=$($UserpathOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select SAMAccountName # Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"

               }
           }
         # END OF BLOCK THAT HELPS DISPLAY ALL THE BEAUTIFUL STUFF for new users
         ##################################################################
        }
        If ($Result -eq "User not found")
        {
          Write-Host "$($SAM)      `t$($Result)`t`t$($Result2)`t$($UserpathOU)     `t`t$($SubOU)" -ForegroundColor cyan
        }
        else
        {
          Write-Host "$($SAM)      `t$($Result)`t`t$($Result2)`t$($UserpathOU)     `t`t$($SubOU)" -ForegroundColor Magenta

        }
  }
  Write-Host ""
  Write-Host " *** Finished creating new users and adding them to the correct OU *** `n"-ForegroundColor blue
  Clear-Groups
  Set-Group
  Set-Manager
}

function Remove-GroupMembershipDL()
{
  $SearchBase = "OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be"
  $Users = Get-ADUser -filter * -SearchBase $SearchBase -Properties MemberOf
  ForEach($User in $Users){
      if ($User.Enabled -eq $True) {
        $User.MemberOf | Remove-ADGroupMember -Member $User -Confirm:$false
        $Count=$Count+1
      }
      else
      {

      }
  }
  Write-Host "Removed $($Count) user(s) from $($UserpathOU)" -ForegroundColor red
}

function Clear-Groups()
{
  Write-Host "Removing all active users from groups" -ForegroundColor white;
  Write-Host "" -ForegroundColor yellow;

  #Choose Organizational Unit
  $Count=0
  $UserpathOU="IT"
  Remove-GroupMembershipDL

  #Choose Organizational Unit
  $Count=0
  $UserpathOU="Boekhouding"
  Remove-GroupMembershipDL

  #Choose Organizational Unit
  $Count=0
  $UserpathOU="Logistiek"
  Remove-GroupMembershipDL

  #Choose Organizational Unit
  $Count=0
  $UserpathOU="ImportExport"
  Remove-GroupMembershipDL


  #Choose Organizational Unit
  $Count=0
  $UserpathOU="Management"
  Remove-GroupMembershipDL


  Write-Host ""
  Write-Host " *** Finished clearing all users in groups *** `n" -ForegroundColor blue
}


function Set-Group()
{
  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  Write-Host "Setting Group(s) for users`n" -ForegroundColor white
  Write-Host "SAM      `tGroup/OU     `t`tSubgroup" -ForegroundColor yellow
  Write-Host "---      `t--------     `t`t--------" -ForegroundColor yellow
  #loop through all users
  foreach ($User in $Users)
  {
      $Displayname = $User.Voornaam + " " + $User.Naam
      $UserFirstname = $User.Naam
      $UserLastname = $User.Voornaam
      $UserAccount = $User.Account
      $SAM = $UserAccount
      $UPN = "$($SAM)@Cynalco.be"
      $OU = ""
      $DistinguishedName = ""
      $BossName = ""

      $Manager = $User.Manager
      $IT = $User.IT
      $Boekhouding =  $User.Boekhouding
      $Logistiek = $User.Logistiek
      $ImportExport = $User.ImportExport

      $DistinguishedName = "$($DistinguishedName)OU=CMAfdelingen,DC=POLIFORMA,dc=be,"

        $Result = ""
        $Result2 = ""

        if (dsquery user -samid $SAM)
        {
          $Result = ""

          #assign to the correct principal group
          $UserpathOU = ""
          $Boss = "False"
          $countDepartments = 0

          if ($Manager -eq "X")
          {
            $UserpathOU = "Management"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
            $Boss = "True"
            Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
            $Result = $UserpathOU
          }
          else
          {
              if ($ImportExport -eq "X")
              {
                $UserpathOU = "ImportExport"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
                $countDepartments = $countDepartments + 1
              }
              if ($Logistiek -eq "X")
              {
                $UserpathOU = "Logistiek"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
                $countDepartments = $countDepartments + 1
              }
              if ($Boekhouding -eq "X")
              {
                $UserpathOU = "Boekhouding"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
                $countDepartments = $countDepartments + 1
              }
              if ($IT -eq "X")
              {
                $UserpathOU = "IT"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
                $countDepartments = $countDepartments + 1
              }
              Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $Result = $UserpathOU
          }

          #assigning to possible (sub) groups
          $UserpathOU = ""
          $Boss = "False"
          $SubOU = ""
          if ($Manager -eq "X")
          {
            $UserpathOU = "Management"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
            $Boss = "True"
            Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
            $countDepartments = $countDepartments + 1

            if ($ImportExport -eq "X")
            {
              $SubOU = "ImportExport"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              #Set-ADGroup -Identity:"CN=Manager,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $Result2 = $SubOU
            }
            if ($Logistiek -eq "X")
            {
              $SubOU = "Logistiek"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $Result2 = $SubOU
            }
            if ($Boekhouding -eq "X")
            {
              $SubOU = "Boekhouding"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $Result2 = $SubOU
            }
            if ($IT -eq "X")
            {
              $SubOU = "IT       "
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $Result2 = $SubOU
            }
          }
          else
          {

              if ($ImportExport -eq "X")
              {
                $UserpathOU = "ImportExport"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }
              if ($Logistiek -eq "X")
              {
                $UserpathOU = "Logistiek"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }
              if ($Boekhouding -eq "X")
              {
                $UserpathOU = "Boekhouding"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }
              if ($IT -eq "X")
              {
                $UserpathOU = "IT       "
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -MemberOf:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
          }

          #used to see if the big boss exists ($boss true and count 1)
          if ($Manager -eq "X")
          {
            if ($countDepartments -eq 1)
              {
                $SubOU = "Management"
                Set-ADGroup -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Replace:'manager'="CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"
                #Get-ADUser -SearchBase "OU=$($UserpathOU),dc=Cynalco,dc=be" -Filter * -ResultSetSize 5000 | Select Name,SamAccountName
                #Write-Host "Setting manager $($Displayname) for users in $($SubOU) "
                #Get-ADUser -SearchBase "OU=$($UserpathOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select SAMAccountName # Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"

              }
          }
    }
        Write-Host "$($SAM)      `t$($Result)  `t`t$($Result2)"  -ForegroundColor DarkGreen
  }
  Write-Host ""
  Write-Host " *** Finished adding users to the correct group(s) *** `n" -ForegroundColor blue

}

function Remove-UnfoundUser()
{

    #import data
    $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

    Write-Host "Disabling users not found in CSV`n" -ForegroundColor white
    Write-Host "SAM           `t`t`tAction" -ForegroundColor yellow
    Write-Host "---           `t`t`t------" -ForegroundColor yellow


    $usersAD = Get-ADUser -SearchBase "ou=CMAfdelingen,dc=Cynalco,dc=be" -filter *
     ForEach($userAD in $usersAD)
        {
          $SAM_AD = $userAD.SAMAccountName
          $UsersCSV = Import-Csv -Delimiter ";" -Path "personeel.csv"
          $found=$false
          #loop through all users
              foreach ($User in $UsersCSV)
              {
                  $Displayname = $User.Voornaam + " " + $User.Naam
                  $UserFirstname = $User.Naam
                  $UserLastname = $User.Voornaam
                  $UserAccount = $User.Account
                  $SAM = $UserAccount
                  if ($SAM_AD -eq $SAM)
                  {
                    $found=$true
                  }

              }


              if ($found -eq $true)
              {
                if (dsquery user -samid $SAM_AD)
                {
                  $ActiveUser = Get-ADUser -Identity $SAM_AD
                  if ($ActiveUser.Enabled -eq $True)
                  {
                    $Result  = "User remains active"
                    Write-host $SAM_AD"     `t`t`t"$Result -ForegroundColor white
                  }
                  else
                  {
                    $Result  = "Old user reactivated"
                    Write-host $SAM_AD"     `t`t`t"$Result -ForegroundColor darkgray
                  }

                }
                else
                {
                  $Result  = "New user detected"
                  Write-host $SAM_AD"     `t`t`t"$Result -ForegroundColor magenta
                }
              }
              else
              {
                $ActiveUser = Get-ADUser -Identity $SAM_AD
                if ($ActiveUser.Enabled -eq $True)
                {
                    Disable-ADaccount -identity $SAM_AD
                    $Result  = "User has been disabled"
                    Write-host $SAM_AD"     `t`t`t"$Result -ForegroundColor  Red
                }
                else{
                    Disable-ADaccount -identity $SAM_AD
                    $Result  = "User remains disabled"
                    Write-host $SAM_AD"     `t`t`t"$Result -ForegroundColor  Green

                }

              }


        }



}

function Set-Manager()
{
  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  Write-Host "Setting manager for users in OU's`n" -ForegroundColor white
  Write-Host "SAM      `tManager of   `t`t`tAction" -ForegroundColor yellow
  Write-Host "---      `t----------   `t`t`t------" -ForegroundColor yellow

  $manManager = ""
  $manIT = ""
  $manBoekhouding = ""
  $manImportExport = ""
  $manLogistiek = ""

  #loop through all users
  foreach ($User in $Users)
  {
      $Displayname = $User.Voornaam + " " + $User.Naam
      $UserFirstname = $User.Naam
      $UserLastname = $User.Voornaam
      $UserAccount = $User.Account
      $SAM = $UserAccount
      $UPN = "$($SAM)@Cynalco.be"
      $OU = ""
      $DistinguishedName = ""
      $BossName = ""

      $Manager = $User.Manager
      $IT = $User.IT
      $Boekhouding =  $User.Boekhouding
      $Logistiek = $User.Logistiek
      $ImportExport = $User.ImportExport

      $UserpathOU = ""
      $DistinguishedName = "$($DistinguishedName)OU=CMAfdelingen,DC=POLIFORMA,dc=be,"

        $Result = ""
        $Result2 = ""
        $countDepartments = 0

          $Boss = "False"
          $SubOU = ""

          if ($Manager -eq "X")
          {
            $UserpathOU = "Management"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
            $Boss = "True"
            $countDepartments = $countDepartments + 1

            if ($ImportExport -eq "X")
            {  
              $SubOU = "ImportExport"
              $DistinguishedName = "OU=$($UserpathOU),"
              $countDepartments = $countDepartments + 1
              #Set-ADGroup -Identity:"CN=Manager,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -ManagedBy:"CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
              $manImportExport = $Displayname
              Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
              $Result = "    `tSet as manager for all users in OU"
            }

            if ($Logistiek -eq "X")
            {
              $SubOU = "Logistiek"
              $DistinguishedName = "OU=$($UserpathOU),"
              $countDepartments = $countDepartments + 1
              $manLogistiek = $Displayname
              Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
              $Result = "Set as manager for all users in OU"
                $SubOU = "Logistiek`t"
            }
            if ($Boekhouding -eq "X")
            {
              $SubOU = "Boekhouding"
              $DistinguishedName = "OU=$($UserpathOU),"
              $countDepartments = $countDepartments + 1
              $manBoekhouding = $Displayname
              Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
              $Result = "Set as manager for all users in OU"
                $SubOU = "Boekhouding`t"
            }
            if ($IT -eq "X")
            {   
              $SubOU = "IT"
              $DistinguishedName = "OU=$($UserpathOU),"
              $countDepartments = $countDepartments + 1
              $manIT = $Displayname
              Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
              $Result = "Set as manager for all users in OU"
                $SubOU = "IT         `t"
            }
          }
          else
          {
          }

          if ($Manager -eq "X")
          {
            if ($countDepartments -eq 1)
              {
                $SubOU = "Management"
                $manManager = $Displayname
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Replace:'manager'="CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,dc=be" -Server:"CrispyMcBacon.Cynalco.be"
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"
                #Get-ADUser -SearchBase "OU=$($UserpathOU),dc=Cynalco,dc=be" -Filter * -ResultSetSize 5000 | Select Name,SamAccountName
                #Write-Host "Setting manager $($Displayname) for users in $($SubOU) "
                #Get-ADUser -SearchBase "OU=$($UserpathOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select SAMAccountName # Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,dc=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"
                Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
                $Result = "Set as manager for all users in OU"
                $SubOU = "Management`t"
              }
          }

          #show only if is a boss
          if ($SubOU -eq "")
          {}
            else{
              Write-Host "$($SAM)      `t$($SubOU)`t`t$($Result)"  -ForegroundColor Magenta
            }
  }
  Write-Host ""
  Write-Host " *** Finished setting managers for all users *** " -ForegroundColor Blue
}


function Log-Action()
{
  $Date = Get-Date
  $Entry = $Date.ToString() + "," + $env:username.ToString() + "," + $Menu.ToString() + ","+ $time_elapsed + ","
  Add-Content script_logbook.csv $Entry
}

function Show-Header()
{
  #making this script sexy
    Clear
    Write-Host '      ____              __        ' -ForegroundColor Yellow
    Write-Host '     / __ \   ____ _   / /      ___ ' -ForegroundColor Yellow
    Write-Host '    / / / /  / __ `/  / /      / _ \' -ForegroundColor Yellow
    Write-Host '   / /_/ /  / /_/ /  / /___   /  __/' -ForegroundColor Yellow
    Write-Host '  /_____/   \__,_/  /_____/   \___/ ' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+' -ForegroundColor Blue
    Write-Host '    |P|o|w|e|r|s|h|e|l|l| |C|L|I|' -ForegroundColor Blue
    Write-Host '    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+' -ForegroundColor Blue
    Write-Host ''
    Write-Host '  >> Author : David Lejeune' -ForegroundColor Red
    Write-Host "  >> Created : 27/09/2016" -ForegroundColor Red
    Write-Host ''
    Write-Host ' #####################################'  -ForegroundColor DarkGreen
    Write-Host ' #    ACTIVE DIRECTORY MANAGEMENT    #' -ForegroundColor DarkGreen
    Write-Host ' #####################################' -ForegroundColor DarkGreen
    Write-Host ''
}

function Show-Menu()
{
  #making this script sexy
    Write-Host " Menu :" -ForegroundColor Magenta;
    Write-Host "";
    Write-Host '    1. '$Menu1  -ForegroundColor Gray;
    Write-Host '    2. '$Menu2 -ForegroundColor Gray;
    Write-Host '    3. '$Menu3 -ForegroundColor Magenta;
    Write-Host '    4. '$Menu4 -ForegroundColor Gray;
    Write-Host '    5. '$Menu5 -ForegroundColor Red;
    Write-Host '    6. '$Menu6 -ForegroundColor DarkMagenta;
    Write-Host '    7. '$Menu7 -ForegroundColor DarkGreen;
    Write-Host '   ';
    Write-Host '    99.'$Menu99 -ForegroundColor DarkGRay;
    Write-Host "";
}

#------------------------------------------------------------------------------
#Script

$Host.UI.RawUI.BackgroundColor = ($bckgrnd = 'black')
$Host.UI.RawUI.ForegroundColor = 'White'
$Host.PrivateData.ErrorForegroundColor = 'Red'
$Host.PrivateData.ErrorBackgroundColor = $bckgrnd
$Host.PrivateData.WarningForegroundColor = 'Magenta'
$Host.PrivateData.WarningBackgroundColor = $bckgrnd
$Host.PrivateData.DebugForegroundColor = 'Yellow'
$Host.PrivateData.DebugBackgroundColor = $bckgrnd
$Host.PrivateData.VerboseForegroundColor = 'Green'
$Host.PrivateData.VerboseBackgroundColor = $bckgrnd
$Host.PrivateData.ProgressForegroundColor = 'Cyan'
$Host.PrivateData.ProgressBackgroundColor = $bckgrnd


Show-Header;
Show-Menu;

#Select action
$Menu = Read-Host -Prompt 'Select an option ';
$sw = [Diagnostics.Stopwatch]::StartNew()
switch ($Menu)
    {
        1
          {
              Write-Host "`nYou have selected $(($Menu1).ToUpper())`n" -ForegroundColor DarkGreen;
              $Menu = $Menu1;
              Create-OU;
          }

        2
          {
              Write-Host "`nYou have selected $(($Menu2).ToUpper())`n" -ForegroundColor DarkGreen;
              $Menu = $Menu2;
              Create-User;
          }

        3
          {
              Write-Host "`nYou have selected $(($Menu3).ToUpper())`n" -ForegroundColor DarkGreen;
              $Menu = $Menu3;
              Bulk-UserManagement;
          }

        4
          {
              Write-Host "`nYou have selected $(($Menu4).ToUpper())`n" -ForegroundColor DarkGreen;
              $Menu = $Menu4;
              Check-UserExistence;
          }
        5
          {
              Write-Host "`nYou have selected $(($Menu5).ToUpper())`n" -ForegroundColor DarkGreen;
              $Menu = $Menu5;
              Bulk-UserDelete;
          }
        6
          {
              Write-Host "`nYou have selected $(($Menu6).ToUpper())`n" -ForegroundColor DarkGreen;
              $Menu = $Menu6;
              Show-Users;
          }
        7
          {
              Write-Host "`nYou have selected $(($Menu7).ToUpper())`n" -ForegroundColor DarkGreen;
              $Menu = $Menu7;
              Delete-User;
          }
        99
          {
              Write-Host "`nYou have selected $(($Menu99).ToUpper())`n" -ForegroundColor DarkGreen;
              $Menu = $Menu99;
              Show-Description;
          }

        default {
          Write-Host "The choice could not be determined." -ForegroundColor Red
        }
    }

    $sw.Stop()
    $time_elapsed = $sw.Elapsed.TotalSeconds
    Write-Host " *** Task completed in "$time_elapsed" seconds. ***" -ForegroundColor Yellow
    Log-Action
#Clear-Host
