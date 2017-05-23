function Get-IPs {

    [cmdletbinding()]
    Param(

        [Parameter(Mandatory = $True,
                   Position =0,
                   ValueFromPipeline = $True,
                   ValueFromPipelineByPropertyName = $True,
                   HelpMessage ="Specify the first IP in the range(s).")]
        [Alias('Start')]
        [String] $StartIP,

        [Parameter(Mandatory = $True,
                   Position =1,
                   HelpMessage ="Enter the last IP in the range(s).")]
        [Alias('End')]
        [String] $EndIP
    )
    [Int]$BitCount = 0
    [String]$Subnet

    for([Int] $i = 0, $i -LT $StartIP.Length; $i++){
        if($StartIP[$i] -EQ "."){
           $BitCount++
        }
        if ($BitCount -EQ 3) {
            $Subnet = $StartIP
            [Int] $StartLastBit = $StartIP.Substring($i)
            break
        }
    }

    for([Int] $j = 0, $j -LT $EndIP.Length; $j++){
        if($EndIP[$j] -EQ "."){
           $BitCount++
        }
        if ($BitCount -EQ 3) {
            [Int] $EndLastBit = $EndIP.Substring($j)
            $BitCount = 0
            break
        }
    }

    for([Int] $k = $Subnet.Length; $k -GE 0; $k--){
            $Subnet = $Subnet -Replace ".$"
            if($Subnet[$k] -EQ "."){
                break
            }
        }

   [String[]] $IPrange = "$($Subnet) $($StartLastBit..$EndLastBit)"

   foreach($IP in $IPrange) {
       Test-Connection $IP -Count 1 -Quiet | Where-Object {$_ -EQ "True"}
            $Properties = @{IPAddress = $IP
                            Status = 'Connected'
                           }
   }
}
