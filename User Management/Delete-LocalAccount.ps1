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
        $Computer = @()
    }

    PROCESS{
        foreach($CN in $CName){
                    $Computer += [ADSI]"WinNT://$CN"
            }

        foreach($Comp in $Computer){
            foreach($User in $Usernames){
                $Comp.Delete("User", $User)
            }
        }
    }

    END{
        return $Account
    }
}