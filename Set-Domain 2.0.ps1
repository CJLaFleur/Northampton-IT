$LogPath = "C:\Users\set-domain-errors.txt"

function Set-Domain{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$True,
      ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage= "Enter the target computer name.")]
      [Alias('Hostname','CN', 'ComputerName')]
    [String[]]$CName,

    [Parameter(Mandatory=$True,
    HelpMessage= "Enter the target computer name.")]
    [Alias('Auth')]


    [Parameter()]
    [string]$ErrorLogFilePath = $LogPath
    )

  BEGIN {
      Remove-Item -Path $ErrorLogFilePath -Force -EA SilentlyContinue
      $ErrorsHappened = $False
  }

  PROCESS{
    foreach ($Computer in $CName){

          Foreach ($Cred in $Credentials){
          try{
          Add-Computer -ComputerName $Computer -DomainName main.city.northampton.ma.us -Credential $Creds
          }
        }
      }
        catch{
          Write-Verbose "Couldn't connect to $Computer"
          $Computer | Out-File $ErrorLogFilePath -Append
          $ErrorsHappened = $True
        }
      }

  END {
    if ($ErrorsHappened) {
      Write-Warning "Errors logged to $ErrorLogFilePath."
      }
    }
   }
}

<#$creds = Get-Credential
For Each ($i in $collection)
{
   My-Cmdlet -Credential $creds
}
#>
