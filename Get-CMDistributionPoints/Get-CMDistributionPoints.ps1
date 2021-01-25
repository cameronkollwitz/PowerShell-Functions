Function Get-CMDistributionPoints {
<#
  .SYNOPSIS
    Input the Configuration Manager Site Code and the site server hostname to remotely get the Distribution Point names in an environment.

  .DESCRIPTION
    Created to allow you to get the Distribution points in an environment from Configuration Manager without the ConfigMgr PowerShell Module.

    As long as WINRM works this works. Can be used dynamically in a lot of different scripts for doing health checks.

  .NOTES Original
    FileName: Get-DistributionPoints.ps1
    Author: Jordan Benzing (@JordanTheItGuy)
    Created: 2019-11-29
    Modified: 2019-11-29
    Version:0.0.0 - (2019-11-29)

  .NOTES
    FileName:     Get-CMDistributionPoints.ps1
    Author:       Cameron Kollwitz (cameron@kollwitz.us)
    Modified:     2021-01-24
    Version:      0.1.0
#>

  [CmdletBinding()]
  Param(
    # Configuration Manager Site Code (Three Character Code)
    [Parameter(HelpMessage = 'Enter the ConfigMgr Site Code', Mandatory = $true )]
    [string]$SiteCode,
    # Configuration MAnager Site Server Hostname
    [Parameter(HelpMessage = 'Enter the ConfigMgr Site Server Hostname' , Mandatory = $true )]
    [string]$SiteServer
  )

  Begin {
    Try {
      If (!(Test-NetConnection -ComputerName $SiteServer -CommonTCPPort WINRM)) {
        Throw 'Could not establish a connection over the WINRM port for WMI access'
      }
    } Catch {
      Write-Error -Message "$($_.Exception.Message)"
    }
  }

  Process {
    $DPS = Get-CimInstance -ComputerName $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Query "SELECT * FROM SMS_SystemResourceList WHERE RoleName='SMS Distribution Point'" | Select-Object -ExpandProperty ServerName
    $DPS
  }

  End {
    Out-Null
  }

}
