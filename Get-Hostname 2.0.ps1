function Get-Hostname {
    
    
    foreach($IP in $IPRange)
    [System.Net.DNS]::GetHostEntry("$IP")
}

