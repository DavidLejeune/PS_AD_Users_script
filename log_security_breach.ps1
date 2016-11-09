$Date = (Get-Date).ToString('dd/MM/yyyy')
$Time = (Get-Date).ToString('HH:mm:ss')
$Entry = $Date.ToString() + "," + $Time.ToString() + "," + [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.ToString() + "," + $Descr.ToString() + ","
Add-Content log_security_breach.csv $Entry
