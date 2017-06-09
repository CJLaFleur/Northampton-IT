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
            $AccountInfo = New-Object -TypeName PSObject
            
            if($CN -NotMatch "HostName"){

                $Results = Get-CimInstance win32_useraccount -ComputerName $CN |
                Where-Object {$_.Name -EQ "MIS" -OR $_.Name -EQ "Localadmin"} |
                Select-Object -Property "Name", "Disabled"
            
                $AccountInfo | Add-Member -MemberType NoteProperty -Name ComputerName -Value $CN
                $AccountInfo | Add-Member -MemberType NoteProperty -Name AccountName -Value $Results.Name
                $AccountInfo | Add-Member -MemberType NoteProperty -Name Disabled -Value $Results.Disabled

                $AccountList.Add($AccountInfo)

                Export-Csv -Path $OutPath -InputObject $AccountInfo -NoTypeInformation -Append
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