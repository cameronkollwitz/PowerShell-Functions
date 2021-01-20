Function Get-ADComputerRebootHistory {
<#
  .SYNOPSIS
    This will output who initiated a reboot or shutdown event.

  .LINK
    https://thesysadminchannel.com/get-reboot-history-using-powershell -

  .EXAMPLE
    Get-ADComputerRebootHistory -ComputerName Server01, Server02

  .EXAMPLE
    Get-ADComputerRebootHistory -DaysFromToday 30 -MaxEvents 1

  .PARAMETER ComputerName
    Specify a computer name you would like to check.  The default is the local computer

  .PARAMETER DaysFromToday
    Specify the amount of days in the past you would like to search for

  .PARAMETER MaxEvents
    Specify the number of events you would like to search for (from newest to oldest)

  .NOTES Original Script
    Name: Get-RebootHistory
    Author: theSysadminChannel
    Version: 1.0
    DateCreated: 2020-Aug-5

  .NOTES
    Name: Get-ADComputerRebootHistory
    Author: Cameron Kollwitz
    Version: 2.0
    DateCreated: 2021-01-15
#>

  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true
    )]
    [string[]]  $ComputerName = $env:COMPUTERNAME,
    [int]       $DaysFromToday = 7,
    [int]       $MaxEvents = 9999
  )

  BEGIN {}

  PROCESS {
    ForEach ($Computer in $ComputerName) {
      Try {
        $Computer = $Computer.ToUpper()
        $EventList = Get-WinEvent -ComputerName $Computer -FilterHashtable @{
          Logname   = 'system'
          Id        = '1074', '6008'
          StartTime = (Get-Date).AddDays(-$DaysFromToday)
        } -MaxEvents $MaxEvents -ErrorAction Stop

        ForEach ($Event in $EventList) {
          If ($Event.Id -eq 1074) {
            [PSCustomObject]@{
              TimeStamp    = $Event.TimeCreated
              ComputerName = $Computer
              UserName     = $Event.Properties.value[6]
              ShutdownType = $Event.Properties.value[4]
            }
          }

          If ($Event.Id -eq 6008) {
            [PSCustomObject]@{
              TimeStamp    = $Event.TimeCreated
              ComputerName = $Computer
              UserName     = $null
              ShutdownType = 'unexpected shutdown'
            }
          }
        }

      } Catch {
        Write-Error $_.Exception.Message
      }
    }
  }
  END {}
}
