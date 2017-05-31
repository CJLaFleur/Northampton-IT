﻿function Get-NetComputers {

    [cmdletbinding()]
    Param(

        [Parameter(Mandatory = $True,
                   Position =0,
                   ValueFromPipeline = $True,
                   ValueFromPipelineByPropertyName = $True,
                   HelpMessage ="Specify the first IP in the range(s).")]
        [Alias('Start')]
        [String]$StartIP,

        [Parameter(Mandatory = $True,
                   Position =1,
                   HelpMessage ="Enter the last IP in the range(s).")]
        [Alias('End')]
        [String]$EndIP,

        [Parameter(Mandatory = $False,
                  HelpMessage ="Enter the subnets you want to scan.")]

        #This is an array of strings intended to store as many subnets as the user wishes. It is named Multiple so it is clear as a parameter.
        [String[]]$Multiple
    )

    [Int]$Count = 0
    [Int]$BitCount = 0
    [String]$Subnet
    [int]$StartLastBit
    [int]$EndLastBit
    $IPQueue = New-Object System.Collections.Queue
    $ComputerInfo = @()

    Clear-Host

    for([Int]$i = 0; $i -LT $StartIP.Length; $i++){
        if($StartIP[$i] -EQ "."){
           $BitCount++
        }
        if ($BitCount -EQ 3) {
            $Subnet = $StartIP
            [String] $Temp = $StartIP.Substring($i)
            $Temp = $Temp.Trim(".")
            $StartLastBit = [convert]::ToInt32($Temp, 10)
            $BitCount = 0
                break
        }
    }

    for([Int]$j = 0; $j -LT $EndIP.Length; $j++){
        if($EndIP[$j] -EQ "."){
           $BitCount++
        }
        if ($BitCount -EQ 3) {
            [String] $Temp = $EndIP.Substring($j)
            $Temp = $Temp.Trim(".")
            $EndLastBit = [convert]::ToInt32($Temp, 10)
            $BitCount = 0
                break
        }
    }

    for([Int]$k = 0; $k -LT $Subnet.Length; $k++){
        if($Subnet[$k] -EQ "."){
           $BitCount++
        }
        if ($BitCount -EQ 3) {
            [String] $Temp = $Subnet.Substring(0, $k)
            $Subnet = $Temp + "."
            $BitCount = 0
                break
        }
    }

   while($StartLastBit -LE $EndLastBit){
        [String]$Temp = $Subnet + $StartLastBit
        $IPQueue.Enqueue($Temp)
        $StartLastBit++
   }

   function Multithreader{

    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,20)
    $RunspacePool.Open()

    $Count = $IPQueue.Count

    for($i = 0; $i -LT $Count; $i++){
        $Job = [powershell]::Create()
        $Job.RunspacePool = $RunspacePool
        $Job.AddScript({Get-ComputerInfo})
        $Job.BeginInvoke()
    }
  }


   function Get-ComputerInfo {
        $IP = $IPQueue.Dequeue()
          [Bool]$IsConnected = Test-Connection $IP -Count 1 -Quiet -BufferSize 1 -TimeToLive 1 | Where-Object {$_ -EQ "True"}

          if($IsConnected -EQ "True"){
          $HostN = [System.Net.DNS]::GetHostEntry("$IP")
          $Properties = @{IPAddress = $IP
                          Hostname = $HostN.HostName
                          Status = 'Connected'
                          }
          $IPData = New-Object -TypeName PSObject -Property $Properties
          $ComputerInfo += $IPData
          return $ComputerInfo | FL
          }
          else{
            Start-Sleep -Milliseconds 1
          }
        }
}