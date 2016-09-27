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
        } 
        2 
        {
            Write-Host 'You have selected'$Menu2;
        } 
        default {"The choice could not be determined."}
    }