function Create-LocalAccount{
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
        $OutPath = "C:\NetLocalAccounts.CSV"
        Remove-Item -Path $OutPath -Force -EA SilentlyContinue
        $Username = "SU"
        $Password = "Jt50PtFtN"

        $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
        $FileHandle.AutoFlush = $True
    }

    PROCESS{
        foreach($CN in $CName){
            try{
                    $Computer = [ADSI]"WinNT://$CN"
                    $CompObj = $Computer.Create("User", $Username)
                    $CompObj.SetPassword($Password)
                    $CompObj.SetInfo()
                    $AdminObj = [ADSI]"WinNT://$CN/Administrators"
                    $AdminObj.Add("WinNT://$CN/Test")
                }
                catch{
                     Export-Csv -Path $OutPath -InputObject $AccountInfo -NoTypeInformation -Append
                }
            }
    }

    END{

    }
}
