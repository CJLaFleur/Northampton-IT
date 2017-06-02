function Get-NetComputers {

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
        [String]$EndIP
    )

    [Int]$Count = 0
    [Int]$BitCount = 0
    [String]$Subnet
    [int]$StartLastBit
    [int]$EndLastBit
    [System.Net.IPAddress[]]$IPRange

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
        $IPRange += @($Subnet + $StartLastBit)
        $StartLastBit++
   }

  function Get-ComputerInfo{ 
        foreach($IP in $IPRange){
         [Bool]$IsConnected = Test-Connection $IP -AsJob | Where-Object {$_ -EQ "True"} | Receive-Job

          if($IsConnected -EQ "True"){
                try{
                    $HostN = [System.Net.DNS]::GetHostEntry("$IP")
                   }
                catch{
                    Out-Null
                     }
                $Properties = @{IPAddress = $IP
                          Hostname = $HostN.HostName
                          Status = 'Connected'
                          }
                $IPData = New-Object -TypeName PSObject -Property $Properties
                Write-Output $IPData | FL
        }
        else{
            Start-Sleep -Milliseconds 1
            }
    }
  }
  Get-ComputerInfo
}
