Import-Module ActiveDirectory

#------------------------------------------------------------------------------
#Script Variables
$Menu1 = "Create new OU";
$Menu2 = "New User"
$Menu3 = "Bulk create User from CSV"
$Menu4 = "Check User existence"


#------------------------------------------------------------------------------
#Functions
function Create-OU()
{
    #create top level OU (needs to worked out further for depth)
    $OUname = Read-Host -Prompt '> OU name ';
    New-ADOrganizationalUnit $OUname -path;
}

function Create-User()
{
    #Create user based on user inpu (input ok, ad action fail)
    $Username = Read-Host -Prompt '> full user ';
    $Givenname = Read-Host -Prompt '> given name ';
    $Surname = Read-Host -Prompt '> surname ';
    #$Displayname = Read-Host -Prompt '> display name ';
    $SAMname = Read-Host -Prompt '> SAM account name ';
    #$UserpathOU = Read-Host -Prompt '> OU ';
    $UPN = "$($SAMname)@POLIFORMADL.com"
    #$UserpathOUstr = "ou=$($UserpathOU),dc=POLIFORMADL,dc=local"
    New-ADUser -name "$($Username)" -GivenName "$($Givenname)" -SurName "$($Surname)" -SamAccountName "$($SAMname)" -UserPrincipalName "$($UPN)" -AccountPassword (ConvertTo-SecureString -AsPlainText "Password123" -Force) -PassThru | Enable-ADAccount;
    ($Error[0]).InvocationInfo.Line
}

function Check-UserExistence()
{
  $user = Read-Host -Prompt '> Enter SamAccountName ';
  if (dsquery user -samid $user){"Found user"}
  else {"Did not find user"}
}

function Bulk-UserCreate()
{
  #main task
  #create users based on csv date

  #import data
  $Users = Import-Csv -Delimiter ";" -Path "personeel.csv"

      Write-Host 'Displaying list of Users'
      Write-Host "Building DistinguishedName based on department(s)`n"
      Write-Host "Account      `tSAM      `tExists?      `tDistinguishedName"
      Write-Host "-------      `t---      `t-------   `t-----------------"

  #loop through all users
  foreach ($User in $Users)
  {
      $Displayname = $User.Naam + " " + $User.Voornaam
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

      $Manager = $User.Directie
      $IT = $User.Administratie
      $Boekhouding =  $User.Automatisering
      $Logistiek = $User.Productie
      $ImportExport = $User.Staf

      #CN=Floris Flipse,OU=FabricageBudel,OU=Productie,OU=PFAfdelingen,DC=POLIFORMADL,DC=COM

      if ($ImportExport -eq "X")
      {
        $DistinguishedName = "$($DistinguishedName)OU=Staf,"
      }
      if ($Logistiek -eq "X")
      {
        $DistinguishedName = "$($DistinguishedName)OU=Productie,"
      }
      if ($Boekhouding -eq "X")
      {
        $DistinguishedName = "$($DistinguishedName)OU=Automatisering,"
      }
      if ($IT -eq "X")
      {
        $DistinguishedName = "$($DistinguishedName)OU=Administratie,"
      }
      if ($Manager -eq "X")
      {
        $DistinguishedName = "$($DistinguishedName)OU=Directie,"
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





      #New-ADUser -name "$($Displayname)" -GivenName "$($UserFirstname)" -SurName "$($UserLastname)" -SamAccountName "$($SAM)" -UserPrincipalName "$($UPN)" -AccountPassword (ConvertTo-SecureString -AsPlainText "Password123" -Force) -PassThru | Enable-ADAccount;

      $Result = ""
      if (dsquery user -samid $SAM)
      {
        $Result = "User Found"
        Write-Host $UserAccount"      `t"$SAM"      `t"$Result"`t"$DistinguishedName



      }
      else
      {
        $Result = "User not found"
        Write-Host $UserAccount"      `t"$SAM"      `t"$Result"`t"$DistinguishedName

        New-ADUser -name "$($Displayname)" -GivenName "$($UserFirstname)" -SurName "$($UserLastname)" -SamAccountName "$($SAM)" -UserPrincipalName "$($UPN)" -AccountPassword (ConvertTo-SecureString -AsPlainText "Password123" -Force) -PassThru | Enable-ADAccount ;

        #Check after creation if user exists now
        if (dsquery user -samid $SAM)
        {
          Write-Host "User succesfully created"
        }
        else
        {
          Write-Host "Unsuccesfull in creating user"
        }

      }

      #New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM `
      #          -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" `
      #          -AccountPassword (ConvertTo-SecureString "$UserAccount" -AsPlainText -Force) -Enabled $true `
      #         -ChangePasswordAtLogon $false –PasswordNeverExpires $true -server DLSV1 -whatif

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
    Write-Host ' #     ACTIVE DIRECTORY MANAGENT     #'
    Write-Host ' #####################################'
    Write-Host ''
    Write-Host " Menu :";
    Write-Host "";
    Write-Host '    1. '$Menu1;
    Write-Host '    2. '$Menu2;
    Write-Host '    3. '$Menu3;
    Write-Host '    4. '$Menu4;
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
              Create-OU;
          }

        2
          {
              Write-Host "`nYou have selected $Menu2`n";
              Create-User;
          }

        3
          {
              Write-Host "`nYou have selected $Menu3`n";
              Bulk-UserCreate;
          }

        4
          {
              Write-Host "`nYou have selected $Menu4`n";
              Check-UserExistence;
          }

        default {"The choice could not be determined."}
    }
