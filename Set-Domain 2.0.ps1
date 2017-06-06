$ErrorLogPath = "C:\Users\clafleur\Documents\set-domain-errors.txt"
$NewComputerPath = "C:\Users\clafleur\Documents\New-Computers.txt"

function Set-Domain{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$False,
      ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage= "Enter the target computer name.")]
    [String[]]$HostName
    )

  BEGIN {
      [Bool]$Retry = Test-Path -Path $ErrorLogPath
      Remove-Item -Path $NewComputerPath -Force -EA SilentlyContinue

      if($Retry -EQ $True ){
        
        $FileReader = New-Object System.IO.StreamReader -Arg $ErrorLogPath
        while($FileReader.EndOfStream -EQ $False){
            $HostName += $FileReader.ReadLine()
        }
        $FileReader.Dispose()
        $FileReader.Close()

        Remove-Item -Path $ErrorLogPath -Force -EA SilentlyContinue

        $FileHandle = New-Object System.IO.StreamWriter -Arg $NewComputerPath 
        $ErrorFileHandle = New-Object System.IO.StreamWriter -Arg $ErrorLogPath

        $Retry = $True
      }
      else{
        $FileHandle = New-Object System.IO.StreamWriter -Arg $NewComputerPath
        $ErrorFileHandle = New-Object System.IO.StreamWriter -Arg $ErrorLogPath
        }

      $ErrorsHappened = $False
      
      $Creds = Get-Credential
  }

  PROCESS{
          foreach ($Computer in $HostName){
                if($Computer -Match 'main.city.northampton.ma.us' -EQ $False){
                    try{
                        Add-Computer -ComputerName $Computer -DomainName main.city.northampton.ma.us -Credential $Creds -ErrorAction Stop
                        $FileHandle.WriteLine($Computer)
                        $FileHandle.WriteLine()
                        }
                    catch {
                        Write-Verbose "Couldn't connect to $Computer"
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
