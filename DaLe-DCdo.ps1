Import-Module ActiveDirectory

clear

$Menu1 = "Create new OU";
$Menu2 = "New User"

Write-Host "Menu :";
Write-Host "";
Write-Host '    1. '$Menu1;
Write-Host '    2. '$Menu2;
Write-Host "";

$Menu = Read-Host -Prompt 'Select an option '


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
        default {"The choice could not be determined."}
    }


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
    New-ADUser -name $Username -GivenName $Givenname -SurName $Surname -DisplayName $Displayname -Path "ou="$UserpathOU",dc=POLIFORMADL.COM,dc=local";
    
}