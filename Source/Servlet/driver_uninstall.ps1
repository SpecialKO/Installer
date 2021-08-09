<#

   This script uninstalls the WinRing0 kernel driver.

   Script needs to be run as administrator.

#>

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
   # Relaunch as an elevated process:
   Start-Process powershell.exe "-File", ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
   exit
}

$SelfDir    = Split-Path $script:MyInvocation.MyCommand.Path
$SpecialK64 = (Get-Item $SelfDir).parent.FullName             + "\SpecialK64.dll"
$TargetDir  = [Environment]::GetFolderPath("MyDocuments")     + "\My Mods\SpecialK\Drivers\WinRing0"
$TargetPath = $TargetDir                                      + "\Installer.dll"

New-Item -ItemType Directory -Path $TargetDir -Force

Copy-Item $SpecialK64 -Destination $TargetPath -Force

Start-Process rundll32 -ArgumentList "`"$TargetPath`",RunDLL_WinRing0 Uninstall" -Wait

Remove-Item -Path $TargetPath -Force

# And that should do it...