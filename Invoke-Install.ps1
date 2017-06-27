function Invoke-Install{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$False,
           Position = 0,
           ValueFromPipelineByPropertyName=$True,
           HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
           [Alias('Hostname','CN', 'ComputerName')]
           [String[]]$CName,

[Parameter(Mandatory=$False,
           HelpMessage = "Enter the package(s) to be installed.")]
           [String[]]$Packages,

[Parameter(Mandatory=$False,
           HelpMessage = "Set this flag to output the status of each attempt to a CSV file.")]
           [Switch]$OutCSV,

[Parameter(Mandatory=$False,
           HelpMessage = "Set this flag to automatically install software packages based on the department the computer belongs to. This is useful when setting up a computer.")]
           [Switch]$ByDept
           )

    BEGIN{
        if($OutCSV){
            $OutPath = "C:\SoftwareInstallation.csv"
            $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
            $FileHandle.AutoFlush = $True

        }

        $Cred = Get-Credential

        Get-Job | Remove-Job -Force

        $Jobs = @()
    }

    PROCESS{

        foreach($CN in $CName){
            foreach($PKG in $Packages){
                try{
                    $Jobs += Invoke-Command -ComputerName $CN -ScriptBlock {choco install $Args[0] -y} -ArgumentList $PKG -Credential $Cred -AsJob
                    
                    if($OutCSV){
                        $FileHandle.WriteLine("$CN, $PKG, Success")
                    }
                }
                catch{
                    if($OutCSV){
                        $FileHandle.WriteLine("$CN, $PKG, Fail")
                    }
                }
            }
        }
        
        foreach($Job in $Jobs){
        Get-Job | Wait-Job

        Get-Job | Receive-Job | Write-Host

        Get-Job | Remove-Job -Force
        }
    }

    END{
        if($OutCSV){
            $FileHandle.Flush()
            $FileHandle.Dispose()
            $FileHandle.Close()
        }
    }
}

function Install-ByDepartment{
    
    foreach($CN in $CName){

        $Jobs += Invoke-Command -ComputerName $CN -ScriptBlock {choco install firefox --ia -setDefaultBrowser}
            $Packages = "ar", "av", "googlechrome", "laserfiche", "micollab", "msoffice", "munis"
            
            if($CN -Match "MAY-" -OR $CN -Match "BLD-" -OR $CN -Match "CSS-"){
                $Packages += "vueworks"
            }
            
            if($CN -Match "HDP-" -OR $CN -Match "BLD-" -OR $CN -Match "MAY-" -OR $CN -Match "PLN-" -OR $CN -Match "CLK-"){
                $Packages += "geotms"
            }
             
            if($CN -Match "MAY-"){
                
            }

            foreach($PKG in $Packages){
                try{
                    $Jobs += Invoke-Command -ComputerName $CN -ScriptBlock {choco install $Args[0] -y} -ArgumentList $PKG -Credential $Cred -AsJob

                    
                    if($OutCSV){
                        $FileHandle.WriteLine("$CN, $PKG, Success")
                    }
                }
                catch{
                    if($OutCSV){
                        $FileHandle.WriteLine("$CN, $PKG, Fail")
                    }
                }
       
            }
        }
}