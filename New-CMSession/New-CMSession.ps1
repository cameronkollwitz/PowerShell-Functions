Function New-CMSession {

  <#

    .SYNOPSIS
    A function to connect you to an ConfigMgr site to be able to run ConfigMgr comdlets.

    .DESCRIPTION
    Connects to the specified ConfigMgr Site to allow you to use the ConfigurationManager.psd1 module.
    Requires the "$ENV:SMS_ADMIN_UI_PATH" variable on the device.

    .PARAMETER Site
    Specify the ConfigMgr Site

    .EXAMPLE
    New-CMSession -Site ABC:

  #>

  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory = $true,
      Position = 0)]
    [ValidatePattern('[a-z0-9-]:')]
    [String]
    $Site
  )

  ### CHECK FOR SMS ENV: PROPERTY AND CHECK CONFIGURATIONMANAGER.PSD1 EXISTS ###

  If (Test-Path -Path 'Env:\SMS_ADMIN_UI_PATH') {

    # CREATE VARIABLE FROM PATH FOUND #
    $smspath = (Get-Item -Path 'Env:\SMS_ADMIN_UI_PATH').Value

    # CHANGE TO WORKING DIRECTORY #
    Set-Location "$($smspath.TrimEnd('i386'))"

    # CREATE ConfigMgr PS MODULE PATH FROM ENV: PROPERTY PATH #
    $smspsModule = "$($smspath.TrimEnd('i386'))" + 'ConfigurationManager.psd1'

    # CHECK PS MODULE EXISTS IN LOCATION #
    If (Test-Path -Path $smspsmodule) {

      Write-Output -InputObject 'ConfigurationManager.psd1 found, continuing...'

    }
  } Else {

    Write-Warning -Message 'ConfigurationManager.psd1 not found, exiting.'
    break

  }

  ### IMPORT THE PS MODULE CONFIGURATIONMANAGER.PSD1 ###
  Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -Verbose

  ### CHANGE DIRECTORY TO THE ConfigMgr SITE ###
  # TEST PSDRIVE CREATED AFTER PS MODULE IMPORT #
  If (Test-Path -Path $site) {

    Write-Output -InputObject "PSDrive for $site found, changing to directory..."

  } Else {

    Write-Warning -Message "PSDrive for $site not created after Import-Module, exiting."
    break

  }

  # CHANGE LOCATION TO SConfigMgr SITE PSDRIVE #
  Try {

    Set-Location $site -ErrorAction Stop -WarningAction Stop

  } Catch {

    Write-Warning -Message "Unable to change to $site directory... exiting."
    break

  }

  Write-Output -InputObject "Now connected to the ConfigMgr site $site"

}
