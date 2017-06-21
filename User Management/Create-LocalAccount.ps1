function Create-LocalAccount{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$False,
           Position = 0,
           ValueFromPipelineByPropertyName=$True,
           HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
           [Alias('Hostname','CN', 'ComputerName')]
           [String[]]$CName,

[Parameter(Mandatory=$True,
           HelpMessage = "Enter the user to be created.")]
           [String]$Username,

[Parameter(Mandatory=$True,
           HelpMessage = "Enter the user to be created.")]
           [String]$Password
    )

    BEGIN{
        $OutPath = "C:\NewLocalAccounts.csv"
        $ErrorPath = "C:\FailedLocalAccounts.csv"
        Remove-Item -Path $OutPath -Force -EA SilentlyContinue
        Remove-Item -Path $ErrorPath -Force -EA SilentlyContinue
        
        ConvertTo-SecureString -String $Password

        $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
        $FileHandle.AutoFlush = $True
    }

    PROCESS{
        foreach($CN in $CName){
            try{
                if($CN -NotMatch "HostName"){
                    $Computer = [ADSI]"WinNT://$CN"
                    $CompObj = $Computer.Create("User", $Username)
                    $CompObj.SetPassword($Password)
                    $CompObj.UserFlags = 64 + 65536
                    $CompObj.SetInfo()
                    $AdminObj = [ADSI]"WinNT://$CN/Administrators"
                    $AdminObj.Add("WinNT://$CN/$Username")

                    $FileHandle.WriteLine("$CN, Success")
                    }
                }
                catch{
                    
                    $Line = "$CN, $Status"

                    $FileHandle.WriteLine("$CN, Fail") 
                }
            }
    }

    END{
        $FileHandle.Flush()
        $FileHandle.Dispose()
        $FileHandle.Close()
    }
}
