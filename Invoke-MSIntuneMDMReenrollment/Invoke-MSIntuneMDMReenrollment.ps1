<#
  .NOTES
  ===========================================================================
   Created on:   	06/11/2020 14:23
   Created by:   	MauriceDaly
   Filename:     	Invoke-MSIntuneMDMReenrollment.ps1
  ===========================================================================
  .DESCRIPTION
    Force re-enrollment of Intune managed devices due to Intune MDM certificate
    issues during IPU
#>

#region Functions

# Logging Function
function Write-LogEntry {
  param (
    [parameter(Mandatory = $true, HelpMessage = "Value added to the log file.")]
    [ValidateNotNullOrEmpty()]
    [string]$Value,
    [parameter(Mandatory = $true, HelpMessage = "Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.")]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("1", "2", "3")]
    [string]$Severity,
    [parameter(Mandatory = $false, HelpMessage = "Name of the log file that the entry will written to.")]
    [ValidateNotNullOrEmpty()]
    [string]$FileName = "Invoke-MSIntuneMDMReenrollment.log"
  )
  # Determine log file location
  $global:LogFilePath = Join-Path -Path $Env:windir -ChildPath "CCM\Logs\$FileName"

  # Construct time stamp for log entry
  $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))

  # Construct date for log entry
  $Date = (Get-Date -Format "MM-dd-yyyy")

  # Construct context for log entry
  $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)

  # Construct final log entry
  $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""Invoke-MSIntuneMDMReenrollment"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"

  # Add value to log file
  try {
    Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $global:LogFilePath -ErrorAction Stop
  } catch [System.Exception] {
    Write-Warning -Message "Unable to append log entry to Invoke-MSIntuneMDMReenrollment.log file. Error message: $($_.Exception.Message)"
  }
}
#endregion Functions

#region Variables

$RegistryKeys = "HKLM:\SOFTWARE\Microsoft\Enrollments", "HKLM:\SOFTWARE\Microsoft\Enrollments\Status", "HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked", "HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled", "HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers", "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts", "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger", "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"

#endregion Variables

try {
  Write-LogEntry -Value "[MDM Enrollment Issue Detection Script] Checking for MDM certificate in computer certificate store" -Severity 1

  # Check for MDM device certificate
  $IntuneMDMCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {
    $_.Issuer -match "Intune MDM"
  }

  if ($IntuneMDMCert.Count -eq 0) {
    Write-LogEntry -Value "[MDM Issue Detected] Intune MDM certificate does not exist. Starting forced on-boarding process." -Severity 1

    # Obtain current management GUID from Task Scheduler
    $EnrollmentGUID = Get-ScheduledTask | Where-Object { $_.TaskPath -like "*Microsoft*Windows*EnterpriseMgmt*" } | Select-Object -ExpandProperty TaskPath -Unique | Where-Object { $_ -like "*-*-*" } | Split-Path -Leaf

    # Start clean up process
    if (-not [string]::IsNullOrEmpty($EnrollmentGUID)) {
      Write-LogEntry -Value "- Current enrollment GUID detected as $([string]$EnrollmentGUID)" -Severity 1

      # Stop Intune Management Exention Agent and CCM Agent services
      Write-LogEntry -Value "- Stopping MDM services" -Severity 1
      if (Get-Service -Name IntuneManagementExtension) {
        Write-LogEntry -Value "- Stopping IntuneManagementExtension service..." -Severity 1
        Stop-Service -Name IntuneManagementExtension
      }
      Write-LogEntry -Value "- Stopping CCMExec service..." -Severity 1
      Stop-Service -Name CCMExec

      # Remove task scheduler entries
      Write-LogEntry -Value "- Removing task scheduler Enterprise Management entries for GUID - $([string]$EnrollmentGUID)" -Severity 1
      Get-ScheduledTask | Where-Object { $_.Taskpath -match $EnrollmentGUID } | Unregister-ScheduledTask -Confirm:$false

      foreach ($Key in $RegistryKeys) {
        Write-LogEntry -Value "- Processing registry key $Key" -Severity 1
        # Remove registry entries
        if (Test-Path -Path $Key) {
          # Search for and remove keys with matching GUID
          Write-LogEntry -Value "- GUID entry found against key $Key. Removing.." -Severity 1
          Get-ChildItem -Path $Key | Where-Object { $_.Name -match $EnrollmentGUID } | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
      }

      # Start Intune Management Exention Agent service
      Write-LogEntry -Value "- Starting MDM services" -Severity 1
      if (Get-Service -Name IntuneManagementExtension) {
        Write-LogEntry -Value "- Starting IntuneManagementExtension service..." -Severity 1
        Start-Service -Name IntuneManagementExtension
      }
      Write-LogEntry -Value "- Starting CCMExec service..." -Severity 1
      Start-Service -Name CCMExec

      # Sleep
      Write-LogEntry -Value "- Waiting for 30 seconds prior to running DeviceEnroller" -Severity 1
      Start-Sleep -Seconds 30

      # Start re-enrollment process
      Write-LogEntry -Value "- Calling C:\Windows\System32\DeviceEnroller.exe with /C /AutoenrollMDM switches" -Severity 1
      $EnrollmentProcess = Start-Process -FilePath "C:\Windows\System32\DeviceEnroller.exe" -ArgumentList "/C /AutoenrollMDM" -NoNewWindow -Wait -PassThru

    } else {
      Write-LogEntry -Value "Unable to obtain enrollment GUID value from task scheduler. Aborting" -Severity 3; exit 1
    }
  } else {
    Write-LogEntry -value "Device machine certifice exists. Aborting" -Severity 2; exit 1
  }

} catch [System.Exception] {
  Write-LogEntry -value "Error message: $($_.Exception.Message)" -Severity 3; exit 1
}
