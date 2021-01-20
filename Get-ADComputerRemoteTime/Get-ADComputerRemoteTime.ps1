Function Get-ADComputerRemoteTime {

  [CmdletBinding()]
  Param(
    [Parameter(HelpMessage = "The name of the remote computer")]
    [string]$ComputerName
  )

  #Get the timezone of the remote computer
  $TimeZone = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-TimeZone}

  #Get the Time of the remote computer
  $Time = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Date}
  $CurrentTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId(($Time), "$($TimeZone.ID)")

  # Echo the time
  Return "The current time of the remote machine is: $($CurrentTime) it's TimeZone ID is: $($TimeZone.ID)"
}
