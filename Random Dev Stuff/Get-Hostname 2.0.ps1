function Get-Hostname {
  Param(

#Taking these values as pipleine input from Get-IPs saves a great deal of logic and processing time.
#I will not implement manual specification of IPs and subnets as there is no reason to attempt to return hostnames from unassigned IPs.
#If for some reason you feel the need to implement this feature all the logic from Get-IPs should work here with small modifications.

  [Parameter(Mandatory = $True,
             ValueFromPipeline = $True,
             ValueFromPipelineByPropertyName = $True,
             HelpMessage ="This is intended to receive pipeline input from Get-IPs.")]
  [String[]] $IPRange,

[Parameter(Mandatory = $False,
             ValueFromPipeline = $True,
             ValueFromPipelineByPropertyName = $True,
             HelpMessage ="Specify the subnets you wish to get hostames from (This can be a list passed from Get-IPs).")]
  [String[]] $Multiple
)
    foreach($IP in $IPRange){
    [System.Net.DNS]::GetHostEntry("$IP")
  }
}
