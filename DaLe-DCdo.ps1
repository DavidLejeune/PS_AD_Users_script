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
$DC1 = "POLIFORMADL"
$DC2 = "COM"

$Menu = ""
$Menu1 = "Create new OU";
$Menu2 = "New User"
$Menu3 = "Bulk create User from CSV"
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
    $UPN = "$($SAM)@POLIFORMADL.com"
    $pathOU = "ou=$($UserpathOU),ou=PFAfdelinen,dc=POLIFORMADL,dc=COM"

    New-ADUser -Department:"$($UserpathOU)" -DisplayName:"$($Displayname)" -GivenName:"$($UserFirstname)" -Name:"$($Displayname)" -Path:"OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM" -SamAccountName:"$($SAM)" -Server:"DLSV1.POLIFORMADL.COM" -Surname:"$($UserLastname)" -Type:"user" -UserPrincipalName:"$($SAM)@POLIFORMADL.COM" -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) -Enabled $true

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
    Get-ADUser -SearchBase "OU=PFAfdelingen,dc=POLIFORMADL,dc=COM" -Filter * -properties * -ResultSetSize 5000 | select CN ,SAMAccountName, Department, Description , Title,UserPrincipalName, DistinguishedName, HomeDirectory, ProfilePath, Office, OfficePhone, Manager    | convertto-html | out-file ADUsers.html
    Get-ADUser -SearchBase "dc=POLIFORMADL,dc=COM" -Filter * -properties * -ResultSetSize 5000 | select DistinguishedName,SAMAccountName, Department | format-table -autosize
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
  Write-Host "Get ready for the magic ...`n"
  Write-Host "Account      `tSAM      `tExists?      `t`tAction     `t`t`tOU"
  Write-Host "-------      `t---      `t-------   `t`t------     `t`t`t--"

  #loop through all users
  foreach ($User in $Users)
  {
      #get csv Variables
      $Displayname = $User.Voornaam + " " + $User.Naam
      $UserFirstname = $User.Naam
      $UserLastname = $User.Voornaam
      $UserAccount = $User.Account
      $SAM = $UserAccount
      $UPN = "$($SAM)@POLIFORMADL.com"
      $OU = ""
      $DistinguishedName = "CN=" + $Displayname + ","

      #find ou
      #$Manager = $User.Manager
      #$IT = $User.IT
      #$Boekhouding =  $User.Boekhouding
      #$Logistiek = $User.Logistiek
      #$ImportExport = $User.ImportExport

      #find the department
      $Manager = $User.Directie
      $IT = $User.Administratie
      $Boekhouding =  $User.Automatisering
      $Logistiek = $User.Productie
      $ImportExport = $User.Staf
      $UserpathOU = ""

      if ($Manager -eq "X")
      {
        $UserpathOU = "Directie"
        $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
      }
      else
      {
          if ($ImportExport -eq "X")
          {
            $UserpathOU = "Staf"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($Logistiek -eq "X")
          {
            $UserpathOU = "Productie"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($Boekhouding -eq "X")
          {
            $UserpathOU = "Automatisering"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($IT -eq "X")
          {
            $UserpathOU = "Administratie"
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







      $DistinguishedName = "$($DistinguishedName)OU=PFAfdelingen,DC=POLIFORMA,DC=COM,"






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


        Write-Host $UserAccount"      `t"$SAM"      `t"$Result"`t`t"$Result2"      `t"$UserpathOU

  }

  Write-Host ""
  Write-Host "Finished reading csv file"
}

function Bulk-UserCreate()
{
  $sw = [Diagnostics.Stopwatch]::StartNew()

  #main task
  #create users based on csv date
  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

  Write-Host "Crunching data like a boss`n"
  Write-Host "Get ready for the magic ...`n"
  Write-Host "Account      `tSAM      `tExists?      `t`tAction     `t`t`tOU"
  Write-Host "-------      `t---      `t-------   `t`t------     `t`t`t--"

  #loop through all users
  foreach ($User in $Users)
  {
      $Displayname = $User.Voornaam + " " + $User.Naam
      $UserFirstname = $User.Naam
      $UserLastname = $User.Voornaam
      $UserAccount = $User.Account
      $SAM = $UserAccount
      $UPN = "$($SAM)@POLIFORMADL.com"
      $OU = ""
      $DistinguishedName = ""
      $BossName = ""

      #find ou
      #$Manager = $User.Manager
      #$IT = $User.IT
      #$Boekhouding =  $User.Boekhouding
      #$Logistiek = $User.Logistiek
      #$ImportExport = $User.ImportExport

      $Manager = $User.Directie
      $IT = $User.Administratie
      $Boekhouding =  $User.Automatisering
      $Logistiek = $User.Productie
      $ImportExport = $User.Staf


      $UserpathOU = ""
      if ($Manager -eq "X")
      {
        $UserpathOU = "Directie"
        $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
      }
      else
      {
          if ($ImportExport -eq "X")
          {
            $UserpathOU = "Staf"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($Logistiek -eq "X")
          {
            $UserpathOU = "Productie"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($Boekhouding -eq "X")
          {
            $UserpathOU = "Automatisering"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          if ($IT -eq "X")
          {
            $UserpathOU = "Administratie"
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

        $DistinguishedName = "$($DistinguishedName)OU=PFAfdelingen,DC=POLIFORMA,DC=COM,"

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
          New-ADUser -Department:"$($UserpathOU)" -DisplayName:"$($Displayname)" -GivenName:"$($UserFirstname)" -Name:"$($Displayname)" -Path:"OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM" -SamAccountName:"$($SAM)" -Server:"DLSV1.POLIFORMADL.COM" -Surname:"$($UserLastname)" -Type:"user" -UserPrincipalName:"$($SAM)@POLIFORMADL.COM" -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) -Enabled $true

          #Check after creation if user exists now
          if (dsquery user -samid $SAM)
          {
            $Result2 = "User succesfully created"
          }
          else
          {
            $Result2 = "Unsuccesfull in creating user"
          }

          $UserpathOU = ""
          if ($Manager -eq "X")
          {
            $UserpathOU = "Directie"
            $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
          }
          else
          {
              if ($ImportExport -eq "X")
              {
                $UserpathOU = "Staf"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }
              if ($Logistiek -eq "X")
              {
                $UserpathOU = "Productie"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }
              if ($Boekhouding -eq "X")
              {
                $UserpathOU = "Automatisering"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }
              if ($IT -eq "X")
              {
                $UserpathOU = "Administratie"
                $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
              }
          }
          #assign to the correct group(s)
          Set-ADGroup -Add:@{'Member'="CN=$($Displayname),OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"} -Identity:"CN=$($UserpathOU),OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM" -Server:"DLSV1.POLIFORMADL.COM"


        }

        #Set-ADGroup -Add:@{'Member'="CN=Tom Cordemans,OU=Staf,OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"}
        #-Identity:"CN=Staf,OU=Staf,OU=PFAfdelingen,DC=POLIFORMADL,DC=COM" -Server:"DLSV1.POLIFORMADL.COM"

        #Add-ADPrincipalGroupMembership -Identity:"CN=Luc Pasteels,OU=Directie,OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
        #-MemberOf:"CN=Automatisering,OU=Automatisering,OU=PFAfdelingen,DC=POLIFORMADL,DC=COM","CN=Directie,OU=Directie,OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
        #-Server:"DLSV1.POLIFORMADL.COM"

        #Set-ADGroup -Identity:"CN=Directie,OU=Directie,OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
        #-ManagedBy:"CN=Robert Hasselbanks,OU=Directie,OU=PFAfdelingen,DC=POLIFORMADL,DC=COM"
        #-Server:"DLSV1.POLIFORMADL.COM"



        Write-Host $UserAccount"      `t"$SAM"      `t"$Result"`t`t"$Result2"      `t"$UserpathOU
  }
  Write-Host ""
  Write-Host "Finished reading csv file"
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
              Bulk-UserCreate;
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
    Write-Host "Task completed in "$time_elapsed" seconds."
    Log-Action
