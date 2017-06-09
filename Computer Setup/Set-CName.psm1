<#
.Synopsis
This function adds computers to a domain.

.Description
This function batch renames computers. It accepts input from a text file where the user
should specify the target computer name and new computer name on successive lines.
This is intended to be used with Set-Domain, which will generate a list of computer names,
and insert a carriage return where the new name should be entered manually.

Alternatively the names can be specified manually in the shell.

This can also automatically retry adding failed computers from an error log, using the -Retry parameter.

This should be run as an administrator as it requires permission to save files to the root directory
of the hard drive.

.Notes
Author: Connor James LaFleur
Copyright: Connor James LaFleur, 6/8/17 2:54PM Eastern Time
#>

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

    [Parameter(Mandatory =$True,
      HelpMessage ="Enter the path to write the error log to.")]
      [String]$ErrorLogPath = "C:\set-cname-errors.txt",

      [Parameter(Mandatory =$False,
      HelpMessage ="Enter the path to the text file that computers are going to be added from.")]
      [String]$NewComputerPath = "C:\New-Computers.txt",

    [Parameter(Mandatory=$False,
      HelpMessage ="Set this to attempt to add failed additions from the last attempt.")]
      [Switch]$Retry,

    [Parameter(Mandatory=$False,
      HelpMessage ="Set this to read from a text file.")]
      [Switch]$FromText
  )

  BEGIN {


      if($Retry.IsPresent -EQ $True){

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
      elseif($FromText.IsPresent -EQ $True){

        $FileReader = New-Object System.IO.StreamReader -Arg $NewComputerPath

        while($FileReader.EndOfStream -EQ $False){
            $HostName += $FileReader.ReadLine()
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

      $Creds = Get-Credential
      }


  PROCESS{

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
      $FileHandle.Dispose()
      $FileHandle.Close()
      if ($ErrorsHappened) {
          Write-Warning "The Computers unable to be renamed were logged to $ErrorLogFilePath."
      }
    }
}
