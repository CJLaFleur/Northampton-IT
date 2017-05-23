
$LogFile = "C:\Users\set-cname-errors.txt"

function Set-CName{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$True,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the target computer name.")]
      [Alias('Hostname','CN', 'ComputerName')]
    [String[]]$CName,
    [Parameter(Mandatory = $True,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the new computer name.")]
      [Alias('NewName')]
      [String[]]$NewCName,
    [Parameter(Mandatory = $True,
      HelpMessage = "Enter your username.")]
      $Username,

      [Parameter()]
      [string]$ErrorLogFilePath = $LogFile
  )

  BEGIN {
      Remove-Item -Path $ErrorLogFilePath -Force -EA SilentlyContinue
      $ErrorsHappened = $False
  }

  PROCESS{

  For ($i = 0; $i -lt $CName.Length; $i++){
    try{
        Rename-Computer -ComputerName $CName[$i] -NewName $NewCName[$i] -DomainCredential $Username
        }
    catch{
    $CName[$i] | Out-File $ErrorLogFilePath -Append
    $ErrorsHappened = $True
    }
   }
  
  }
  END {
      if ($ErrorsHappened) {
          Write-Verbose "Errors logged to $ErrorLogFilePath."
      }
    }
}

