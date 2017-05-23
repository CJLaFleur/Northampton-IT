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

   $StartIP.Length
   $EndIP.Length

    for([Int] $i = 0, $i -LT $StartLength; $i++){
        if($StartIP[$i] -EQ "."){
           $BitCount++
        }
        if ($BitCount -EQ 3) {
            $Subnet = $StartIP
            [Int] $StartLastBit = $StartIP.Substring($i)
            break
        }
    }

    for([Int] $i = 0, $i -LT $EndLength; $i++){
        if($EndIP[$i] -EQ "."){
           $BitCount++
        }
        if ($BitCount -EQ 3) {
            [Int] $EndLastBit = $EndIP.Substring($i)
            $BitCount = 0
            break
        }
    }

    for([Int] $i = $Subnet.Length; $i -GE 0; $i--){
            $Subnet = $Subnet -Replace ".$"
            if($Subnet[$i] -EQ "."){
                break
            }
        }

   $IPrange = "$($Subnet) $($StartLastBit..$EndLastBit)"

   foreach($IP in $IPrange) {
       Test-Connection $IP -Count 1 -Quiet | Where-Object {$_ -EQ "True"}
   }
}
