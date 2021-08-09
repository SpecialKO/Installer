<#	
	.SYNOPSIS
		Unregisters Special K's DLL files from the AppInit_DLLs registry keys.

	.DESCRIPTION
		This script validates whether there is any references to Special K's
		DLL files in the AppInit_DLLs registry keys, and if there are, attempts
		to elevate and remove them.
	
	.INPUTS
		None
	
	.OUTPUTS
		None

	.NOTES
		AppInit_DLLs was originally used for the global injection service cirka
		2016 but was replaced with a more stable method with less compatibility
		issues.
#>

<#
	We cannot access 64-bit registry while running as a 32-bit PowerShell context on 64-bit Windows,
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

# Assume there is nothing to do.
$32bit = $64bit = $False

# Validate 32-bit AppInit_DLLs
If ((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Windows" -Name "AppInit_DLLs").AppInit_DLLs -like "*SpecialK*")
{
	$32bit = $True
}

# Validate 64-bit AppInit_DLLs
If ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "AppInit_DLLs").AppInit_DLLs -like "*SpecialK*")
{
	$32bit = $True
}

If ($32bit -or $64bit)
{
	# Relaunch PowerShell as an elevated process with the permissions required to modify the AppInit_DLLs registry keys.
	if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
	{
		Start-Process powershell.exe "-NonInteractive -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
		Exit $LastExitCode
	}

	# Unregister Special K from the 32-bit AppInit_DLLs
	If ($32bit)
	{
		Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Windows" -Name "AppInit_DLLs" -Value (((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Windows" -Name "AppInit_DLLs").AppInit_DLLs).Split(", ", [System.StringSplitOptions]::RemoveEmptyEntries) -NotLike "*SpecialK*" -join ",");
	}

	# Unregister Special K from the 64-bit AppInit_DLLs
	If ($64bit)
	{
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "AppInit_DLLs" -Value (((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "AppInit_DLLs").AppInit_DLLs).Split(", ", [System.StringSplitOptions]::RemoveEmptyEntries) -NotLike "*SpecialK*" -join ",");
	}
}