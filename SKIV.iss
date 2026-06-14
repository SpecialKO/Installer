; -- SKIV.iss --
;
; This is the install script for the dedicated SKIV installer.
;
; licensed under MIT
; https://github.com/SpecialKO/Installer/blob/main/LICENSE


#define SpecialKName      "Special K Image Viewer"
#define SpecialKPublisher "The Special K Group"
#define SpecialKURL       "https://special-k.info/"
#define SpecialKHelpURL   "https://wiki.special-k.info/"
#define SpecialKForum     "https://discourse.special-k.info/"
#define SpecialKDiscord   "https://discord.special-k.info"
#define SpecialKPatreon   "https://www.patreon.com/Kaldaien"
#define SpecialKExeName   "SKIV.exe"
#define SourceDir         "Source_SKIV"                   ; Keeps the files and folder structure of the install folder as intended post-install
#define RedistDir         "Redistributables"              ; Required dependencies and PowerShell helper scripts
#define OutputDir         "Builds_SKIV"                   ; Output folder to put compiled builds of the installer
#define AssetsDir         "Assets"                        ; LICENSE.txt, icon.ico, WizardImageFile.bmp, and WizardSmallImageFile.bmp
#define SKIVVersion       GetStringFileInfo(SourceDir + '\SKIV.exe',       "ProductVersion")

#include "SpecialK_Shared.iss"

#define public Dependency_NoExampleSetup
#include "CodeDependencies.iss"


[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
ArchitecturesInstallIn64BitMode    = x64compatible
ArchitecturesAllowed               = x86compatible x64compatible
; Windows 8.1
; MinVersion                         = 6.3.9600
; Windows 7 SP1
MinVersion                         = 6.1sp1
AppId                              = {{#SKIVUninstID}
AppName                            = {#SpecialKName}
AppVersion                         = {#SKIVVersion}
AppVerName                         = {#SpecialKName}
AppPublisher                       = {#SpecialKPublisher}
AppPublisherURL                    = {#SpecialKURL}
AppSupportURL                      = {#SpecialKHelpURL}
AppUpdatesURL                      =
AppCopyright                       = Copyleft 🄯 2026
VersionInfoVersion                 = {#SKIVVersion}
VersionInfoOriginalFileName        = SKIV_{#SKIVVersion}.exe
VersionInfoCompany                 = {#SpecialKPublisher}
DefaultDirName                     = {autopf}\{#SpecialKName}
UsePreviousAppDir                  = yes
DisableDirPage                     = no
DefaultGroupName                   = {#SpecialKName}
DisableProgramGroupPage            = yes
LicenseFile                        = {#AssetsDir}\LICENSE_SKIV.txt
PrivilegesRequired                 = lowest
PrivilegesRequiredOverridesAllowed = commandline dialog
OutputDir                          = {#OutputDir}
OutputBaseFilename                 = SKIV_{#SKIVVersion}
SetupIconFile                      = {#AssetsDir}\SKIV.ico
Compression                        = lzma2/ultra64
SolidCompression                   = yes
LZMAUseSeparateProcess             = yes
WizardStyle                        = modern dynamic windows11 hidebevels includetitlebar
WizardImageFile                    = {#AssetsDir}\WizardImageFileZoom.bmp
WizardImageFileDynamicDark         = {#AssetsDir}\WizardImageFileZoom.bmp
WizardImageAlphaFormat             = defined
WizardSmallImageFile               = {#AssetsDir}\WizardSmallImageFile_SKIV.bmp
WizardSmallImageFileDynamicDark    = {#AssetsDir}\WizardSmallImageFile_SKIV.bmp
UninstallFilesDir                  = {app}
UninstallDisplayIcon               = {app}\SKIV.exe
CloseApplications                  = yes
DisableWelcomePage                 = no
SetupLogging                       = yes
SetupMutex                         = SKSetupMutex{#SetupSetting("AppId")}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"


[Messages]
SetupAppTitle    ={#SpecialKName} Setup
SetupWindowTitle ={#SpecialKName} v {#SKIVVersion}
UninstallAppTitle={#SpecialKName} Uninstall
WelcomeLabel2    =This will install {#SpecialKName} v {#SKIVVersion} on your computer.%n%nPortable HDR image viewer, screen capture/snipping, tonemapping and analysis tool with decode/encode/transcode for JPEG-XR, JPEG-XL, AVIF, Radiance HDR, OpenEXR, UltraHDR and PNG.%n%nIt is recommended that you close all other applications before continuing.
ConfirmUninstall =Are you sure you want to completely remove %1 and all of its components?
DiskSpaceMBLabel =


[Code]
// Shared code is stored in SpecialK_Shared.iss

// Dependency handler
function InitializeSetup: Boolean;
begin
  Log('Initializing Setup.');

  Log('Required dependencies:');

  // DirectX End-User Runtime
  //Dependency_AddDirectX;
  // Not required any longer following the removal of CEGUI

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
    WizardForm.DiskSpaceLabel.Parent  := PageFromID(wpWelcome).Surface;
    // Hide the disk spacel label
    WizardForm.DiskSpaceLabel.Visible := False;

    InitializePatreonButton();
  end;
end;


procedure DeinitializeSetup();
begin

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
    Wizardform.ReadyMemo.Lines.Add('      Special K Image Viewer (SKIV) v {#SKIVVersion}');
    Wizardform.ReadyMemo.Lines.Add('');
    //Wizardform.ReadyMemo.Lines.Add('Destination location:');
    //Wizardform.ReadyMemo.Lines.Add(ExpandConstant('      {app}'));
    //Wizardform.ReadyMemo.Lines.Add('');

    //if SwitchHasValue('Shortcuts', 'true', 'true') then
    //begin
    //  Wizardform.ReadyMemo.Lines.Add('Shortcuts:');
    //  Wizardform.ReadyMemo.Lines.Add('      Desktop');
    //  Wizardform.ReadyMemo.Lines.Add('      Start menu');
    //  Wizardform.ReadyMemo.Lines.Add('');
    //end;

    // And finally if there is any additional tasks from Inno Setup or CodeDependencies.iss, add them back.
    Wizardform.ReadyMemo.Lines.Add(AdditionalTasks);

    Wizardform.ReadyMemo.Show;
  end;
end;


function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  WasVisible       : Boolean;

begin
  Log('Preparing Install.');

  WasVisible   := WizardForm.PreparingLabel.Visible;
  Result       := '';

  // Do custom install stuff here...

end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
    DefaultCaption   : String;

begin
  if CurUninstallStep = usUninstall then
  begin
    Log('Preparing Uninstall.');

    DefaultCaption := UninstallProgressForm.StatusLabel.Caption;

    // Do custom uninstall stuff here...

    UninstallProgressForm.StatusLabel.Caption := DefaultCaption;
  end;
end;


[InstallDelete]
Type: files;          Name: "{app}\SpecialK32.pdb"
Type: files;          Name: "{app}\SpecialK64.pdb"
Type: files;          Name: "{app}\unins00*"
Type: filesandordirs; Name: "{app}\Fonts"


[Registry]
Root: HKCU; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SKIV.exe";                    ValueType: string; ValueData: "{app}\{#SpecialKExeName}";   Flags: dontcreatekey  uninsdeletekey   createvalueifdoesntexist
Root: HKCU; Subkey: "SOFTWARE\Kaldaien\Special K\Viewer";                           ValueName: "Path"; ValueType: string; ValueData: "{app}";                      Flags:                uninsdeletevalue createvalueifdoesntexist
Root: HKCU; Subkey: "SOFTWARE\Kaldaien\Special K\Viewer";                                                                                                          Flags: dontcreatekey  uninsdeletekey


[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

; NOTE: When solid compression is enabled, be sure to list your temporary files at (or near) the top of the [Files] section.
; In order to extract an arbitrary file in a solid-compressed installation, Setup must first decompress all prior files (to a temporary buffer in memory).
; This can result in a substantial delay if a number of other files are listed above the specified file in the [Files] section.

; Temporary files that are extracted as needed

; Main Special K files should always be overwritten
Source: "{#SourceDir}\SKIV.exe";                     DestDir: "{app}";          Flags: ignoreversion;                            Check: IsWin64;
Source: "{#SourceDir}\SpecialK64.dll";               DestDir: "{app}";          Flags: ignoreversion;                            Check: IsWin64;
Source: "{#SourceDir}\SpecialK64.pdb";               DestDir: "{app}";          Flags: ignoreversion skipifsourcedoesntexist;    Check: IsWin64;
Source: "{#SourceDir}\SKIV32.exe";                   DestDir: "{app}";          Flags: ignoreversion;  DestName: "SKIV.exe";     Check: not IsWin64;
Source: "{#SourceDir}\SpecialK32.dll";               DestDir: "{app}";          Flags: ignoreversion;                            Check: not IsWin64;
Source: "{#SourceDir}\SpecialK32.pdb";               DestDir: "{app}";          Flags: ignoreversion skipifsourcedoesntexist;    Check: not IsWin64;

; Remaining files should only be created if they do not exist already.
; NOTE: This line causes the files included above to be counted twice in DiskSpaceMBLabel
Source: "{#SourceDir}\*";                            DestDir: "{app}";          Flags: onlyifdoesntexist recursesubdirs createallsubdirs;  Excludes: "SKIV.exe,SKIV32.exe,\SpecialK32.dll,\SpecialK32.pdb,\SpecialK64.dll,\SpecialK64.pdb"


[Dirs]
Name: "{app}";          Permissions: users-modify
Name: "{app}\Fonts"


[Tasks]
Name: desktopicon;   Description: "Create &desktop shortcut";     Flags: unchecked
Name: startmenu;     Description: "Create start menu shortcut";


[Icons]
Name: "{autoprograms}\{#SpecialKName}";    Filename: "{app}\{#SpecialKExeName}";    Check: SwitchHasValue('Shortcuts', 'true', 'true');    Tasks: startmenu
Name:  "{autodesktop}\{#SpecialKName}";    Filename: "{app}\{#SpecialKExeName}";    Check: SwitchHasValue('Shortcuts', 'true', 'true');    Tasks: desktopicon


[Run]
; Checked by default

; Normal install
Filename: "{app}\{#SpecialKExeName}";               Description: "{cm:LaunchProgram,{#StringChange(SpecialKName, '&', '&&')}}"; \
  Flags: nowait postinstall runasoriginaluser skipifsilent;                                    Check: SwitchHasValue('LaunchSKIV', 'true', 'true');

; Silent install
Filename: "{app}\{#SpecialKExeName}";               Description: "{cm:LaunchProgram,{#StringChange(SpecialKName, '&', '&&')}}"; \
  Flags: nowait postinstall runasoriginaluser skipifnotsilent;                                 Check: SwitchHasValue('StartMinimized', '0', '0');

; Silent install + minimize
Filename: "{app}\{#SpecialKExeName}";               Description: "{cm:LaunchProgram,{#StringChange(SpecialKName, '&', '&&')}}"; \
  Flags: nowait postinstall runasoriginaluser skipifnotsilent;   Parameters: "Minimize";       Check: SwitchHasValue('StartMinimized', '1', '0');

Filename: "{#SpecialKHelpURL}";                     Description: "Open the wiki"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

; Unchecked by default

Filename: "{#SpecialKDiscord}";                     Description: "Join the Discord server"; \
   Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKForum}";                       Description: "Visit the forum"; \
   Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKPatreon}";                     Description: "Support the project on Patreon"; \
   Flags: shellexec nowait postinstall skipifsilent unchecked


[UninstallDelete]
Type: files;          Name: "{app}\imgui.ini"
Type: files;          Name: "{app}\SKIV.ini"
Type: files;          Name: "{app}\SKIV.log"
Type: files;          Name: "{app}\SKIV.log.bak"
Type: filesandordirs; Name: "{app}\Fonts"
Type: dirifempty;     Name: "{app}"

