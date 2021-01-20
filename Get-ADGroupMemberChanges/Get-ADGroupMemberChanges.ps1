Function Get-ADGroupMemberChanges {
<#
  A scheduled script can easily monitor the membership of one or more
  groups in Active Directory to detect changes and, optionally, to reverse
  out these changes.  This is a sample script to get started and could be
  fleshed out to include logging, alerting, reversing out changes, etc.
#>

  # For the group being monitoed, create an array of the desired members
  # using either the full paths (safer) or just the common names (easier):
  $AuthorizedMembers =
  @(
    'CN=Administrator,CN=Users,DC=cameronkollwitz,DC=com',
    'CN=Cameron,OU=Users,OU=Home,DC=cameronkollwitz,DC=com'
  )

  # Query the current membership of the monitored group:
  $MonitoredGroup = 'Domain Admins' #Example group to examine.

  # Import the Active Directory PowerShell module
  Import-Module -Name ActiveDirectory

  # Get the group members
  $Members = Get-ADGroupMember -Identity $MonitoredGroup |
    Select-Object -ExpandProperty distinguishedName

  # Compare the two lists for any differences, if the lists do not match, the $Differences variable will not be empty!
  $Differences = Compare-Object -ReferenceObject $AuthorizedMembers -DifferenceObject $Members
  If ($null -ne $Differences) {
    Try {
      Write-Host -Object "ALERT: The Security Group $MonitoredGroup has changed!" -ForegroundColor Red

      # Add back any missing authorized members:
      ForEach ($mbr in $AuthorizedMembers) {
        If ($Members -notcontains $mbr) {
          Write-Host -Object "Adding back missing members" -ForegroundColor Green
          Add-ADGroupMember -Identity $MonitoredGroup -Members $mbr
        }
      }

      # Remove any unauthorized members:
      ForEach ($mbr in $Members) {
        If ($AuthorizedMembers -notcontains $mbr) {
          Write-Host -Object "Removing unauthorized group members" -ForegroundColor Green
          Remove-ADGroupMember -Identity $MonitoredGroup -Members $mbr -Confirm:$False
        }
      }

      # In real life, don't forget to write status information and error messages
      # to a log somewhere, plus do the necessary alerting for each change; for
      # example, the script could write to local and remote event logs, send
      # syslog messages to a SIEM, send SMTP and SMS messages to admins, etc.
    }

    Catch {
      Exit 1
    }

  }
}