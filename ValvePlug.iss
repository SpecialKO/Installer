; -- ValvePlug.iss --
;
; This is the install script for ValvePlug
;   https://github.com/SpecialKO/ValvePlug
;
;
;
; licensed under MIT
; https://github.com/SpecialKO/Installer/blob/main/LICENSE


#define SpecialKName      "Steam Input Disabler (Valve Plug)"
#define SpecialKPublisher "The Special K Group"
#define SpecialKURL       "https://github.com/SpecialKO/ValvePlug"
#define SpecialKHelpURL   "https://github.com/SpecialKO/ValvePlug"
#define SpecialKForum     "https://discourse.differentk.fyi/"
#define SpecialKDiscord   "https://discord.gg/specialk"
#define SpecialKPatreon   "https://www.patreon.com/Kaldaien"
#define SpecialKExeName   "SKIF.exe"                                                                                 
#define SourceDir         "Source_ValvePlug"              ; Keeps the files and folder structure of the install folder as intended post-install
#define RedistDir         "Redistributables"              ; Required dependencies and PowerShell helper scripts   
#define OutputDir         "Builds_ValvePlug"              ; Output folder to put compiled builds of the installer   
#define AssetsDir         "Assets"                        ; LICENSE.txt, icon.ico, WizardImageFile.bmp, and WizardSmallImageFile.bmp
#define SpecialKVersion   GetStringFileInfo(SourceDir + '\XInput1_4.dll', "ProductVersion") ; ProductVersion
;#define MusicFileName     "techno_stargazev2.1loop.mp3"
#define SteamAppID        "0"

#include "SpecialK_Shared.iss"

#define public Dependency_NoExampleSetup
#include "CodeDependencies.iss"


[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
ArchitecturesInstallIn64BitMode    = x64
ArchitecturesAllowed               = x86 x64
; Windows 8.1
; MinVersion                         = 6.3.9600
; Windows 7 SP1
MinVersion                        = 6.1sp1
AppId                              = {{#ValvePlugUninstID}
AppName                            = {#SpecialKName}
AppVersion                         = {#SpecialKVersion}  
AppVerName                         = {#SpecialKName}
AppPublisher                       = {#SpecialKPublisher}
AppPublisherURL                    = {#SpecialKURL}
AppSupportURL                      = {#SpecialKHelpURL}
AppUpdatesURL                      = 
AppCopyright                       = Copyleft 🄯 2024
VersionInfoVersion                 = {#SpecialKVersion}
VersionInfoOriginalFileName        = ValvePlug_{#SpecialKVersion}.exe
VersionInfoCompany                 = {#SpecialKPublisher}
DefaultDirName                     = {code:GetSteamInstallFolder|{#SteamAppID}}
DirExistsWarning                   = no
UsePreviousAppDir                  = no
DisableDirPage                     = yes
DefaultGroupName                   = {#SpecialKName}
DisableProgramGroupPage            = yes
LicenseFile                        = {#AssetsDir}\LICENSE_ValvePlug.txt
PrivilegesRequired                 = lowest
PrivilegesRequiredOverridesAllowed = 
OutputDir                          = {#OutputDir}
OutputBaseFilename                 = ValvePlug_{#SpecialKVersion}
SetupIconFile                      = {#AssetsDir}\icon.ico
Compression                        = lzma2/ultra64
SolidCompression                   = yes
LZMAUseSeparateProcess             = yes
WizardStyle                        = modern
WizardSmallImageFile               = {#AssetsDir}\WizardSmallImageFile.bmp
WizardImageFile                    = {#AssetsDir}\WizardImageFile.bmp
UninstallFilesDir                  = {autopf}\ValvePlug
UninstallDisplayIcon               = {autopf}\ValvePlug\unins000.exe
CloseApplications                  = yes
RestartApplications                = yes
DisableWelcomePage                 = no
SetupLogging                       = yes
SetupMutex                         = SKSetupMutex{#SetupSetting("AppId")}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"


[Messages]
SetupAppTitle    ={#SpecialKName} Setup
SetupWindowTitle ={#SpecialKName} v {#SpecialKVersion}
UninstallAppTitle={#SpecialKName} Uninstall
WelcomeLabel2    =This will install the {#SpecialKName} v {#SpecialKVersion}.%n%nValve Plug is a XInput1_4.dll based drop-in patch to the Steam client to deny it access to input devices using the XInput API and any API that opens handles to HID devices, disabling the Steam Input feature and all related functionality.%n%nThis patch was created because the built-in options of the Steam client labeled "Off" give end-users the illusion of control when in reality none of them, or any combination thereof, allows the user to fully disable Steam Input and its various device enumeration and initialization code.
ConfirmUninstall =Are you sure you want to completely remove the %1 and all of its components?%n%nThis will restore Steam Input and all related functionality.  
DiskSpaceMBLabel =


[Code]
// Shared code is stored in SpecialK_Shared.iss


// -----------
// Global variables
// -----------
var
  ReadMoreButton     : TNewButton;


// This is called by the OnClick handler of a button
procedure ReadMoreButtonClick(Sender: TObject);
var
  ResultCode       : Integer;
begin
  ShellExec('', 'https://github.com/SpecialKO/ValvePlug', '', '', SW_SHOW, ewNoWait, ResultCode);
end;


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
     
    //InitializeMusicPlayback('{#MusicFileName}');
  end;

  // Create Read Mode button
  ReadMoreButton         := TNewButton.Create(WizardForm);
  ReadMoreButton.Parent  := WizardForm;
  ReadMoreButton.Left    :=
    WizardForm.ClientWidth -
    WizardForm.CancelButton.Left - 
    WizardForm.CancelButton.Width;
  ReadMoreButton.Top     := WizardForm.CancelButton.Top; //WizardForm.CancelButton.Top + 50;
  ReadMoreButton.Width   := WizardForm.CancelButton.Width;
  ReadMoreButton.Height  := WizardForm.CancelButton.Height;
  ReadMoreButton.Caption := 'Read More';
  ReadMoreButton.OnClick := @ReadMoreButtonClick;
  ReadMoreButton.Anchors := [akLeft, akBottom];
end;


procedure RegisterExtraCloseApplicationsResources();
begin
  RegisterExtraCloseApplicationsResource(False, ExpandConstant('{app}\Steam.exe'));
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
    Wizardform.ReadyMemo.Lines.Add('      Steam Input Disabler (Valve Plug)   v {#SpecialKVersion}');
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
  DefaultCaption   : String;
  WasVisible       : Boolean;
  InstallFolder    : String;

begin 
  Log('Preparing Install.');

  DefaultCaption := WizardForm.PreparingLabel.Caption;
  WasVisible     := WizardForm.PreparingLabel.Visible;
  Result         := '';

  try
    WizardForm.PreparingLabel.Visible := True;
    WizardForm.PreparingLabel.Caption := '';
    Wizardform.NextButton.Visible := False;
    Wizardform.NextButton.Enabled := False;
    Wizardform.BackButton.Visible := False;
    Wizardform.BackButton.Enabled := False;

    InstallFolder := ExpandConstant('{app}');

    if (IsSteamRunning()) and (FileExists(InstallFolder + '\Steam.exe')) then
    begin 
      Log('Steam.exe file check : detected');
      WizardForm.PreparingLabel.Caption := 'Shutting down Steam...';
      if StopSteam() then
      begin
        repeat
          Sleep(2500);
        until not IsSteamRunning();
      end;
    end;
  
  except 
    Log('Catastrophic error in PrepareToInstall()!');
    // Surpresses exception when task does not exist or another issue prevents proper lookup
  finally
    WizardForm.PreparingLabel.Caption := DefaultCaption;
    WizardForm.PreparingLabel.Visible := WasVisible;
  end;
end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DefaultCaption   : String;
  InstallFolder    : String;
begin
  if CurUninstallStep = usUninstall then
  begin 
    Log('Preparing Uninstall.');

    DefaultCaption := UninstallProgressForm.StatusLabel.Caption;
    InstallFolder := ExpandConstant('{app}');

    if (IsSteamRunning()) and (FileExists(InstallFolder + '\Steam.exe')) then
    begin 
      Log('Steam.exe file check : detected');
      UninstallProgressForm.StatusLabel.Caption := 'Shutting down Steam...'; 
      if StopSteam() then
      begin
        repeat
          Sleep(2500);
        until not IsSteamRunning();
      end;
    end;

    UninstallProgressForm.StatusLabel.Caption := DefaultCaption;
  end;
end;


procedure DeinitializeSetup();
begin
  RestartSteam();
end;


procedure DeinitializeUninstall();
begin
  RestartSteam();
end;


[Types]
Name: "default";    Description: "Disallow Steam Input (default)"
Name: "allow";      Description: "Allow Steam Input";
Name: "custom";     Description: "Custom installation"; Flags: iscustom


[Components]
Name: dll;                 Description: "Install Valve Plug's custom XInput1_4.dll to the base Steam folder";    types: default allow custom;     flags: fixed;
Name: registry;            Description: "Valve Plug registry configuration:";                                    types: default allow custom;     flags: fixed;
Name: registry\disable;    Description: "Disallow Steam Input (default)";                                        types: default;                  flags: disablenouninstallwarning exclusive;
Name: registry\enable;     Description: "Allow Steam Input";                                                     types: allow;                    flags: disablenouninstallwarning exclusive;


[Registry]
Root: HKCU; Subkey: "SOFTWARE\Kaldaien\ValvePlug";                   ValueType: dword;       ValueName: "FillTheSwamp";       ValueData: "1";        Flags: uninsdeletekey;       Components: registry\disable
Root: HKCU; Subkey: "SOFTWARE\Kaldaien\ValvePlug";                   ValueType: dword;       ValueName: "FillTheSwamp";       ValueData: "0";        Flags: uninsdeletekey;       Components: registry\enable


[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

; NOTE: When solid compression is enabled, be sure to list your temporary files at (or near) the top of the [Files] section.
; In order to extract an arbitrary file in a solid-compressed installation, Setup must first decompress all prior files (to a temporary buffer in memory).
; This can result in a substantial delay if a number of other files are listed above the specified file in the [Files] section.

; Temporary files that are extracted as needed
;Source: "{#AssetsDir}\{#MusicFileName}";             DestDir: {tmp};            Flags: dontcopy;

; Main files should always be overwritten
Source: "{#SourceDir}\XInput1_4.dll";                DestDir: "{app}";          Flags: ignoreversion;

; Remaining files should only be created if they do not exist already.
; NOTE: This line causes the files included above to be counted twice in DiskSpaceMBLabel
;Source: "{#SourceDir}\*";                            DestDir: "{app}";          Flags: skipifsourcedoesntexist onlyifdoesntexist recursesubdirs createallsubdirs;  Excludes: "XInput1_4.dll" 


[Run]
; Unchecked by default

Filename: "{#SpecialKHelpURL}";                     Description: "Open the GitHub repository"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKDiscord}";                     Description: "Join the Discord server"; \
   Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKForum}";                       Description: "Visit the forum"; \
   Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKPatreon}";                     Description: "Support the project on Patreon"; \
   Flags: shellexec nowait postinstall skipifsilent unchecked


[UninstallDelete]
Type: dirifempty;     Name: "{autopf}\ValvePlug"