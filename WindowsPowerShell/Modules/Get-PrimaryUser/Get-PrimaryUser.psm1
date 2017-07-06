function Get-PrimaryUser{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$False,
           Position = 0,
           ValueFromPipelineByPropertyName=$True,
           HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
           [Alias('HostName','CN', 'ComputerName')]
           [String[]]$CName,

[Parameter(Mandatory=$False,
           HelpMessage = "Set this flag to output the status of each attempt to a CSV file.")]
           [Switch]$OutCSV
           )

    BEGIN{
        $UserList = New-Object System.Collections.Generic.List[System.Object]
        if($OutCSV){
            $OutPath = "C:\ComputerProfiles.csv"
            $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
            $FileHandle.AutoFlush = $True
        }
    }

    PROCESS{
        foreach($CN in $CName){
            $UserInfo = New-Object -TypeName PSObject
            try{
                [String]$User = Get-WmiObject –ComputerName $CN –Class Win32_ComputerSystem | Select-Object UserName
                $i = $User.IndexOf("\")
                $Temp = $User.Substring($i + 1)
                $User = $Temp
                $j = $User.IndexOf("}")
                $Temp = $User.Substring(0, $j)
                $User = $Temp.ToUpper()
            
                $UserInfo | Add-Member -Type NoteProperty -Name HostName -Value $CN -Force
                $UserInfo | Add-Member -Type NoteProperty -Name UserName -Value $User -Force

                if($OutCSV){
                    $FileHandle.WriteLine("$CN, $User")
                }
            }
            catch{
                $UserInfo | Add-Member -Type NoteProperty -Name HostName -Value $CN -Force
                $UserInfo | Add-Member -Type NoteProperty -Name UserName -Value "Username could not be found" -Force

                if($OutCSV){
                    $FileHandle.WriteLine("$CN, Username could not be found")
                }
            }
        $UserList.Add($UserInfo)
        }
    }

    END{
        if($OutCSV){
            $FileHandle.Flush()
            $FileHandle.Dispose()
            $FileHandle.Close()
        }
        return $UserList
    }
}
