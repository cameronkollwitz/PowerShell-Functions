Function Set-LocalAdministratorTask {
  <#
  .SYNOPSIS
    Adds a User as a Local Administrator to the device for the specified amount of time.

  .DESCRIPTION
    Creates a Scheduled Task to add a User as a member of the Local Administrators Security Group on the device.

  .PARAMETER Duration
    Duration (in seconds) for Local Administrator permissions to be available to the User.

  .PARAMETER LogPath
    Define the location of the log. Defaults to "C:\Windows\Logs\Software\LocalAdministratorTask.log"

  .PARAMETER UserIDs
    User to add to Local Administrators

  .EXAMPLE
    Set-LocalAdministratorTask -LogPath "C:\Temp\MyLog.log"

  .NOTES
    Author:       Cameron Kollwitz <cameron@kollwitz.us>
    Date:         2021-01-16
    File:         Set-LocalAdministratorTask.ps1
#>

  [CmdletBinding()]
  Param(
    # User to add to Local Administrators
    [Parameter(Mandatory = $True)]
    [string[]]$UserIDs,
    # Duration (in seconds) for Local Administrator permissions to be available to the User.
    [Parameter(Mandatory = $True)]
    [int]$Duration,
    # Define the location of the log
    [Parameter(Mandatory = $False)]
    [String]$LogPath = "$ENV:WinDir\Logs\Software\LocalAdministratorTask.log"
  )

  Begin {
    # Test Logging Directory Existence. Create if it does not exist.
    If (!(Test-Path -Path "$ENV:WinDir\Logs\Software" )) {
      New-Item -Path "$ENV:WinDir\logs\Software" -ItemType Directory -Force
    }
  }

  Process {
    ForEach ($UserID in $UserIDs) {
      $GrantAdminTo = 'Domain\' + $UserID

      # Remove Local Administrator When Duration=0
      If (($Duration -eq 0) -and ($null -ne (Get-ScheduledTask "Remove Admin Access $UserID" -ErrorAction SilentlyContinue) )) {
        Unregister-ScheduledTask -TaskName 'Remove Admin Access $UserID' -Confirm:$false
        Out-File -FilePath $LogPath -InputObject ((Get-Date).ToString() + ' | Removed Task | ' + $GrantAdminTo) -Append
      }

      # Add User to Local Administrator
      Add-LocalGroupMember -Group 'Administrators' -Member "$GrantAdminTo" -ErrorAction SilentlyContinue

      # Validates User is now a memeber of Local Administrators and logs it
      If ((Get-LocalGroupMember -Group 'Administrators' -Member "$GrantAdminTo" -ErrorAction SilentlyContinue).count -gt 0) {
        If ($Duration -gt 0) {
          Out-File -FilePath $LogPath -InputObject ((Get-Date).ToString() + " | Added | $GrantAdminTo | Until: $((Get-Date).AddDays($Duration).ToString())") -Append
        } Else {
          Out-File -FilePath $LogPath -InputObject ((Get-Date).ToString() + " | Added | $GrantAdminTo | Until: Indefinite") -Append
        }
      } Else {
        Out-File -FilePath $LogPath -InputObject ((Get-Date).ToString() + " | ERROR | $GrantAdminTo | USER DOES NOT EXIST, UNABLE TO ADD USER TO ADMIN GROUP") -Append
        RETURN 'BAD USERNAME'
      }

      If ($Duration -gt 0) {
        $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-NoProfile -WindowStyle Hidden -command `"`& {`$Member = '$GrantAdminTo';Remove-LocalGroupMember -Group Administrators -Member `$Member; Unregister-ScheduledTask -TaskName 'Remove Admin Access $UserID' -confirm:`$false; `$Cleared = (Get-Date).ToString() + ' | Removed | ' + `$Member; Out-File -FilePath $LogPath -InputObject `$Cleared -Append}`""
        $Settings = New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter 10
        $Date = ((Get-Date).AddDays($Duration))
        $trigger = New-ScheduledTaskTrigger -Once -At $Date -RepetitionInterval (New-TimeSpan -Hours 3) -RepetitionDuration (New-TimeSpan -Days 30)
        # Schedule User removal from Local Administrator group
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Remove Admin Access $UserID" -Description 'Remove Admin Access' -User 'NT AUTHORITY\SYSTEM' -RunLevel Highest -Force -Settings $Settings
      }
    }
  }

  End {
    Out-Null
  }
}
