# Get-EpochDate.ps1

Function Get-EpochDate ($epochDate) {
  [System.TimeZone]::CurrentTimeZone.ToLocalTime(([DateTime]'1/1/1970').AddSeconds($epochDate))
}
