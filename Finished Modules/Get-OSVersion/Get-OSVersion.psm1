<#
.Synopsis
Gets the version of Windows on domain or network computers.

.Notes
Author: Connor James LaFleur
Copyright: Connor James LaFleur, 7/6/17 9:23AM Eastern Time
#>


function Get-OSVersion{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$False,
           Position = 0,
           ValueFromPipelineByPropertyName=$True,
           HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
           [Alias('Hostname','CN', 'ComputerName')]
           [String[]]$CName,

[Parameter(Mandatory = $False,
           HelpMessage ="Set this if you wish to output the results of the script to a csv file.")]
           [Switch]$OutCSV
           )

    BEGIN{
        if($OutCSV){
        $OutPath = "C:\OSInfo.csv"
        Remove-Item -Path $OutPath -Force -EA SilentlyContinue
        $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
        $FileHandle.AutoFlush = $True
        }
        $VersionInfo = New-Object System.Collections.Generic.List[System.Object]
    }

    PROCESS{
        foreach($CN in $CName){
            if($CN -NotMatch "Host"){
                try{
                    $OSInfo = New-Object -TypeName PSObject
                    $OS = (Get-WmiObject -ClassName Win32_OperatingSystem -ComputerName $CN).Caption

                    $OSInfo | Add-Member -Type NoteProperty -Name HostName -Value $CN -Force
                    $OSInfo | Add-Member -Type NoteProperty -Name OSVersion -Value $OS -Force
                }
                catch{
                    $OSInfo | Add-Member -Type NoteProperty -Name HostName -Value $CN -Force
                    $OSInfo | Add-Member -Type NoteProperty -Name OSVersion -Value "OS Version could not be found" -Force
                }
                $VersionInfo.Add($OSInfo)
            }
        }
    }

    END{
        if($OutCSV){
            $FileHandle.Flush()
            $FileHandle.Dispose()
            $FileHandle.Close()
        }
        return $VersionInfo
    }
}