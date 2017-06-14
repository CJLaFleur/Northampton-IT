function Set-Domain{

  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$False,
      ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage= "Enter the target computer name.")]
    [String[]]$HostName,

    [Parameter(Mandatory =$True,
      HelpMessage ="Enter the path to write the error log to.")]
      [String]$ErrorLogPath = "C:\set-cname-errors.txt",

    [Parameter(Mandatory =$True,
      HelpMessage ="Enter the path to write the successfully added computers to.")]
      [String]$NewComputerPath = "C:\New-Computers.txt",

    [Parameter(Mandatory=$False,
    HelpMessage ="Set this to attempt to add failed additions from the last attempt.")]
    [Switch]$Retry,

    [Parameter(Mandatory=$False,
    HelpMessage ="Set this to read from a network scan.")]
    [Switch]$FromScan
    )

  BEGIN {
      $ErrorLogPath = "C:\set-domain-errors.txt"
      $NewComputerPath = "C:\New-Computers.txt"
      Remove-Item -Path $NewComputerPath -Force -EA SilentlyContinue

      if($Retry.IsPresent -EQ $True){
        
        $FileReader = New-Object System.IO.StreamReader -Arg $ErrorLogPath
        
        while($FileReader.EndOfStream -EQ $False){
            $HostName += $FileReader.ReadLine()
        }

        $FileReader.Dispose()
        $FileReader.Close()

        Remove-Item -Path $ErrorLogPath -Force -EA SilentlyContinue

        $FileHandle = New-Object System.IO.StreamWriter -Arg $NewComputerPath 
        $ErrorFileHandle = New-Object System.IO.StreamWriter -Arg $ErrorLogPath


        $FileHandle.AutoFlush = $True
        $ErrorFileHandle.AutoFlush = $True
      }
      elseif($FromScan.IsPresent -EQ $True){
        
        Select-Object -Property HostName | foreach{
                $HostName += $_
                }
        $FileHandle = New-Object System.IO.StreamWriter -Arg $NewComputerPath
        $ErrorFileHandle = New-Object System.IO.StreamWriter -Arg $ErrorLogPath

        $FileHandle.AutoFlush = $True
        $ErrorFileHandle.AutoFlush = $True
      }
      else{
        $FileHandle = New-Object System.IO.StreamWriter -Arg $NewComputerPath
        $ErrorFileHandle = New-Object System.IO.StreamWriter -Arg $ErrorLogPath

        $FileHandle.AutoFlush = $True
        $ErrorFileHandle.AutoFlush = $True
        }

      $ErrorsHappened = $False
      
      $Creds = Get-Credential
  }

  PROCESS{
          foreach ($Computer in $HostName){
                if($Computer -Match 'main.city.northampton.ma.us' -EQ $True){
                  Write-Warning "$Computer is already part of the domain"
                  $ErrorFileHandle.WriteLine($Computer)        
                }

                if($Computer -Match 'main.city.northampton.ma.us' -EQ $False){
                    try{
                        Add-Computer -ComputerName $Computer -DomainName main.city.northampton.ma.us -Credential $Creds -ErrorAction Stop
                        $FileHandle.WriteLine($Computer)
                        $FileHandle.WriteLine()
                        }
                    catch {
                        Write-Warning "Couldn't connect to $Computer"
                        $ErrorFileHandle.WriteLine($Computer)
                        $ErrorsHappened = $True
                }
            }
          }
     }

  END {
    $FileHandle.Close()

    if($Retry -EQ $False){
            $ErrorFileHandle.Close()
        }
    if ($ErrorsHappened) {
      Write-Warning "The computers that were not added to the domain were logged to $ErrorLogPath."
      }
    }
}
