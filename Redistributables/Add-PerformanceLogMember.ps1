<#  
  .SYNOPSIS
    Adds NT AUTHORITY\INTERACTIVE to BUILT-IN\Performance Log Users.

  .DESCRIPTION
    This script validates if NT AUTHORITY\INTERACTIVE is a member of the local
    BUILT-IN\Performance Log Users group, and attempts to add it if not.

  .LINK
    https://github.com/GameTechDev/PresentMon
  
  .INPUTS
    None
  
  .OUTPUTS
    None

  .NOTES
    The Performance Log Users permission is required to perform event tracing (ETW),
    which is used by Special K's PresentMon functionality to shows the current
    presentation model being used for games.
  
  .NOTES
    NT AUTHORITY\INTERACTIVE means any interactive user session that logged-on
    via the Windows Graphical User Interface is granted the permission.

#>

# The necessary cmdlets does not exist while running as a 32-bit PowerShell context on 64-bit Windows,
# which necessitates switching context over to 64-bit PowerShell.
# 
# Inno Setup is internally always 32-bit, hence why 32-bit PowerShell launches.
if ($Env:PROCESSOR_ARCHITEW6432 -eq "AMD64")
{
  If ($MyInvocation.Line) {
        &"$env:WINDIR\Sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass $MyInvocation.Line
    } Else {
        &"$env:WINDIR\Sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "$($MyInvocation.InvocationName)" $args
    }
  Exit $LastExitCode
}

# The security identifiers of relevant users and groups, see https://docs.microsoft.com/en-us/windows/win32/secauthz/well-known-sids
$NTAuthorityInteractive = "S-1-5-4"      # NT AUTHORITY\INTERACTIVE
$PerformanceLogUsers    = "S-1-5-32-559" #     BUILT-IN\Performance Log Users

# Assume there is nothing to do
$AllDone = $True

Try
{
  if ([Environment]::OSVersion.Version -like "1*")
  {
    # On Windows 10, use the native PowerShell cmdlet Add-LocalGroupMember since it supports SIDs
    # Use -ErrorAction Stop to throw an exception when NT AUTHORITY\INTERACTIVE is not a member of BUILT-IN\Performance Log Users.
    Get-LocalGroupMember -SID $PerformanceLogUsers -Member $NTAuthorityInteractive -ErrorAction Stop
  }
  else
  {
    # On Windows 8.1 assume there's always something to do
    $AllDone = $False
  }
}
Catch
{
  # We are on Windows 10, something needs to be done
  $AllDone = $False
}

# If there is something to do
if ($AllDone -eq $False)
{
  # Relaunch PowerShell as an elevated process with the permissions required to add the users to the group
  if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
  {
    Start-Process powershell.exe "-NonInteractive -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    Exit $LastExitCode
  }
  
  # Add the user to the group
  if ([Environment]::OSVersion.Version -like "1*")
  {
    # On Windows 10, use the native PowerShell cmdlet Add-LocalGroupMember since it supports SIDs
    Add-LocalGroupMember -SID $PerformanceLogUsers -Member $NTAuthorityInteractive -ErrorAction SilentlyContinue
  }
  
  # Windows 8.1 lacks Add-LocalGroupMember, so a fallback is needed
  else
  {
    # Use WMI to retrieve the localized names of the group and user
    $Group = (Get-WmiObject -Class Win32_Group         -Filter "LocalAccount = True AND SID = '$PerformanceLogUsers'"   ).Name
    $User  = (Get-WmiObject -Class Win32_SystemAccount -Filter "LocalAccount = True AND SID = '$NTAuthorityInteractive'").Name
    
    # Use NET to add the user to the group
    net localgroup "$Group" "$User" /add
  }
}