Class Network{

  #Beginning and end of IP range in a given Subnet, as well as the subnet and IPRange as an array of strings.
  [String] $StartIP
  [String] $EndIP
  [String] $Subnet
  [String] $FirstSubnet
  [String] $LastSubnet
  [String[]] $IPrange

  #Constructor to be used when working with only one subnet.
  Network($StartIP, $EndIP){
    $This.StartIP = $StartIP
    $This.EndIP = $EndIP
  }

  #Constructor to be used when working with multiple subnets.
  Network($StartIP, $EndIP, $FirstSubnet, $LastSubnet){
    $This.StartIP = $StartIP
    $This.EndIP = $EndIP
    $This.FirstSubnet = $FirstSubnet
    $This.LastSubnet = $LastSubnet
  }

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

   $IPrange = "$($Subnet) $($StartLastBit..$EndLastBit)"

   foreach($IP in $IPrange) {
       Test-Connection $IP -Count 1 -Quiet | Where-Object {$_ -EQ "True"}
            $Properties = @{IPAddress = $IP
                            Status = 'Connected'
                           }
   }
}
