$Date = Get-Date
$Descr = "USB policy bypass attempt"
$Entry = $Date.ToString() + "," + [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.ToString() + "," + $Descr.ToString() + ","
Add-Content log_security_breach.csv $Entry
