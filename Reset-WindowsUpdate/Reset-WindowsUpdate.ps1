Function Reset-WindowsUpdate {
  <#
  .SYNOPSIS
    Reset-WindowsUpdate

  .DESCRIPTION
    This script will reset all of the Windows Updates components to DEFAULT SETTINGS.

  .OUTPUTS
    Results are printed to the console. Future releases will support outputting to a log file.
#>

  [CmdletBinding()]
  Param ()

  BEGIN {
    # Determine System Architecture
    $arch = Get-WMIObject -Class Win32_Processor -ComputerName LocalHost | Select-Object AddressWidth

    # Stop Processes
    Write-Host -Object '1. Stopping Windows Update Services...'
    Stop-Service -Name BITS -Force
    Stop-Service -Name wuauserv -Force
    Stop-Service -Name appidsvc -Force
    Stop-Service -Name cryptsvc -Force

    # Remove Fragments
    Write-Host -Object '2. Remove QMGR Data file...'
    Remove-Item -Path "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue

    # Rename SoftwareDistribution and CatRoot directories
    Write-Host -Object '3. Moving the SoftwareDistribution and CatRoot Directories to .bak...'
    Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak -ErrorAction SilentlyContinue
    Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue

    # Remove old Windows Update logs
    Write-Host -Object '4. Removing old Windows Update logs...'
    Remove-Item -Path $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue

    # Reset Windows Update Services to Default
    Write-Host -Object '5. Resetting the Windows Update Services to default settings...'
    'sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)'
    'sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)'
  }

  PROCESS {
    # Change Directory
    Set-Location $env:systemroot\system32

    # Register Default DLLs
    Write-Host -Object '6. Registering Default DLLs...'
    regsvr32.exe /s atl.dll
    regsvr32.exe /s urlmon.dll
    regsvr32.exe /s mshtml.dll
    regsvr32.exe /s shdocvw.dll
    regsvr32.exe /s browseui.dll
    regsvr32.exe /s jscript.dll
    regsvr32.exe /s vbscript.dll
    regsvr32.exe /s scrrun.dll
    regsvr32.exe /s msxml.dll
    regsvr32.exe /s msxml3.dll
    regsvr32.exe /s msxml6.dll
    regsvr32.exe /s actxprxy.dll
    regsvr32.exe /s softpub.dll
    regsvr32.exe /s wintrust.dll
    regsvr32.exe /s dssenh.dll
    regsvr32.exe /s rsaenh.dll
    regsvr32.exe /s gpkcsp.dll
    regsvr32.exe /s sccbase.dll
    regsvr32.exe /s slbcsp.dll
    regsvr32.exe /s cryptdlg.dll
    regsvr32.exe /s oleaut32.dll
    regsvr32.exe /s ole32.dll
    regsvr32.exe /s shell32.dll
    regsvr32.exe /s initpki.dll
    regsvr32.exe /s wuapi.dll
    regsvr32.exe /s wuaueng.dll
    regsvr32.exe /s wuaueng1.dll
    regsvr32.exe /s wucltui.dll
    regsvr32.exe /s wups.dll
    regsvr32.exe /s wups2.dll
    regsvr32.exe /s wuweb.dll
    regsvr32.exe /s qmgr.dll
    regsvr32.exe /s qmgrprxy.dll
    regsvr32.exe /s wucltux.dll
    regsvr32.exe /s muweb.dll
    regsvr32.exe /s wuwebv.dll

    Write-Host -Object '7. Removing Windows Update Client Settings...'
    REG DELETE 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' /v AccountDomainSid /f
    REG DELETE 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' /v PingID /f
    REG DELETE 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' /v SusClientId /f

    Write-Host -Object '8. Resetting the WinSock...'
    netsh winsock reset
    netsh winhttp reset proxy

    Write-Host -Object '9. Delete all BITS jobs...'
    Get-BitsTransfer | Remove-BitsTransfer

    Write-Host -Object '10. Attempting to install the Windows Update Agent...'
    if ($arch -eq 64) {
      wusa Windows8-RT-KB2937636-x64 /quiet
    } else {
      wusa Windows8-RT-KB2937636-x86 /quiet
    }
  }

  END {
    # Bring Windows Update Service Back Online
    Write-Host -Object '11. Starting Windows Update Services...'
    Start-Service -Name BITS
    Start-Service -Name wuauserv
    Start-Service -Name appidsvc
    Start-Service -Name cryptsvc

    # Force Windows Update Discovery
    Write-Host -Object '12. Forcing discovery...'
    wuauclt /resetauthorization /detectnow

    # Final Message
    Write-Host -Object 'Process complete. The device must reboot before continuing!' -ForegroundColor Red
  }

}