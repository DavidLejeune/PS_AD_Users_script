
    Clear

    Write-Host '      ____              __        '
    Write-Host '     / __ \\   ____ _   / /      ___ '
    Write-Host '    / / / /  / __ `/  / /      / _ \\'
    Write-Host '   / /_/ /  / /_/ /  / /___   /  __/'
    Write-Host '  /_____/   \\__,_/  /_____/   \\___/ '
    Write-Host ''
    Write-Host '    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+'
    Write-Host '    |P|o|w|e|r|s|h|e|l|l| |C|L|I|'
    Write-Host '    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+'
    Write-Host ''
    Write-Host '  >> Author : David Lejeune'
    Write-Host "  >> Created : 28/09/2016"
    Write-Host ''
    Write-Host ' #####################################'
    Write-Host ' #      LOG ACTIVITIES TO CSV        #'
    Write-Host ' #####################################'
    Write-Host ''

    $Date = Get-Date

    Write-Host ' Welcome'$env:username
    Write-Host ' Date'$Date
    Write-Host ''
    Write-Host 'Enter a description for the log entry'
    $Descr = Read-Host -Prompt ' ';
    $Entry = $Date.ToString() + ";" + $env:username.ToString() + ";" + $Descr.ToString() + ";"
   
    Add-Content logbook.csv $Entry
    Write-Host ''
    Write-Host 'Entry has been logged , GREAT SUCCESS'