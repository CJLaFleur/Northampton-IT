class Network{

    [Int]$Count = 0
    [Int]$OctetCount = 0
    [String]$StartIP
    [String]$EndIP
    [String]$Subnet
    [int]$StartLastOctet
    [int]$EndLastOctet
    

    Network($StartIP, $EndIP){
        $this.StartIP = $StartIP
        $this.EndIP = $EndIP
        $IPQueue = New-Object System.Collections.Queue
        $Ping = New-Object System.Net.Networkinformation.Ping
        $PingOptions = New-Object System.Net.Networkinformation.PingOptions
        $PingOptions.PingOptions(.1, $False)
        $ComputerList = New-Object System.Collections.Generic.List[System.Object]
    }

    [Void] GetNetComputers() {
    [Int]$OctetCount = 0

    Clear-Host

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
          $Test = $Ping.Send($IP, 1, .1, $PingOptions)
          if($Test.Status -EQ 'Success'){
            try{
                $HostN = [System.Net.DNS]::GetHostEntry("$IP")
                $ComputerInfo | Add-Member -Type NoteProperty -Name IPAddress -Value $IP -Force
                $ComputerInfo | Add-Member -Type NoteProperty -Name HostName -Value $HostN.HostName -Force
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
        Get-ComputerInfo
        
        Return $ComputerList
}

}