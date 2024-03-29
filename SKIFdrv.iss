﻿; -- SKIFdrv.iss --
;
; This is the install script for SKIFdrv
;   https://github.com/SpecialKO/SKIFdrv
;
;
;
; licensed under MIT
; https://github.com/SpecialKO/Installer/blob/main/LICENSE


#define SpecialKName      "Special K Extended Hardware Monitoring Driver"
#define SpecialKPublisher "The Special K Group"
#define SpecialKURL       "https://special-k.info/"
#define SpecialKForum     "https://discourse.differentk.fyi/"
#define SpecialKDiscord   "https://discord.gg/specialk"
#define SpecialKPatreon   "https://www.patreon.com/Kaldaien"
#define RedistDir         "Redistributables"              ; Required dependencies and PowerShell helper scripts   
#define OutputDir         "Builds_SKIFdrv"                ; Output folder to put compiled builds of the installer   
#define AssetsDir         "Assets"                        ; LICENSE.txt, icon.ico, WizardImageFile.bmp, and WizardSmallImageFile.bmp

#define SourceDir         "Source_SKIFdrv"
#define SpecialKVersion   GetStringFileInfo(SourceDir + '\SKIFdrv.exe', "ProductVersion")
#define SpecialKHelpURL   "https://wiki.special-k.info/"
#define SpecialKFileName  "SK_WinRing0"

#include "SpecialK_Shared.iss"

#define public Dependency_NoExampleSetup
#include "CodeDependencies.iss"


[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
ArchitecturesInstallIn64BitMode    = x64
ArchitecturesAllowed               = x64
MinVersion                         = 6.3.9600
AppId                              = {{#SKIFdrvUninstID}
AppName                            = {#SpecialKName}
AppVersion                         = {#SpecialKVersion}  
AppVerName                         = {#SpecialKName}
AppPublisher                       = {#SpecialKPublisher}
AppPublisherURL                    = {#SpecialKURL}
AppSupportURL                      = {#SpecialKHelpURL}
AppUpdatesURL                      = 
AppCopyright                       = Copyleft 🄯 2015-2023
VersionInfoVersion                 = {#SpecialKVersion}
VersionInfoOriginalFileName        = {#SpecialKFileName}.exe
VersionInfoCompany                 = {#SpecialKPublisher}
DefaultDirName                     = {code:GetSpecialKInstallFolder}\Drivers\WinRing0
DirExistsWarning                   = no
UsePreviousAppDir                  = no
DisableDirPage                     = no
DefaultGroupName                   = {#SpecialKName}
DisableProgramGroupPage            = yes
InfoBeforeFile                     = {#AssetsDir}\SKIFdrv_InfoBefore.rtf
LicenseFile                        = {#AssetsDir}\LICENSE.txt
PrivilegesRequired                 = admin
PrivilegesRequiredOverridesAllowed = 
OutputDir                          = {#OutputDir}
OutputBaseFilename                 = {#SpecialKFileName}
SetupIconFile                      = {#AssetsDir}\icon.ico
Compression                        = lzma2/ultra64
SolidCompression                   = yes
LZMAUseSeparateProcess             = yes
WizardStyle                        = modern
WizardSmallImageFile               = {#AssetsDir}\WizardSmallImageFile.bmp
WizardImageFile                    = {#AssetsDir}\WizardImageFile.bmp
UninstallFilesDir                  = {app}
UninstallDisplayIcon               = {app}\unins000.exe
CloseApplications                  = yes
DisableWelcomePage                 = no
SetupLogging                       = yes
;SignTool                           = signtool


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"


[Messages]
SetupAppTitle    ={#SpecialKName} Setup
SetupWindowTitle ={#SpecialKName}
UninstallAppTitle={#SpecialKName} Uninstall
WelcomeLabel2    =This will install the {#SpecialKName} v {#SpecialKVersion} on your computer.%n%nSpecial K with be extended with advanced hardware monitoring and reporting features in games, such as reporting the CPU temperature and power draw per core as part of its CPU widget.%n%nIt is recommended that you close all other applications before continuing.
ConfirmUninstall =Are you sure you want to completely remove the %1?%n%nThis will disable the extended hardware monitoring features of Special K and revert the CPU widget to its barebone functionality.
DiskSpaceMBLabel =

[Code]

// Dependency handler
function InitializeSetup: Boolean;
begin
  Log('Initializing Setup.');

  Log('Required dependencies:');
  
  // 32-bit Visual C++ 2015-2022 Redistributable
  try
    Log('+ 32-bit Visual C++ 2015-2022 Redistributable');
    Dependency_ForceX86 := True;
    Dependency_AddVC2015To2022;
    Dependency_ForceX86 := False;
  except 
    Log('Catastrophic error in InitializeSetup() for 32-bit Visual C++ 2015-2022 Redistributable!');
    // Surpresses exception when an issue prevents proper lookup
  end;
      
  // 64-bit Visual C++ 2015-2022 Redistributable
  if IsWin64 then
  begin
    try
      Log('+ 64-bit Visual C++ 2015-2022 Redistributable');
      Dependency_AddVC2015To2022;
    except 
      Log('Catastrophic error in InitializeSetup() for 64-bit Visual C++ 2015-2022 Redistributable!');
      // Surpresses exception when an issue prevents proper lookup
    end;
  end;

  Result := True;
end;  


procedure InitializeWizard();
begin 
  Log('Initializing Wizard.');

  if not WizardSilent() then
  begin 
    FixInnoSetupTaskbarPreview();

    // Have the disk spacel label appear here instead of later
    WizardForm.DiskSpaceLabel.Parent := PageFromID(wpWelcome).Surface;
  end;
end;


procedure CurPageChanged(CurPageID: Integer);
var
  AdditionalTasks : String;
begin
  if CurPageID = wpReady then
  begin 
    Log('Initializing Ready Page.');

    Wizardform.ReadyMemo.Font.Name := 'Consolas';

    // CodeDependencies.iss adds the additional tasks to the ReadyMemo before this code executes,
    //   so make a copy of the current text, then clear the lines.
    AdditionalTasks := Wizardform.ReadyMemo.Text;
    Wizardform.ReadyMemo.Lines.Clear();

    // Let's add our custom lines
    Wizardform.ReadyMemo.Lines.Add('');
    Wizardform.ReadyMemo.Lines.Add('Components to install:');
    Wizardform.ReadyMemo.Lines.Add('      {#SpecialKName} v {#SpecialKVersion}');
    Wizardform.ReadyMemo.Lines.Add('');

    // And finally if there is any additional tasks from Inno Setup or CodeDependencies.iss, add them back.
    Wizardform.ReadyMemo.Lines.Add(AdditionalTasks); 

    Wizardform.ReadyMemo.Show;
  end;
end;


[InstallDelete]
Type: files;          Name: "{app}\Version\unins00*"


[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

; NOTE: When solid compression is enabled, be sure to list your temporary files at (or near) the top of the [Files] section.
; In order to extract an arbitrary file in a solid-compressed installation, Setup must first decompress all prior files (to a temporary buffer in memory).
; This can result in a substantial delay if a number of other files are listed above the specified file in the [Files] section.

; No need to replace the driver if it already exists
Source: "{#SourceDir}\*.sys";                        DestDir: "{app}";          Flags: restartreplace uninsrestartdelete;

; Remaining files should always be recreated.
; NOTE: This line causes the files included above to be counted twice in DiskSpaceMBLabel
Source: "{#SourceDir}\*";                            DestDir: "{app}";          Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "WinRing0.sys,WinRing0x64.sys"


[Run]
Filename: "{app}\SKIFdrv.exe";   Parameters: "Install";   WorkingDir: "{app}"; \
  Flags: shellexec waituntilterminated; StatusMsg: "Performing final driver installation..."


[UninstallRun]
Filename: "{app}\SKIFdrv.exe";   Parameters: "Uninstall Silent";   WorkingDir: "{app}"; \
  Flags: shellexec waituntilterminated; RunOnceId: "DeleteDrvService"


[UninstallDelete]                              
; WinRing0.sys is the 32-bit driver of WinRing0, but it's not actually used or supported.
; WinRing0.dll is the only thing required to allow 32-bit applications to use the 64-bit driver.
Type: files;          Name: "{app}\WinRing0.sys"
Type: files;          Name: "{app}\SKIFdrv.log"
Type: dirifempty;     Name: "{app}"

