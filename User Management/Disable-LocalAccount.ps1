function Disable-LocalAccount{
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
        $Account = @()
        $DisableUser = 2
    }

    PROCESS{
        foreach($CN in $CName){
            foreach($User in $Usernames){
                    $Account += [ADSI]"WinNT://$CN/$User"
            }
        }

        for([Int]$i = 0; $i -LT $Account.Count; $i++){
            $Account[$i].UserFlags = $DisableUser
            $Account[$i].SetInfo()
        }
    }

    END{
        return $Account
    }
}