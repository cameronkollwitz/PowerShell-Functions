Function Enable-ADComputerRemoteRegistry {
  #NOTNEEDED requires -RunAsAdministrator
  #requires -Version 3.0

  <#
  .SYNOPSIS
    This will enable the remote registry service on local or remote computers.
    For updated help and examples refer to -Online version.

  .DESCRIPTION
    This will enable the remote registry service on local or remote computers.
    For updated help and examples refer to -Online version.

  .NOTES
    Name: Enable-ADComputerRemoteRegistry
    Author: The Sysadmin Channel
    Version: 1.0
    DateCreated: 2018-Jun-21
    DateUpdated: 2018-Jun-21

  .LINK
    https://thesysadminchannel.com/remotely-enable-remoteregistry-service-powershell

  .EXAMPLE
    For updated help and examples refer to -Online version.
#>

  [CmdletBinding()]
  Param(
    [Parameter(
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0)]
    [string[]]  $ComputerName = $env:COMPUTERNAME
  )

  BEGIN {}
  PROCESS {
    ForEach ($Computer in $ComputerName) {
      Try {
        $RemoteRegistry = Get-CimInstance -Class Win32_Service -ComputerName $Computer -Filter 'Name = "RemoteRegistry"' -ErrorAction Stop
        If ($RemoteRegistry.State -eq 'Running') {
          Write-Output "$Computer is already Enabled"
        }
        If ($RemoteRegistry.StartMode -eq 'Disabled') {
          Set-Service -Name RemoteRegistry -ComputerName $Computer -StartupType Manual -ErrorAction Stop
          Write-Output "$Computer : Remote Registry has been Enabled"
        }
        If ($RemoteRegistry.State -eq 'Stopped') {
          Start-Service -InputObject (Get-Service -Name RemoteRegistry -ComputerName $Computer) -ErrorAction Stop
          Write-Output "$Computer : Remote Registry has been Started"
        }
      } Catch {
        $ErrorMessage = $Computer + ' Error: ' + $_.Exception.Message
        Write-Output "$ErrorMessage"
      }
    }
  }
  END {}
}
