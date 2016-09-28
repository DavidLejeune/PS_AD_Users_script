Import-Module ActiveDirectory

$Menu1 = "Create new OU";
$Menu2 = "New User"
$Menu3 = "Bulk create User from CSV"

function Create-OU()
{
    $OUname = Read-Host -Prompt '> OU name ';
    New-ADOrganizationalUnit $OUname;
}



function Create-User()
{
    $Username = Read-Host -Prompt '> full user ';
    $Givenname = Read-Host -Prompt '> given name ';
    $Surname = Read-Host -Prompt '> surname ';
    $Displayname = Read-Host -Prompt '> display name ';
    $UserpathOU = Read-Host -Prompt '> OU ';
    New-ADUser -name $Username -GivenName $Givenname -SurName $Surname -DisplayName $Displayname -Path "ou="$UserpathOU",dc=POLIFORMADL,dc=COM";
    
}

function Bulk-UserCreate()
{


}

function Show-Header()
{
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
    Write-Host "";
    
}





Show-Header;
$Menu = Read-Host -Prompt 'Select an option ';

switch ($Menu) 
    { 
        1 
        {
            Write-Host 'You have selected'$Menu1;
            Create-OU;
        } 
        2 
        {
            Write-Host 'You have selected'$Menu2;
            Create-User;
        } 
        2 
        {
            Write-Host 'You have selected'$Menu3;
            Bulk-UserCreate;
        } 
        default {"The choice could not be determined."}
    }

