$LogPath = "C:\Users\clafleur\Documents\set-cname-errors.txt"
$NewComputerPath = "C:\Users\clafleur\Documents\New-Computers.txt"

function Set-CName{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$False,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the target computer name.")]
      [Alias('Hostname','CN', 'ComputerName')]
    [String[]]$CName,
    
    [Parameter(Mandatory = $False,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage = "Enter the new computer name.")]
      [Alias('NewName')]
      [String[]]$NewCName,

      [string]$ErrorLogFilePath = $LogPath
  )

  

  BEGIN {

      if($NewComputerPath -NE $Null){
        $FileHandle = New-Object System.IO.StreamReader -Arg $NewComputerPath
      }

      if($ErrorLogFilePath -NE $Null){
        $FileHandle = New-Object System.IO.StreamReader -Arg $ErrorLogFilePath
      }
  
      while ($FileHandle.EndOfStream -EQ $False) {
        $CName += $FileHandle.ReadLine()
        $NewCName += $FileHandle.ReadLine()
        }
        $ErrorsHappened = $False
      }


  PROCESS{

  for ($i = 0; $i -lt $CName.Length; $i++){
    try{
        Rename-Computer -ComputerName $CName[$i] -NewName $NewCName[$i] -DomainCredential $Username -ErrorAction Stop
        }
    catch{
        $CName[$i] | Out-File $ErrorLogFilePath -Append
        $ErrorsHappened = $True
    }
   }
  
  }
  END {
      $FileHandle.Dispose()
      $FileHandle.Close()
      if ($ErrorsHappened) {
          Write-Verbose "The Computers unable to be renamed were logged to $ErrorLogFilePath."
      }
    }
}

