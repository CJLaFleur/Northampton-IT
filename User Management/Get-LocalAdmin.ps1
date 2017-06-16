function Get-LocalAdmin{

[CmdletBinding()]
  param(
[Parameter(Mandatory=$False,
           Position = 0,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the target computer name to be targeted. Can be multiple names.")]
      [Alias('HostName','CN', 'ComputerName')]
    [String[]]$CName
    )

    BEGIN{
    $OutPath = "C:\NetLocalAccounts.CSV"
    Remove-Item -Path $OutPath -Force -EA SilentlyContinue
    $AccountList = New-Object System.Collections.Generic.List[System.Object]

    $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
    $FileHandle.AutoFlush = $True

    }

    PROCESS{
        foreach($CN in $CName){

            if($CN -NotMatch "HostName"){
               try{
                $Results = Get-CIMInstance -Class win32_useraccount -ComputerName $CN -Namespace "root\cimv2" -Filter "LocalAccount='$True'" |
                Where-Object {$_.Name -EQ "MIS" -OR $_.Name -EQ "Localadmin"} |
                Select-Object -Property "Name", "Disabled"

                    $AccountInfo = New-Object -TypeName PSObject
                    $AccountInfo | Add-Member -MemberType NoteProperty -Name ComputerName -Value $CN
                    $AccountInfo | Add-Member -MemberType NoteProperty -Name AccountName -Value $Results.Name -Force
                    $AccountInfo | Add-Member -MemberType NoteProperty -Name Disabled -Value $Results.Disabled -Force

                    if($Results.Name -NE $Null){
                        $AccountList.Add($AccountInfo)

                        $Line = "$CN, " + $Results.Name + ", " + $Results.Disabled
                        $FileHandle.WriteLine($Line)
                    }
                }
                catch{
                   $AccountInfo | Add-Member -MemberType NoteProperty -Name ComputerName -Value $CN
                   $AccountInfo | Add-Member -MemberType NoteProperty -Name AccountName -Value "The account name could not be resolved" -Force
                   $AccountInfo | Add-Member -MemberType NoteProperty -Name Disabled -Value $Null -Force
                }
            }
        }
    }

    END{
        $FileHandle.Flush()
        $FileHandle.Dispose()
        $FileHandle.Close()
        return $AccountList
    }


}
