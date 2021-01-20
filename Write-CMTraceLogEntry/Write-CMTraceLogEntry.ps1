Function Write-CMTraceLogEntry {
  <#
  .DESCRIPTION
    Write data to a CMTrace compatible log file.

  .PARAMETER Value
    Value added to the log file.

  .PARAMETER Severity
    Severity for the log entry.

    1 for Informational
    2 for Warning
    3 for Error

  .PARAMETER FileName
    Name of the log file that the entry will written to.

  .EXAMPLE
    Write-CMTraceLogEntry -Value 'Log information goes here' -Severity 1 -FilePath $ENV:TEMP\CMLogEntry.log

  .NOTES
    Credit to SCConfigMgr <https://www.scconfigmgr.com/>
#>

  [CmdletBinding()]
  Param(
    # Value
    [Parameter(
      Mandatory = $true,
      HelpMessage = 'Value added to the log file.'
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $Value,
    # Severity
    [Parameter(
      Mandatory = $true,
      HelpMessage = 'Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.'
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateSet(
      '1',
      '2',
      '3'
    )]
    [String]
    $Severity,
    # FileName
    [Parameter(
      Mandatory = $false,
      HelpMessage = 'Name of the log file that the entry will written to.'
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $FileName = ($script:LogFile | Split-Path -Leaf)
  )

  BEGIN {}

  PROCESS {
    # Determine log file location
    $LogFilePath = Join-Path -Path $LogsDirectory -ChildPath $FileName

    # Construct time stamp for log entry
    If (-not(Test-Path -Path 'variable:global:TimezoneBias')) {
      [String]$global:TimezoneBias = [System.TimeZoneInfo]::Local.GetUtcOffset((Get-Date)).TotalMinutes
      If ($TimezoneBias -match '^-') {
        $TimezoneBias = $TimezoneBias.Replace('-', '+')
      } Else {
        $TimezoneBias = '-' + $TimezoneBias
      }
    }

    $Time = -join @((Get-Date -Format 'HH:mm:ss.fff'), $TimezoneBias)

    # Construct date for log entry. Use ISO8601
    $Date = (Get-Date -Format 'yyyy-MM-dd')

    # Construct context for log entry
    $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)

    # Construct the log entry
    $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""Install-DellBiosProvider"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"

    # Add to log file
    Try {
      Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    } Catch [System.Exception] {
      Write-Warning -Message "Unable to append log entry to $FileName $($_.InvocationInfo.ScriptLineNumber)$($_.Exception.Message)"
    }
  }

  END {}

}
