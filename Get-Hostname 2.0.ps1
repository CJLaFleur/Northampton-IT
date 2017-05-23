function Get-Hostname {
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

    foreach($IP in $IPRange)
    [System.Net.DNS]::GetHostEntry("$IP")
}
