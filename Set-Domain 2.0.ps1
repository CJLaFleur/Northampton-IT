$LogPath = "C:\Users\clafleur\set-domain-errors.txt"

function Set-Domain{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$True,
      ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage= "Enter the target computer name.")]
      [Alias('HostName','CN', 'ComputerName')]
    [String[]]$CName,

    [Parameter()]
    [string]$ErrorLogFilePath = $LogPath
    )

  BEGIN {
      $FileHandle = New-Object System.IO.File

      $FileHandle.Delete("C:\Users\clafleur\set-domain-errors.txt")
      $FileHandle.Delete("C:\Users\clafleur\New-Computers.txt")

      $ErrorsHappened = $False
      
      $Creds = Get-Credential
  }

  PROCESS{

    foreach ($Computer in $CName){
       if($Computer -Match 'main.city.northampton.ma.us' -EQ $False){
          try{
            Add-Computer -ComputerName $Computer -DomainName main.city.northampton.ma.us -Credential $Creds
            $FileHandle.AppendAllText("C:\Users\clafleur\New-Computers.txt", $Computer)
          }
          catch{
            Write-Verbose "Couldn't connect to $Computer"
            $FileHandle.AppendAllText($ErrorLogFilePath, $Computer)
            $ErrorsHappened = $True
            }
         }
       }
     }

  END {
    if ($ErrorsHappened) {
      Write-Warning "Errors logged to $ErrorLogFilePath."
      }
    }
}
