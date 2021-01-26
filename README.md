# PowerShell Functions

My Public PowerShell Functions.

## Functions

### Add-ADUserAcl

TBW.

### Enable-ADComputerRemoteRegistry

This will enable the remote registry service on local or remote computers.

### Get-ADComputerInstalledSoftware

Get-ADComputerInstalledSoftware opens up the specified (remote) registry and scours it for installed software.

When found it returns a list of the software and its version.

### Get-ADComputerRebootHistory

This will output who initiated a reboot or shutdown event.

### Get-ADComputerRemoteTime

Retrieve the time of a remote device.

### Get-ADUserFromSid

Converts a SID to NTAccount.

### Get-AppxDeprovisioned

This function returns an array of all the apps that are deprovisioned on the local computer.

Deprovisioned apps will show up in the registry if they were removed while Windows was offline, or with the PowerShell cmdlets for removing AppX Packages.

### Get-AzureADSecurityGroup

This script will get an Azure AD group through Microsoft Graph API and return a custom object showing the display name, ID, and created date of that group.

### Get-CMDistributionPoints

Created to allow you to get the Distribution points in an environment from Configuration Manager without the ConfigMgr PowerShell Module.

As long as WINRM works this works. Can be used dynamically in a lot of different scripts for doing health checks.

### Get-CMTaskSequenceStatus

Evaluates if there is currently a Task Sequence running on the device.

### Get-EpochDate

TBW.

### Get-NetworkConfiguration

Function that gets network configuration of a server or workstation and prints it to the screen.

This function can be invoked remotely against a remote machine by using

```PowerShell
Invoke-Command -ScriptBlock ${Function:Get-NetworkConfiguration}
```

### Get-RRASFarm

This command will query the Win32_TSGatewayConnection class using RPC and root/Microsoft/Windows/RemoteAccess using WinRM and write summary object to the pipeline.

### Get-SoftwareUninstallStrings

TBW.

### Get-VMWareToolsStatus

This will check the status of the VMware vmtools status.

Properties include: Name, Status, UpgradeStatus, and Version

### Invoke-AppxReprovision

Starting in Windows 10 1803, a registry key is set for every deprovisioned app.

As long as this registry key is in place, a deprovisioned application will not be reinstalled during a feature update.

By removing these registry keys, we can ensure that deprovisioned apps, such as the windows store are able to be reinstalled.

### Invoke-AzureAdDeltaSync

A PowerShell Function to invoke a Delta Sync with an Azure Active Directory Connect server remotely.

### Get-MWMTraceRoute

Utilize the .NET Framework to implement a "Mid-Wage-Man's Traceroute" using PowerShell.

### New-CMSession

Connects to the specified ConfigMgr Site to allow you to use the `ConfigurationManager.psd1` module.

Requires the `$ENV:SMS_ADMIN_UI_PATH` variable on the device.

### New-RandomPassword

Generates a random password using only common ASCII code numbers.

The password will be four characters in length at a minimum so that it may contain at least one of each of the following character types: uppercase, lowercase, number and password-legal non-alphanumerics.

To make the output play nice, the following characters are excluded from the output password string:

- Extended ASCII
- Spaces
- \#
- "
- `
- '
- 0
- O

Also, the function prevents any two identical characters in a row.

The output should be compatible with any code page or culture when an appropriate encoding is chosen.

Because of how certain characters are excluded, the randomness of the password is slightly lower, hence, the length may need to be increased to achieve a particular entropy.

### Register-PSRepositoryFix

Workaround caused by a bug relating to accessing HTTPS NuGet endpoints.

### Reset-DellTpmOwner

Used to reset the TPM Ownership of a device using Microsoft APIs.

### Reset-WindowsUpdate

This script will reset all of the Windows Updates components to Default Settings.

### Set-AutopilotAssignDeviceToUser

The Set-AutopilotAssignDeviceToUser cmdlet assign the specified user and sets a Display Name to show on the Windows Autopilot device.

### Set-LocalAdministratorTask

Creates a Scheduled Task to add a User as a member of the Local Administrators Security Group on the device.

### Write-CMTraceLogEntry

Write data to a CMTrace compatible log file.
