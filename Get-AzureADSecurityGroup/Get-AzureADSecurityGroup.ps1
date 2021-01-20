Function Get-AzureADSecurityGroup {
<#
  .SYNOPSIS
    Get an Azure AD group object through Microsoft Graph API.

  .DESCRIPTION
    This script will get an Azure AD group through Microsoft Graph API and return a custom object showing
    the display name, id and created date of that group.

  .PARAMETER TenantName
    Specify the tenant name, e.g. domain.onmicrosoft.com.

  .PARAMETER GroupName
    Name of the Azure AD group name.

  .PARAMETER ApplicationID
    Specify the Application ID of the app registration in Azure AD. When no parameter is manually passed, script will attempt to use well known Microsoft Intune PowerShell app registration.

  .EXAMPLE
    # Get an Azure AD group called 'All Users':
    .\Get-AzureADSecurityGroup.ps1 -TenantName "domain.onmicrosoft.com" -GroupName "All Users"

  .NOTES
    FileName:    Get-AzureADSecurityGroup.ps1
    Author:      Nickolaj Andersen
    Contact:     @NickolajA
    Created:     2017-10-12
    Updated:     2017-10-12

    Version history:
    1.0.0 - (2017-10-12) Script created
    2.0.0 - (2021-01-15) Script converted to function and updated naming convention.

    Required modules:
    AzureAD (Install-Module -Name AzureAD)
#>

  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType('MSIntuneGraph.AADGroup')]
  Param(
    [parameter(Mandatory = $true, HelpMessage = "Specify the tenant name, e.g. domain.onmicrosoft.com.")]
    [ValidateNotNullOrEmpty()]
    [string]$TenantName,

    [parameter(Mandatory = $true, HelpMessage = "Name of the Azure AD group name.")]
    [ValidateNotNullOrEmpty()]
    [string]$GroupName,

    [parameter(Mandatory = $false, HelpMessage = "Specify the Application ID of the app registration in Azure AD. When no parameter is manually passed, script will attempt to use well known Microsoft Intune PowerShell app registration.")]
    [ValidateNotNullOrEmpty()]
    [string]$ApplicationID = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
  )

  Begin {
    # Determine if the PSIntuneAuth module needs to be installed
    Try {
      Write-Verbose -Message "Attempting to locate PSIntuneAuth module"
      $PSIntuneAuthModule = Get-InstalledModule -Name PSIntuneAuth -ErrorAction Stop
      If ($null -ne $PSIntuneAuthModule) {
        Write-Verbose -Message "Authentication module detected, checking for latest version"
        $LatestModuleVersion = (Find-Module -Name PSIntuneAuth -ErrorAction Stop -Verbose:$false).Version
        If ($LatestModuleVersion -gt $PSIntuneAuthModule.Version) {
          Write-Verbose -Message "Latest version of PSIntuneAuth module is not installed, attempting to install: $($LatestModuleVersion.ToString())"
          $UpdateModuleInvocation = Update-Module -Name PSIntuneAuth -Scope CurrentUser -Force -ErrorAction Stop -Confirm:$false
        }
      }
    } Catch [System.Exception] {
      Write-Warning -Message "Unable to detect PSIntuneAuth module, attempting to install from PSGallery"
      Try {
        Install-Module -Name PSIntuneAuth -Scope AllUsers -Force -ErrorAction Stop -Confirm:$false
        Write-Verbose -Message "Successfully installed PSIntuneAuth"
      } Catch [System.Exception] {
        Write-Warning -Message "An error occurred while attempting to install PSIntuneAuth module. Error message: $($_.Exception.Message)" ; break
      }
    }

    # Check if token has expired and if, request a new
    Write-Verbose -Message "Checking for existing authentication token"
    If ($null -ne $Global:AuthToken) {
      $UTCDateTime = (Get-Date).ToUniversalTime()
      $TokenExpireMins = ($Global:AuthToken.ExpiresOn.datetime - $UTCDateTime).Minutes
      Write-Verbose -Message "Current authentication token expires in (minutes): $($TokenExpireMins)"
      If ($TokenExpireMins -le 0) {
        Write-Verbose -Message "Existing token found but has expired, requesting a new token"
        $Global:AuthToken = Get-MSIntuneAuthToken -TenantName $TenantName -ClientID $ApplicationID
      } Else {
        Write-Verbose -Message "Existing authentication token has not expired, will not request a new token"
      }
    } Else {
      Write-Verbose -Message "Authentication token does not exist, requesting a new token"
      $Global:AuthToken = Get-MSIntuneAuthToken -TenantName $TenantName -ClientID $ApplicationID
    }
  }
  Process {
    # Graph URI
    $GraphURI = "https://graph.microsoft.com/v1.0/groups?`$filter=displayname eq '$($GroupName)'"

    # Get group object from Graph API
    $AADGroup = (Invoke-RestMethod -Uri $GraphURI -Method Get -Headers $AuthToken).Value
    If ($null -ne $AADGroup) {
      $PSObject = [PSCustomObject]@{
        PSTypeName      = "MSIntuneGraph.AADGroup"
        DisplayName     = $AADGroup.displayName
        GroupID         = $AADGroup.id
        CreatedDateTime = $AADGroup.createdDateTime
      }

      # Output object to pipeline
      Write-Output -InputObject $PSObject
    } Else {
      Write-Warning -Message "Unable to find a group matching specified '$($GroupName)'"
    }
  }

}
