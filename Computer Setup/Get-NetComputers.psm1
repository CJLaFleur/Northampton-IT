<#
.Synopsis
This function adds computers to a domain.

.Description
This function scans subnets for active IP Addresses, and resolves them to their HostNames.
It returns a List object containing the IPs and HostNames

.Parameter Multiple
This parameter allows for a user to specify multiple subnets to scan.
Type each subnet in the form of x.x.x where x represents an octet in an IP.
When using this, instead of specifying full IPs in the first two positions as if scanning in a single
subnet, specify only the final octet range you want to use, and then the subnets following this
parameter. When using this parameter, each individual input must be surrounded in quotes, and
subnets should be entered in a comma-separated list.

.Notes
Author: Connor James LaFleur
Copyright: Connor James LaFleur, 6/8/17 2:31PM Eastern Time
#>

function Get-NetComputers {

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True,
                   Position =0,
                   ValueFromPipeline = $True,
                   ValueFromPipelineByPropertyName = $True,
                   HelpMessage ="Specify the first IP in the range(s).")]
        [String]$StartIP,

        [Parameter(Mandatory = $True,
                   Position =1,
                   HelpMessage ="Enter the last IP in the range(s).")]
        [String]$EndIP,

        [Parameter(Mandatory = $False,
        HelpMessage ="Specify the subnets you wish to scan.")]
        [Alias('Multiple')]
        [String[]]$SubnetArray

    )

    BEGIN{
    [Int]$Count = 0
    [Int]$OctetCount = 0
    [String]$Subnet = $Null
    [int]$StartLastOctet = $Null
    [int]$EndLastOctet = $Null
    $HostNames
    $IPQueue = New-Object System.Collections.Queue
    $Ping = New-Object System.Net.Networkinformation.Ping
    $ComputerList = New-Object System.Collections.Generic.List[System.Object]
    $OutPath = "C:\Users\clafleur\Documents\NetComputers.txt"
    $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
    $FileHandle.AutoFlush = $True

    }

    PROCESS{
    for([Int]$i = 0; $i -LT $StartIP.Length; $i++){
        if($StartIP[$i] -EQ "."){
           $OctetCount++
        }
        if ($OctetCount -EQ 3) {
            $Subnet = $StartIP
            [String] $Temp = $StartIP.Substring($i)
            $Temp = $Temp.Trim(".")
            $StartLastOctet = [convert]::ToInt32($Temp, 10)
            $OctetCount = 0
                break
        }
    }

    for([Int]$j = 0; $j -LT $EndIP.Length; $j++){
        if($EndIP[$j] -EQ "."){
           $OctetCount++
        }
        if ($OctetCount -EQ 3) {
            [String] $Temp = $EndIP.Substring($j)
            $Temp = $Temp.Trim(".")
            $EndLastOctet = [convert]::ToInt32($Temp, 10)
            $OctetCount = 0
                break
        }
    }

    if($SubnetArray -EQ $Null){
        for([Int]$k = 0; $k -LT $Subnet.Length; $k++){
            if($Subnet[$k] -EQ "."){
           $OctetCount++
            }
            if ($OctetCount -EQ 3) {
            [String] $Temp = $Subnet.Substring(0, $k)
            $Subnet = $Temp + "."
            $OctetCount = 0
                break
            }
        }
    }

    else{


    }

   while($StartLastOctet -LE $EndLastOctet){
        [String]$Temp = $Subnet + $StartLastOctet
        $IPQueue.Enqueue($Temp)
        $StartLastOctet++
   }

   <#function Multithreader{

    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,50)
    $RunspacePool.Open()

    $Count = $IPQueue.Count

    $Jobs = @()

    for($i = 0; $i -LT $Count; $i++){
        $Job = [PowerShell]::Create()
        $Job.RunspacePool = $RunspacePool
        $Job.AddScript({Get-ComputerInfo})
        $Jobs += New-Object -TypeName PSObject -Property @{
            Thread = $Job
            Handle = $Job.BeginInvoke()
        }
    }

    foreach ($Job in $Jobs){
        if($Job.Handle.IsCompleted -EQ $True){
            $Job.Thread.EndInvoke($Job.Handle)
            $Job.Thread.Dispose()
        }
    }

    $RunspacePool.Close() | Out-Null
    $RunspacePool.Dispose() | Out-Null
  }#>

   function Get-ComputerInfo {
        $NumIPs = $IPQueue.Count

        for([Int]$i = 0; $i -LT $NumIPs; $i++){
          $ComputerInfo = New-Object -TypeName PSObject
          $IP = $IPQueue.Dequeue()
          $Test = $Ping.Send($IP, 1, .1)
          if($Test.Status -EQ 'Success'){
            try{
                $HostN = [System.Net.DNS]::GetHostEntry("$IP")
                $ComputerInfo | Add-Member -Type NoteProperty -Name IPAddress -Value $IP -Force
                $ComputerInfo | Add-Member -Type NoteProperty -Name HostName -Value $HostN.HostName -Force

                $FileHandle.WriteLine($HostN.HostName.ToString())
                }
                catch{
                    $ComputerInfo | Add-Member -Type NoteProperty -Name IPAddress -Value $IP -Force
                    $ComputerInfo | Add-Member -Type NoteProperty -Name HostName -Value 'HostName could not be resolved' -Force
                }
                $ComputerList.Add($ComputerInfo)
             }
          else{
            Start-Sleep -Milliseconds .1
          }
        }
      }
    }
     END{
        Get-ComputerInfo
        return $ComputerList
        }
}
