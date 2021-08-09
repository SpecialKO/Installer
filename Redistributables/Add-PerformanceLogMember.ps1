<#	
	.SYNOPSIS
		Adds critical user accounts to the local Performance Log Users group.

	.DESCRIPTION
		This script validates whether the user account and NT AUTHORITY\INTERACTIVE
		is a member of the local Performance Log Users group, and if not, attempts
		to elevate and add them.

	.LINK
		https://github.com/GameTechDev/PresentMon
	
	.INPUTS
		None
	
	.OUTPUTS
		None

	.NOTES
		The Performance Log Users group is required for Special K's PresentMon
		functionality which shows the current presentation model being used
		by the game.
#>

<#
	The necessary cmdlets does not exist while running as a 32-bit PowerShell context on 64-bit Windows,
	which necessitates switching context over to 64-bit PowerShell.

	Inno Setup is internally always 32-bit, hence why 32-bit PowerShell launches.
#>
if ($Env:PROCESSOR_ARCHITEW6432 -eq "AMD64")
{
	If ($MyInvocation.Line) {
        &"$env:WINDIR\Sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass $MyInvocation.Line
    } Else {
        &"$env:WINDIR\Sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "$($MyInvocation.InvocationName)" $args
    }
	Exit $LastExitCode
}

<#
	The security identifiers of relevant users and groups.
	
	https://docs.microsoft.com/en-us/windows/win32/secauthz/well-known-sids
#>
$CurrentUser 			= [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value 		# This is unique per user and machine.
$NTAuthorityInteractive = "S-1-5-4" 																# NT AUTHORITY\INTERACTIVE
$PerformanceLogUsers 	= "S-1-5-32-559" 															# Performance Log Users

# Assume there is nothing to do.
$AllDone = $True

# Use -ErrorAction Stop to throw an exception when a missing user is found.
Try
{
	# Get-LocalGroupMember -SID $PerformanceLogUsers -Member $CurrentUser				-ErrorAction Stop
	Get-LocalGroupMember -SID $PerformanceLogUsers -Member $NTAuthorityInteractive 	-ErrorAction Stop
}
Catch
{
	# Something needs to be done.
	$AllDone = $False
}

# If there is something to do.
if ($AllDone -eq $False)
{
	# Relaunch PowerShell as an elevated process with the permissions required to add the users to the group.
	if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
	{
		Start-Process powershell.exe "-NonInteractive -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
		Exit $LastExitCode
	}

	# Add the users to the group.
	# Add-LocalGroupMember -SID $PerformanceLogUsers -Member $CurrentUser 			-ErrorAction SilentlyContinue
	Add-LocalGroupMember -SID $PerformanceLogUsers -Member $NTAuthorityInteractive 	-ErrorAction SilentlyContinue
}