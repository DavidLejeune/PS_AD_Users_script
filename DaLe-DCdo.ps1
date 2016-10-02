#Description
#To be done

Import-Module ActiveDirectory

#------------------------------------------------------------------------------
#Script Variables
$Menu = ""
$Menu1 = "Create new OU";
$Menu2 = "New User"
$Menu3 = "Bulk create User from CSV"
$Menu4 = "Check User existence"
$Menu5 = "Bulk delete User from CSV"


#------------------------------------------------------------------------------
#Functions
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

function Check-UserExistence()
{
  $user = Read-Host -Prompt '> Enter SamAccountName ';
  if (dsquery user -samid $user){"Found user"}
  else {"Did not find user"}
}

function Bulk-UserDelete()
{
  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"
  #header of table
  Write-Host 'Displaying list of Users'
  Write-Host "Building DistinguishedName based on department(s)`n"
  Write-Host "Account      `tSAM      `tExists?     `t`Result"
  Write-Host "-------      `t---      `t-------     `t------"

  #loop through all users
  foreach ($User in $Users)
  {
      #get Variables
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
      if ($Manager -eq "X")
      {
        $UserpathOU = "Directie"
        $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
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

        }


  Write-Host $UserAccount"      `t"$SAM"      `t"$Result"`t"$Result2

  }

  Write-Host ""
  Write-Host "Finished reading csv file"
}

function Bulk-UserCreate()
{
  #main task
  #create users based on csv date

  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

      Write-Host 'Displaying list of Users'
      Write-Host "Building DistinguishedName based on department(s)`n"
      Write-Host "Account      `tSAM      `tExists?      `tResult"
      Write-Host "-------      `t---      `t-------   `t------"

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
      if ($Manager -eq "X")
      {
        $UserpathOU = "Directie"
        $DistinguishedName = "$($DistinguishedName)OU=$($UserpathOU),"
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



        }
        else
        {
          $Result = "User not found"

          #create the user and assign to OU

          New-ADUser -Department:"$($UserpathOU)" -DisplayName:"$($Displayname)" -GivenName:"$($UserFirstname)" -Name:"$($Displayname)" -Path:"OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM" -SamAccountName:"$($SAM)" -Server:"DLSV1.POLIFORMADL.COM" -Surname:"$($UserLastname)" -Type:"user" -UserPrincipalName:"$($SAM)@POLIFORMADL.COM" -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) -Enabled $true

          #New-ADUser -Department:"$($UserpathOU)" -DisplayName:"$($Displayname)" -GivenName:"$($UserFirstname)" -Name:"$($Displayname)" -Path:"OU=$($UserpathOU),OU=PFAfdelingen,DC=POLIFORMADL,DC=COM" -SamAccountName:"$($SAM)" -Server:"DLSV1.POLIFORMADL.COM" -Surname:"$($UserLastname)" -Type:"user" -UserPrincipalName:"$($SAM)@POLIFORMADL.COM"
          #New-ADUser -name "$($Displayname)" -GivenName "$($UserFirstname)" -SurName "$($UserLastname)" -SamAccountName "$($SAM)" -UserPrincipalName "$($UPN)" -AccountPassword (ConvertTo-SecureString -AsPlainText "Password123" -Force)  -PassThru | Enable-ADAccount ;

          #Check after creation if user exists now
          if (dsquery user -samid $SAM)
          {
            $Result2 = "User succesfully created"
          }
          else
          {
            $Result2 = "Unsuccesfull in creating user"
          }
        }

        Write-Host $UserAccount"      `t"$SAM"      `t"$Result"`t"$Result2
  }
  Write-Host ""
  Write-Host "Finished reading csv file"
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
    Write-Host " Menu :";
    Write-Host "";
    Write-Host '    1. '$Menu1;
    Write-Host '    2. '$Menu2;
    Write-Host '    3. '$Menu3;
    Write-Host '    4. '$Menu4;
    Write-Host '    5. '$Menu5;
    Write-Host "";
}


#------------------------------------------------------------------------------
#Script


Show-Header;

#Select action
$Menu = Read-Host -Prompt 'Select an option ';
switch ($Menu)
    {
        1
          {
              Write-Host "`nYou have selected $Menu1`n";
              $Menu = $Menu1;
              Create-OU;
          }

        2
          {
              Write-Host "`nYou have selected $Menu2`n";
              $Menu = $Menu2;
              Create-User;
          }

        3
          {
              Write-Host "`nYou have selected $Menu3`n";
              $Menu = $Menu3;
              Bulk-UserCreate;
          }

        4
          {
              Write-Host "`nYou have selected $Menu4`n";
              $Menu = $Menu4;
              Check-UserExistence;
          }
        5
          {
              Write-Host "`nYou have selected $Menu5`n";
              $Menu = $Menu5;
              Bulk-UserDelete;
          }

        default {"The choice could not be determined."}
    }
