function Delete-LocalAccount{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$False,
           Position = 0,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
      [Alias('Hostname','CN', 'ComputerName')]
    [String[]]$CName,

    [Parameter(Mandatory=$False,
           Position = 1,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the target accounts to disable. Can be multiple accounts.")]
      [Alias('AccountName')]
    [String[]]$Usernames
    )

    BEGIN{

        $OutPath = "C:\DeletedLocalAccounts.csv"
        $ErrorPath = "C:\FailedDeletedLocalAccounts.csv"
        Remove-Item -Path $OutPath -Force -EA SilentlyContinue
        Remove-Item -Path $ErrorPath -Force -EA SilentlyContinue

        $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
        $FileHandle.AutoFlush = $True

        $ErrorFileHandle = New-Object System.IO.StreamWriter -Arg $ErrorPath
        $ErrorFileHandle.AutoFlush = $True

    }

    PROCESS{
        foreach($CN in $CName){
            try{
                if($CN -NotMatch "HostName"){
                    $Computer = [ADSI]"WinNT://$CN"
                    foreach($User in $Usernames){
                        $Computer.Delete("User", $User)

                        $Status = "Success"
                        $Line = "$CN, $User, $Status"
                        $FileHandle.WriteLine($Line)
                }
            }
          }
          catch{
            $Status = "Fail"
            $Line = "$CN, $User, $Status"
            $ErrorFileHandle.WriteLine($Line)
          }
        }
    }

    END{
        
    }
}
