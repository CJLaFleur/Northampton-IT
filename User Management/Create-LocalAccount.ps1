function Create-LocalAccount{
[Cmdletbinding()]
param(
[Parameter(Mandatory=$False,
           Position = 0,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
      [Alias('Hostname','CN', 'ComputerName')]
    [String[]]$CName,

    [Parameter(Mandatory =$False,
      HelpMessage ="Enter the path to write the error log to.")]
      [String]$ErrorLogPath = "C:\New-Account-Errors.txt",

    [Parameter(Mandatory =$False,
      HelpMessage ="Enter the path to write the successfully added computers to.")]
      [String]$OutPath = "C:\New-Accounts.CSV",

    [Parameter(Mandatory=$False,
    HelpMessage ="Set this to attempt to add failed additions from the last attempt.")]
    [Switch]$Retry
    )

    BEGIN{
        $Username = "SU"
        $Pass = "Jt50PtFtN"

        if($Retry){
            
        }
    }

    PROCESS{
        foreach($CN in $CName){
            if($CN -NotMatch "HostName"){
                try{
                    $User = [ADSI]"WinNT://$CN"
                    $UserObj = $User.Create("User", $Username)
                    $UserObj.SetPassword($Pass)
                    $UserObj.SetInfo()
                    $AdminObj = [ADSI]"WinNT://$CN/Administrators"
                    $AdminObj.Add("WinNT://$CN/$Username")
                    Out-File -Path $OutPath -InputObject $CN -NoTypeInformation -Append
                    }
                
                catch{
                    Write-Warning "Failed to create a local admin account on $CN. Errors logged to $ErrorPath"
                    
                }
            }
        }


    }

    END{
        
    }
}