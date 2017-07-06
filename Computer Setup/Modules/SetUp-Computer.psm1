function Setup-Computer{
    BEGIN{
        $CName = Get-NetComputers 10.70.5.1 10.70.5.50 | Where-Object {$_.HostName -NotMatch "ITS-" -AND $_.Hostname -NotMatch "Host"}
    }

    PROCESS{
        
        foreach($CN in $CName){
                Invoke-Script -CName $CN.HostName -ScriptBlock {Set-ExecutionPolicy RemoteSigned -Force}
                Invoke-Script -CName $CN.HostName -ScriptBlock {iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))}
                Invoke-Script -CName $CN.HostName -ScriptBlock {choco add source -n=NHIT -s="\\finance\Chocolatey Repo" --priority=1}
                Invoke-Script -CName $CN.Hostname -ScriptBlock {Copy-Item "\\finance\files\Software Distribution\printkey2000.exe" -Destination "C:\Users\Public\Public Desktop"}
                Invoke-Install -CName $CN.HostName -Packages "ar", "av", "munis", "msoffice", "meraki", "googlechrome", "firefox"
                Create-LocalAccount -CName $CN.HostName -Username "SU" -Password "Jt50PtFtN"
        }
    }
    
    
}