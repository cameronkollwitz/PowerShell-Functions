Function Connect-CmRemoteControl {
  <#
  .SYNOPSIS
    This script calls the Configuration Manager Console's Remote Control (CmRcViewer.exe) to start a Remote Control session from Powershell.
  .NOTES
    Created on:     2014-09-12 (ISO 8601)
    Created by:     Adam Bertram
    Filename:       Connect-CmRemoteControl.ps1
    Requirements:   An available Configuration Manager Site Server and the Configuration Manager Console installed.
                    Permissions to connect to the remote computer.
  .EXAMPLE
    PS> Connect-CmRemoteControl -Computername MYCOMPUTER -SiteServer CM01

    This example would bring up the Configuration Manager Remote Control window connecting to the computer called MYCOMPUTER

  .PARAMETER Computername
    The name of the computer you'd like to use remote tools to connect to

  .PARAMETER SiteServer
    The name of the ConfigMGr Site Server holding the site database.
#>

  [CmdletBinding()]
  Param (
    [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
    [ValidateScript( { Test-Connection -ComputerName $_ -Quiet -Count 1 })]
    [string]$Computername,
    [ValidateScript( { Test-Connection -ComputerName $_ -Quiet -Count 1 })]
    [string]$SiteServer = 'CM01'
  )

  BEGIN {
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    Set-StrictMode -Version Latest
  }

  PROCESS {
    Try {
      ## Find the path of the Configuration Manager Console to get the path of the remote tools client
      If (!$env:SMS_ADMIN_UI_PATH -or !(Test-Path "$($env:SMS_ADMIN_UI_PATH)\CmRcViewer.exe")) {
        Throw 'Unable to find the Configuration Manager Remote Controll! Is the Conifugraiton Manager Console installed?'
      } Else {
        $RemoteToolsFilePath = "$($env:SMS_ADMIN_UI_PATH)\CmRcViewer.exe"
      }
      & $RemoteToolsFilePath $Computername "\\$SiteServer"
    } Catch {
      Write-Error $_.Exception.Message
    }
  }

  END {}

}
