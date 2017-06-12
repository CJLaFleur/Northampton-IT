function Get-LocalAdmin{

[CmdletBinding()]
  param(
[Parameter(Mandatory=$False,
           Position = 0,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
      [Alias('Hostname','CN', 'ComputerName')]
    [String[]]$CName,

    [Parameter(Mandatory=$False,
    HelpMessage ="Set this to read from a network scan.")]
    [Switch]$FromScan
    )

    BEGIN{
    $OutPath = "C:\NetLocalAccounts.CSV"
    Remove-Item -Path $OutPath -Force -EA SilentlyContinue
    $AccountList = New-Object System.Collections.Generic.List[System.Object]

    #$FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
    #$FileHandle.AutoFlush = $True

        if($FromScan){
            Select-Object -Property HostName | foreach{
                $CName += $_
            }
        }


    }

    PROCESS{
        foreach($CN in $CName){
            
            if($CN -NotMatch "HostName"){

                $Results = Get-WMIObject -Class win32_useraccount -ComputerName $CN -Namespace "root\cimv2" -Filter "LocalAccount='$True'" |
                Where-Object {$_.Name -EQ "MIS" -OR $_.Name -EQ "Localadmin"} |
                Select-Object -Property "Name", "Disabled"

                    $AccountInfo = New-Object -TypeName PSObject
                    $AccountInfo | Add-Member -MemberType NoteProperty -Name ComputerName -Value $CN
                    $AccountInfo | Add-Member -MemberType NoteProperty -Name AccountName -Value $Results.Name -Force
                    $AccountInfo | Add-Member -MemberType NoteProperty -Name Disabled -Value $Results.Disabled -Force

                    $AccountList.Add($AccountInfo)
                    
                #Export-Csv -Path $OutPath -InputObject $AccountInfo -NoTypeInformation -Append
            }
            

            
            #$FileHandle.WriteLine($Results.Name)
            #$FileHandle.WriteLine($Results.Disabled)
        }
    }

    END{
        <#$FileHandle.Flush()
        $FileHandle.Dispose()
        $FileHandle.Close()
        #>
        
        
        
        
        return $AccountList
    }


}


