function Disable-LocalAccount{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$False,
           Position = 0,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
      [Alias('HostName','CN', 'ComputerName')]
    [String[]]$CName
    )

    BEGIN{
    
    }

    PROCESS{
        foreach($CN in $CName){
            try{
                $Account = [ADSI]"WinNT://$CN/Administrator"
                $Account.SetPassword("Admin123")
                $Account.UserFlags = 2 + 64 + 65536
                $Account.SetInfo()
            }
            catch{
                
            }
        }
    }

    END{
       
    }
}
