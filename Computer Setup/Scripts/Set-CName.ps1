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

    [Parameter(Mandatory =$False,
      HelpMessage ="Enter the path to write the error log to.")]
      [String]$ErrorLogPath = "C:\set-cname-errors.txt",

      [Parameter(Mandatory =$False,
      HelpMessage ="Enter the path to the text file that computers are going to be added from.")]
      [String]$NewComputerPath = "C:\New-Computers.csv",

    [Parameter(Mandatory=$False,
      HelpMessage ="Set this to attempt to add failed additions from the last attempt.")]
      [Switch]$Retry,

    [Parameter(Mandatory=$False,
      HelpMessage ="Set this to read from a CSV file.")]
      [Switch]$FromCSV
  )

  BEGIN {
      
      $Creds = Get-Credential
      $ErrorActionPreference = "SilentlyContinue"

      if($Retry){

        $FileReader = New-Object System.IO.StreamReader -Arg $ErrorLogPath

        while($FileReader.EndOfStream -EQ $False){
            $HostName += $FileReader.ReadLine()
        }

        $FileReader.Dispose()
        $FileReader.Close()

        Remove-Item -Path $ErrorLogPath -Force -EA SilentlyContinue

        $ErrorFileHandle = New-Object System.IO.StreamWriter -Arg $ErrorLogPath


        $FileHandle.AutoFlush = $True
        $ErrorFileHandle.AutoFlush = $True
      }
      elseif($FromCSV){

        $FileReader = New-Object System.IO.StreamReader -Arg $NewComputerPath

        while($FileReader.EndOfStream -EQ $False){
            $CName += $FileReader.ReadLine()
            $NewCname += $FileReader.ReadLine()
            }

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
      }


  PROCESS{

  $ErrorActionPreference = "Stop"
  for ($i = 0; $i -lt $CName.Length; $i++){
    try{
        Rename-Computer -ComputerName $CName[$i] -NewName $NewCName[$i] -DomainCredential $Username -ErrorAction Stop
        }
        catch{
            Write-Warning "Couldn't rename " + $CName[$i] + " to " + $NewCName[$i]
            $ErrorFileHandle.WriteLine($CName[$i])
            $ErrorFileHandle.WriteLine($NewCName[$i])
            $ErrorsHappened = $True
        }
   }

  }
  END {
      $ErrorActionPreference = "SilentlyContinue"
      $FileHandle.Dispose()
      $FileHandle.Close()
      if ($ErrorsHappened) {
          Write-Warning "The Computers unable to be renamed were logged to $ErrorLogFilePath."
      }
    }
}
