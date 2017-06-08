function Get-IPs {
    #Parameters
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

    #Non-parameter variables
    [Int]$Count = 0
    [Int]$BitCount = 0
    [String]$Subnet
    [int]$StartLastBit
    [int]$EndLastBit
    $IPQueue = New-Object System.Collections.Queue

    Clear-Host

    #Parse First IP Address
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

    #Parse end IP Address
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

    #Trims $Subnet down to three octets
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

   #Initializes the array of the range of IPs.
   while($StartLastBit -LE $EndLastBit){
        [String]$Temp = $Subnet + $StartLastBit
        $IPQueue.Enqueue($Temp)
        $StartLastBit++
   }


   ###############################################-Multithreader Function-#####################################################
   function Multithreader(){

        BEGIN{
            $SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
            $SessionState.Variables.Add(
            (New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry('IPRange', $IPQueue, 'Range of IP addresses')))

            $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, 20, $SessionState, $Host)
            $RunspacePool.BeginOpen()

            $Controller = [PowerShell]::Create()
            $Controller.RunspacePool = $RunspacePool


        }

        PROCESS{
            $Controller.AddScript({
                   if($IPQueue.GetEnumerator() -NE 0 -And $IPQueue.GetEnumerator() -GT 19){
                        for([Int]$i = 0; $i -LT 20; $i++){
                            $i | % $Thread$_
                }
                
            })
        }
   }







   #############################################-End Multithreader-############################################################

   #Iterates through each IP in the array and runs Test-Connection against them.


   function Scan-Network {

   foreach($IP in $IPRange){

          [Bool]$IsConnected = Test-Connection $IP -Count 1 -Quiet -BufferSize 1 -TimeToLive 1 | Where-Object {$_ -EQ "True"}

          if($IsConnected -EQ "True"){
          $HostN = [System.Net.DNS]::GetHostEntry("$IP")
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
    Scan-Network
}
