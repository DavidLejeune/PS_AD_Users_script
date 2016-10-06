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
  "# Description"
  "# -----------"
  "# Active Directory Management tool"
  "# Created for Task1 Operating Systems Windows 2 @ Vives"
  "#"
  "# Author : David Lejeune"
  "# Created : 27/09/2016"
  "# School : Vives"
  "# Course : Operating Systems Windows 2"
  "# Class : 3PB-ICT"
  "# Group : 2"
  "#"
  "# Task goals"
  "# ----------"
  "# Manage an Active Directory on Windows Server 2012 R2"
  "# 1)Bulk create users based on csv (OK)"
  "# 2)Update users based on weekly csv updates (TBD)"
  ""
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
    $pathOU = "ou=$($UserpathOU),ou=PFAfdelinen,dc=Cynalco,dc=be"

    New-ADUser -Department:"$($UserpathOU)" -DisplayName:"$($Displayname)" -GivenName:"$($UserFirstname)" -Name:"$($Displayname)" -Path:"OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -SamAccountName:"$($SAM)" -Server:"CrispyMcBacon.Cynalco.be" -Surname:"$($UserLastname)" -Type:"user" -UserPrincipalName:"$($SAM)@Cynalco.be" -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) -Enabled $true

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
    Get-ADUser -SearchBase "OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select CN ,SAMAccountName, Department, Description , Title,UserPrincipalName, DistinguishedName, HomeDirectory, ProfilePath, Office, OfficePhone, Manager    | convertto-html | out-file ADUsers.html
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


  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  #header of table
  Write-Host "Get ready for the magic ...`n"
  Write-Host "SAM      `tExists?      `t`tAction     `t`t`tOU"
  Write-Host "---      `t-------   `t`t------     `t`t`t--"

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

      #find ou
      $Manager = $User.Manager
      $IT = $User.IT
      $Boekhouding =  $User.Boekhouding
      $Logistiek = $User.Logistiek
      $ImportExport = $User.ImportExport


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

#if ($ImportExport -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=ImportExport,"
#}
#if ($Logistiek -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=Logistiek,"
#}
#if ($Boekhouding -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=Boekhouding,"
#}
#if ($IT -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=IT,"
#}
#if ($Manager -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=Manager,"
#}







      $DistinguishedName = "$($DistinguishedName)OU=CMAfdelingen,DC=Cynalco,DC=be,"






        $Result = ""
        $Result2 = ""
        if (dsquery user -samid $SAM)
        {
          $Result = "User Found"
          remove-aduser -identity $SAM -confirm:$false

          #remove user from groups
          #$DGs= Get-DistributionGroup | where { (Get-DistributionGroupMember $_ | foreach {$_.UserPrincipalName}) -contains $UPN}
          #foreach( $dg in $DGs){
          #    Remove-DistributionGroupMember $dg -Member $UPN
          #  }

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


        Write-Host $SAM"      `t"$Result"`t`t"$Result2"      `t"$UserpathOU

  }

  Write-Host ""
  Write-Host " *** Finished bulk deleting users *** "
}

function Bulk-UserManagement()
{

  #main task
  #create users based on csv date
  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  Write-Host "Crunching data like a boss"
  Write-Host "Get ready for the magic ...`n"
  Write-Host "Creating users`n"
  Write-Host "SAM      `tExists?      `t`tAction     `t`t`tOU`t`t     `tSubgroup"
  Write-Host "---      `t-------   `t`t------     `t`t`t--`t`t     `t--------"

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

      #find ou
      #$Manager = $User.Manager
      #$IT = $User.IT
      #$Boekhouding =  $User.Boekhouding
      #$Logistiek = $User.Logistiek
      #$ImportExport = $User.ImportExport

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


#------------------------------
#if ($ImportExport -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=ImportExport,"
#}
#if ($Logistiek -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=Logistiek,"
#}
#if ($Boekhouding -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=Boekhouding,"
#}
#if ($IT -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=IT,"
#}
#if ($Manager -eq "X")
#{
#  $DistinguishedName = "$($DistinguishedName)OU=Manager,"
#}

        $DistinguishedName = "$($DistinguishedName)OU=CMAfdelingen,DC=Cynalco,DC=be,"

        $Result = ""
        $Result2 = ""

        if (dsquery user -samid $SAM)
        {
          $Result = "User Found"
          $Result2 =  "No creation required"
        }
        else
        {
          $Result = "User not found"

          #create the user and assign to OU
          New-ADUser -ChangePasswordAtLogon:$true -Department:"$($UserpathOU)" -DisplayName:"$($Displayname)" -GivenName:"$($UserFirstname)" -Name:"$($Displayname)" -Path:"OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -SamAccountName:"$($SAM)" -Server:"CrispyMcBacon.Cynalco.be" -Surname:"$($UserLastname)" -Type:"user" -UserPrincipalName:"$($SAM)@Cynalco.be" -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) -Enabled $true

          #Check after creation if user exists now
          if (dsquery user -samid $SAM)
          {
            $Result2 = "User succesfully created"
          }
          else
          {
            $Result2 = "Unsuccesfull in creating user"
          }

          #assign to the correct principal group
          $UserpathOU = ""
          $Boss = "False"
          $countDepartments = 0
          if ($Manager -eq "X")
          {
            $UserpathOU = "Management"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
            $Boss = "True"

            Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"

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
              Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"

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
            Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
            $countDepartments = $countDepartments + 1

            if ($ImportExport -eq "X")
            {
              $SubOU = "ImportExport"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              #Set-ADGroup -Identity:"CN=Management,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"

            }
            if ($Logistiek -eq "X")
            {
              $SubOU = "Logistiek"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
            }
            if ($Boekhouding -eq "X")
            {
              $SubOU = "Boekhouding"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
            }
            if ($IT -eq "X")
            {
              $SubOU = "IT"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
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

              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"

          }


          #-----------------------------------------


          #used to see if the big boss exists ($boss true and count 1)
          if ($Manager -eq "X")
          {
            if ($countDepartments -eq 1)
              {
                $SubOU = "Management"
                Set-ADGroup -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Replace:'manager'="CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"
                #Get-ADUser -SearchBase "OU=$($UserpathOU),dc=Cynalco,dc=be" -Filter * -ResultSetSize 5000 | Select Name,SamAccountName
                #Write-Host "Setting manager $($Displayname) for users in $($SubOU) "
                #Get-ADUser -SearchBase "OU=$($UserpathOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select SAMAccountName # Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"

              }
          }
    }

        Write-Host "$($SAM)      `t$($Result)`t`t$($Result2)      `t$($UserpathOU)     `t`t$($SubOU)"
  }
  Write-Host ""
  Write-Host " *** Finished creating new users and adding them to the correct OU *** `n"
  Set-Group
  Set-Manager
}


function Set-Group()
{

  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  Write-Host "Setting Group(s) for users`n"
  Write-Host "SAM      `tGroup/OU     `t`tSubgroup"
  Write-Host "---      `t--------     `t`t--------"
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

      #find ou
      #$Manager = $User.Manager
      #$IT = $User.IT
      #$Boekhouding =  $User.Boekhouding
      #$Logistiek = $User.Logistiek
      #$ImportExport = $User.ImportExport

      $Manager = $User.Manager
      $IT = $User.IT
      $Boekhouding =  $User.Boekhouding
      $Logistiek = $User.Logistiek
      $ImportExport = $User.ImportExport



        $DistinguishedName = "$($DistinguishedName)OU=CMAfdelingen,DC=Cynalco,DC=be,"

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

            Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
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
              Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
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
            Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
            $countDepartments = $countDepartments + 1

            if ($ImportExport -eq "X")
            {
              $SubOU = "ImportExport"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              #Set-ADGroup -Identity:"CN=Management,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $Result2 = $SubOU
            }
            if ($Logistiek -eq "X")
            {
              $SubOU = "Logistiek"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $Result2 = $SubOU
            }
            if ($Boekhouding -eq "X")
            {
              $SubOU = "Boekhouding"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $Result2 = $SubOU
            }
            if ($IT -eq "X")
            {
              $SubOU = "IT"
              $DistinguishedName = "OU=$($UserpathOU),"
              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $countDepartments = $countDepartments + 1
              Set-ADGroup -Identity:"CN=$($SubOU),OU=$($SubOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
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
                $UserpathOU = "IT"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }

              Add-ADPrincipalGroupMembership -Identity:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -MemberOf:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"

          }


          #-----------------------------------------


          #used to see if the big boss exists ($boss true and count 1)
          if ($Manager -eq "X")
          {
            if ($countDepartments -eq 1)
              {
                $SubOU = "Management"
                Set-ADGroup -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=$($Displayname),OU=$($UserpathOU),OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Replace:'manager'="CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"
                #Get-ADUser -SearchBase "OU=$($UserpathOU),dc=Cynalco,dc=be" -Filter * -ResultSetSize 5000 | Select Name,SamAccountName
                #Write-Host "Setting manager $($Displayname) for users in $($SubOU) "
                #Get-ADUser -SearchBase "OU=$($UserpathOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select SAMAccountName # Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"

              }
          }
    }

        Write-Host "$($SAM)      `t$($Result)      `t$($Result2)"
  }
  Write-Host ""
  Write-Host " *** Finished adding users to the correct group(s) *** `n"

}

function Set-Manager()
{

  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  Write-Host "Setting manager for users in OU's`n"
  Write-Host "SAM      `tManager of`t`tAction"
  Write-Host "---      `t----------`t`t------"

  $manManagement = ""
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

      #find ou
      #$Manager = $User.Manager
      #$IT = $User.IT
      #$Boekhouding =  $User.Boekhouding
      #$Logistiek = $User.Logistiek
      #$ImportExport = $User.ImportExport

      $Manager = $User.Manager
      $IT = $User.IT
      $Boekhouding =  $User.Boekhouding
      $Logistiek = $User.Logistiek
      $ImportExport = $User.ImportExport


      $UserpathOU = ""


        $DistinguishedName = "$($DistinguishedName)OU=CMAfdelingen,DC=Cynalco,DC=be,"

        $Result = ""
        $Result2 = ""
        $countDepartments = 0

          $UserpathOU = ""
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
              #Set-ADGroup -Identity:"CN=Management,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -ManagedBy:"CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
              $manImportExport = $Displayname
              Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
              $Result = "Set as manager for all users in OU"
            }

            if ($Logistiek -eq "X")
            {
              $SubOU = "Logistiek"
              $DistinguishedName = "OU=$($UserpathOU),"
              $countDepartments = $countDepartments + 1
              $manLogistiek = $Displayname
              Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
              $Result = "Set as manager for all users in OU"

            }
            if ($Boekhouding -eq "X")
            {
              $SubOU = "Boekhouding"
              $DistinguishedName = "OU=$($UserpathOU),"
              $countDepartments = $countDepartments + 1
              $manBoekhouding = $Displayname
              Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
              $Result = "Set as manager for all users in OU"

            }
            if ($IT -eq "X")
            {
              $SubOU = "IT"
              $DistinguishedName = "OU=$($UserpathOU),"
              $countDepartments = $countDepartments + 1
              $manIT = $Displayname
              Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
              $Result = "`tSet as manager for all users in OU"

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
                $manManagement = $Displayname
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Replace:'manager'="CN=Bert Laplasse,OU=Management,OU=CMAfdelingen,DC=Cynalco,DC=be" -Server:"CrispyMcBacon.Cynalco.be"
                #Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"
                #Get-ADUser -SearchBase "OU=$($UserpathOU),dc=Cynalco,dc=be" -Filter * -ResultSetSize 5000 | Select Name,SamAccountName
                #Write-Host "Setting manager $($Displayname) for users in $($SubOU) "
                #Get-ADUser -SearchBase "OU=$($UserpathOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | select SAMAccountName # Set-ADUser -Identity:"CN=Linda Hombroeckx,OU=Logistiek,OU=CMAfdelingen,DC=Cynalco,DC=be" -Manager:$null -Server:"CrispyMcBacon.Cynalco.be"
                Get-ADUser -SearchBase "OU=$($SubOU),OU=CMAfdelingen,dc=Cynalco,dc=be" -Filter * -properties * -ResultSetSize 5000 | Set-ADUser  -Manager "$($SAM)" #-Identity:"$($_.SAMAccountName)" -Manager  #-Server:"CrispyMcBacon.Cynalco.be"
                $Result = "Set as manager for all users in OU"

              }
          }

          #show only if is a boss
          if ($SubOU -eq "")
          {}
            else{
              Write-Host "$($SAM)      `t$($SubOU)`t`t$($Result)"
            }
  }
  Write-Host ""
  Write-Host " *** Finished setting managers for all users *** "
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
    Write-Host '      ____              __        '
    Write-Host '     / __ \   ____ _   / /      ___ '
    Write-Host '    / / / /  / __ `/  / /      / _ \'
    Write-Host '   / /_/ /  / /_/ /  / /___   /  __/'
    Write-Host '  /_____/   \__,_/  /_____/   \___/ '
    Write-Host ''
    Write-Host '    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+'
    Write-Host '    |P|o|w|e|r|s|h|e|l|l| |C|L|I|'
    Write-Host '    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+'
    Write-Host ''
    Write-Host '  >> Author : David Lejeune'
    Write-Host "  >> Created : 27/09/2016"
    Write-Host ''
    Write-Host ' #####################################'
    Write-Host ' #    ACTIVE DIRECTORY MANAGEMENT    #'
    Write-Host ' #####################################'
    Write-Host ''
}

function Show-Menu()
{
  #making this script sexy
    Write-Host " Menu :";
    Write-Host "";
    Write-Host '    1. '$Menu1;
    Write-Host '    2. '$Menu2;
    Write-Host '    3. '$Menu3;
    Write-Host '    4. '$Menu4;
    Write-Host '    5. '$Menu5;
    Write-Host '    6. '$Menu6;
    Write-Host '    7. '$Menu7;
    Write-Host '   ';
    Write-Host '    99.'$Menu99;
    Write-Host "";
}


#------------------------------------------------------------------------------
#Script


Show-Header;
Show-Menu;

#Select action
$Menu = Read-Host -Prompt 'Select an option ';
$sw = [Diagnostics.Stopwatch]::StartNew()
switch ($Menu)
    {
        1
          {
              Write-Host "`nYou have selected $(($Menu1).ToUpper())`n";
              $Menu = $Menu1;
              Create-OU;
          }

        2
          {
              Write-Host "`nYou have selected $(($Menu2).ToUpper())`n";
              $Menu = $Menu2;
              Create-User;
          }

        3
          {
              Write-Host "`nYou have selected $(($Menu3).ToUpper())`n";
              $Menu = $Menu3;
              Bulk-UserManagement;
          }

        4
          {
              Write-Host "`nYou have selected $(($Menu4).ToUpper())`n";
              $Menu = $Menu4;
              Check-UserExistence;
          }
        5
          {
              Write-Host "`nYou have selected $(($Menu5).ToUpper())`n";
              $Menu = $Menu5;
              Bulk-UserDelete;
          }
        6
          {
              Write-Host "`nYou have selected $(($Menu6).ToUpper())`n";
              $Menu = $Menu6;
              Show-Users;
          }
        7
          {
              Write-Host "`nYou have selected $(($Menu7).ToUpper())`n";
              $Menu = $Menu7;
              Delete-User;
          }
        99
          {
              Write-Host "`nYou have selected $(($Menu99).ToUpper())`n";
              $Menu = $Menu99;
              Show-Description;
          }

        default {"The choice could not be determined."}
    }


    $sw.Stop()
    $time_elapsed = $sw.Elapsed.TotalSeconds
    Write-Host " *** Task bepleted in "$time_elapsed" seconds. ***"
    Log-Action
