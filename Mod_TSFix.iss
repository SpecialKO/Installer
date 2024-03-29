﻿; -- Mod_TSFix.iss --
;
; This is the install script for the following Special K game mods:
;  - TSFix for Tales of Symphonia
;
;
;
; licensed under MIT
; https://github.com/SpecialKO/Installer/blob/main/LICENSE


#define TSFix

#define SpecialKName          "Special K"
#define SpecialKPublisher     "The Special K Group"
#define SpecialKURL           "https://special-k.info/"
#define SpecialKForum         "https://discourse.differentk.fyi/"
#define SpecialKDiscord       "https://discord.gg/specialk"
#define SpecialKPatreon       "https://www.patreon.com/Kaldaien"
#define RedistDir             "Redistributables"              ; Required dependencies and PowerShell helper scripts   
#define OutputDir             "Builds_Mods"                   ; Output folder to put compiled builds of the installer   
#define AssetsDir             "Assets"                        ; LICENSE.txt, icon.ico, WizardImageFile.bmp, and WizardSmallImageFile.bmp

#if Defined TSFix ; Tales of Symphonia
  #define SourceDir           "Source_TSFix"
  #define SteamAppID          "372360"
  #define SpecialKModUninstID "{947863C3-EB5E-4496-995D-17EDABCD580D}"
  #define SpecialKGameName    "Tales of Symphonia"
  #define SpecialKModName     "TSFix"
  #define SpecialKVersion     GetStringFileInfo(SourceDir + '\tsfix.dll', "ProductVersion")
  #define SpecialKHelpURL     "https://wiki.special-k.info/en/SpecialK/Custom/TSFix"
  #define BackupFile          "TOS.exe"

  // Texture packs
  #define File_dlc_cleanup_ui          "97_UICleanup.7z"
  #define File_dlc_cleanup_effects     "98_Cleanup.7z"
  #define File_dlc_cleanup_characters  "98_CharactersCombined.7z"
  #define File_dlc_cleanup_font        "01_CleanFont.7z"

  // Button mods
  #define File_dlc_gamepad_ps3         "00_PS3Buttons.7z"
  #define File_dlc_gamepad_gc          "00_GCButtons.7z"

  // 4K texture pack (downloaded during install)
  #define File_dlc_cleanup_4k_upscale  "99_Upscale4x.7z"
  #define Link_dlc_cleanup_4k_upscale  "https://sk-data.special-k.info/TSFix/99_Upscale4x.7z"
#endif

#define SpecialKFileName  StringChange("SpecialK " + SpecialKModName + " " + SpecialKVersion, " ", "_") 
#define MusicFileName     "techno_stargazev2.1loop.mp3"

#include "SpecialK_Shared.iss"

#define public Dependency_NoExampleSetup
#include "CodeDependencies.iss"


[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
ArchitecturesInstallIn64BitMode    = x64
ArchitecturesAllowed               = x86 x64
MinVersion                         = 6.3.9600
AppId                              = {{#SpecialKModUninstID}
AppName                            = {#SpecialKName} ({#SpecialKModName}) for {#SpecialKGameName}
AppVersion                         = {#SpecialKVersion}  
AppVerName                         = {#SpecialKName} ({#SpecialKModName}) for {#SpecialKGameName}
AppPublisher                       = {#SpecialKPublisher}
AppPublisherURL                    = {#SpecialKURL}
AppSupportURL                      = {#SpecialKHelpURL}
AppUpdatesURL                      = 
AppCopyright                       = Copyleft 🄯 2015-2022
VersionInfoVersion                 = {#SpecialKVersion}
VersionInfoOriginalFileName        = {#SpecialKFileName}.exe
VersionInfoCompany                 = {#SpecialKPublisher}
DefaultDirName                     = {code:GetSteamInstallFolder|{#SteamAppID}}
DirExistsWarning                   = no
UsePreviousAppDir                  = no
DisableDirPage                     = no
DefaultGroupName                   = {#SpecialKName}
DisableProgramGroupPage            = yes
LicenseFile                        = {#AssetsDir}\LICENSE_TSFix.txt
PrivilegesRequired                 = lowest
PrivilegesRequiredOverridesAllowed = commandline
OutputDir                          = {#OutputDir}
OutputBaseFilename                 = {#SpecialKFileName}
SetupIconFile                      = {#AssetsDir}\icon.ico
Compression                        = lzma2/ultra64
SolidCompression                   = yes
LZMAUseSeparateProcess             = yes
WizardStyle                        = modern
WizardSmallImageFile               = {#AssetsDir}\WizardSmallImageFile.bmp
WizardImageFile                    = {#AssetsDir}\WizardImageFile.bmp
UninstallFilesDir                  = {app}\Version\
UninstallDisplayIcon               = {app}\Version\unins000.exe
CloseApplications                  = yes
DisableWelcomePage                 = no
SetupLogging                       = yes
SetupMutex                         = SKSetupMutex{#SetupSetting("AppId")}


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"


[Messages]
SetupAppTitle    ={#SpecialKName} Setup
SetupWindowTitle ={#SpecialKName} ({#SpecialKModName}) v {#SpecialKVersion} for {#SpecialKGameName}
UninstallAppTitle={#SpecialKName} Uninstall
WelcomeLabel2    =This will install {#SpecialKName} ({#SpecialKModName}) v {#SpecialKVersion} for {#SpecialKGameName} on your computer.%n%nLovingly referred to as the Swiss Army Knife of PC gaming, Special K does a bit of everything. It is best known for fixing and enhancing graphics, its many detailed performance analysis and correction mods, and a constantly growing palette of tools that solve a wide variety of issues affecting PC games.%n%nIt is recommended that you close all other applications before continuing.
ConfirmUninstall =Are you sure you want to completely remove %1 and all of its components?  
DiskSpaceMBLabel =

[Code]
var
  DownloadPage:  TDownloadWizardPage;
  DisplayWidth:  Integer;
  DisplayHeight: Integer;

Const
    SM_CXSCREEN = 0; // The enum-value for getting the width of the cient area for a full-screen window on the primary display monitor, in pixels.
    SM_CYSCREEN = 1; // The enum-value for getting the height of the client area for a full-screen window on the primary display monitor, in pixels.

// Used to retrieve primary display resolution
function GetSystemMetrics (nIndex: Integer): Integer;
  external 'GetSystemMetrics@User32.dll stdcall setuponly';


function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;


// Function to create an appropriate CustomConfig.conf file in the game folder
procedure CreateCustomConfig();
begin
  Log('Creating CustomConfig.conf...');
  SaveStringToFile(ExpandConstant('{app}\CustomConfig.conf'), Format('Resolution=%dx%d', [DisplayWidth, DisplayHeight]) + #13#10 + 'FullScreen=0' + #13#10, False);
end;


// Dependency handler
function InitializeSetup: Boolean;
begin
  Log('Initializing Setup.'); 

  Log('Required dependencies:');

  // DirectX End-User Runtime
  //Dependency_AddDirectX;
  
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
  (*
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
  *)

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

    // Sets up the download page
    DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);

    InitializeMusicPlayback('{#MusicFileName}');
  end;
 
  DisplayWidth  := GetSystemMetrics(SM_CXSCREEN);
  DisplayHeight := GetSystemMetrics(SM_CYSCREEN);

  Log(Format('Primary display resolution: %dx%d', [DisplayWidth, DisplayHeight]));
end;


procedure DeinitializeSetup();
begin 
  DeinitializeMusicPlayback();
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
    Wizardform.ReadyMemo.Lines.Add('      Special K ({#SpecialKModName}) v {#SpecialKVersion} for {#SpecialKGameName}');
    Wizardform.ReadyMemo.Lines.Add('');

    // And finally if there is any additional tasks from Inno Setup or CodeDependencies.iss, add them back.
    Wizardform.ReadyMemo.Lines.Add(AdditionalTasks); 

    Wizardform.ReadyMemo.Show;
  end;
end;                


// Code that downloads the optional selected tasks
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpReady then begin

    // 4K texture pack (downloaded during install due to its 5 GB large size)
    if WizardIsTaskSelected('dlc_cleanup_4k_upscale') then
    begin
      Log('User selected dlc_cleanup_4k_upscale.');

      // Only download the file if it does not already exist
      if FileExists(ExpandConstant('{app}\TSFix_Res\inject\{#File_dlc_cleanup_4k_upscale}')) then
      begin
        Log('Skipping download as {#File_dlc_cleanup_4k_upscale} already exists: ' + ExpandConstant('{app}\TSFix_Res\inject\{#File_dlc_cleanup_4k_upscale}'));
        Result := True;
      end
      else
      begin
        Log('Downloading {#Link_dlc_cleanup_4k_upscale} as {#File_dlc_cleanup_4k_upscale} to ' + ExpandConstant('{tmp}'));
        DownloadPage.Clear;
        DownloadPage.Add('{#Link_dlc_cleanup_4k_upscale}', '{#File_dlc_cleanup_4k_upscale}', '');
        DownloadPage.Show;
        try
          try
            DownloadPage.Download; // This downloads the files to {tmp}
            Result := True;
          except
            if DownloadPage.AbortedByUser then
              Log('Aborted by user.')
            else
              SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
            Result := False;
          end;
        finally
          DownloadPage.Hide;
        end;
      end;
    end else
      Result := True;


  end else
    Result := True;
end;


function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  WasVisible       : Boolean;
  ResultCode       : Integer;

begin 
  Log('Preparing Install.');

  WasVisible   := WizardForm.PreparingLabel.Visible;
  Result       := '';
  ResultCode   := 0;

  try 
    Log('Establishing WMI connection...'); 
    WbemLocator   := CreateOleObject('WbemScripting.SWbemLocator');
    WbemServices  := WbemLocator.ConnectServer('localhost', 'root\CIMV2');

    WizardForm.PreparingLabel.Visible := True;
    WizardForm.PreparingLabel.Caption := '';
    Wizardform.NextButton.Visible := False;
    Wizardform.NextButton.Enabled := False;
    Wizardform.BackButton.Visible := False;
    Wizardform.BackButton.Enabled := False;

    if not WizardSilent() then
    begin
      // Check if NT AUTHORITY\INTERACTIVE is in BUILTIN\Performance Log Users and if not, make it so
      WizardForm.PreparingLabel.Caption := 'Checking membership in the local ''Performance Log Users'' group...';
      Log('Checking membership in the local ''Performance Log Users'' group.');

      if not IsInteractiveInPLU() then
      begin
        WizardForm.PreparingLabel.Caption := 'Attempting to grant membership in the local ''Performance Log Users'' group...';
        Log('Launching ''net'' elevated to add user (' + LocINTUserName + ') to the group (' + LocPLUGroupName + ').');
        ShellExec('RunAs', 'net', 'localgroup "' + LocPLUGroupName + '" "' + LocINTUserName + '" /add', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

        Sleep(500);

        if ResultCode <> 0 then
        begin
          Log('Failed to grant permission : ' + IntToStr(ResultCode) + ', ' + SysErrorMessage(ResultCode));
        end;      
      end;

      ResultCode   := 0;
    end;

#if Defined UnX
    WizardForm.PreparingLabel.Caption := 'Making game executables Large Address Aware (LAA)...';
    Log('Making game executables Large Address Aware (LAA).');

    MakeExecutableLAAware(ExpandConstant('{app}\FFX.exe'));
    MakeExecutableLAAware(ExpandConstant('{app}\FFX-2.exe'));
    MakeExecutableLAAware(ExpandConstant('{app}\FFX&X-2_Will.exe'));
#endif
  
  except 
    Log('Catastrophic error in PrepareToInstall()!');
    // Surpresses exception when task does not exist or another issue prevents proper lookup
  finally
    WizardForm.PreparingLabel.Visible := WasVisible;
  end;
end;

// Gets processed after the main uninstall steps, see https://stackoverflow.com/a/31499471/15133327
// This is needed to restore any backed up files.
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin

#if Defined BackupFile
    if FileExists(ExpandConstant('{app}\{#BackupFile}.bak')) then
    begin
      Log('Restoring the original file: {#BackupFile}');
      if not RenameFile(ExpandConstant('{app}\{#BackupFile}.bak'), ExpandConstant('{app}\{#BackupFile}')) then
      begin
        if FileCopy(ExpandConstant('{app}\{#BackupFile}.bak'), ExpandConstant('{app}\{#BackupFile}'), False) then
        begin
          DeleteFile(ExpandConstant('{app}\{#BackupFile}.bak'));
        end;
      end;
    end;
#endif

  end;
end;


[InstallDelete]
Type: files;          Name: "{app}\Version\unins00*"
; Texture packs
Type: files;          Name: "{app}\TSFix_Res\inject\{#File_dlc_cleanup_ui}";            Tasks: not dlc_cleanup_ui;
Type: files;          Name: "{app}\TSFix_Res\inject\{#File_dlc_cleanup_effects}";       Tasks: not dlc_cleanup_effects;
Type: files;          Name: "{app}\TSFix_Res\inject\{#File_dlc_cleanup_characters}";    Tasks: not dlc_cleanup_characters;
Type: files;          Name: "{app}\TSFix_Res\inject\{#File_dlc_cleanup_font}";          Tasks: not dlc_cleanup_font;
; Button mods        
Type: files;          Name: "{app}\TSFix_Res\inject\{#File_dlc_gamepad_ps3}";           Tasks: not dlc_gamepad_ps3;
Type: files;          Name: "{app}\TSFix_Res\inject\{#File_dlc_gamepad_gc}";            Tasks: not dlc_gamepad_gc;
; 4K texture pack (downloaded during install) 
Type: files;          Name: "{app}\TSFix_Res\inject\{#File_dlc_cleanup_4k_upscale}";    Tasks: not dlc_cleanup_4k_upscale;


[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

; NOTE: When solid compression is enabled, be sure to list your temporary files at (or near) the top of the [Files] section.
; In order to extract an arbitrary file in a solid-compressed installation, Setup must first decompress all prior files (to a temporary buffer in memory).
; This can result in a substantial delay if a number of other files are listed above the specified file in the [Files] section.

; Temporary files that are extracted as needed
Source: "{#AssetsDir}\techno_stargazev2.1loop.mp3";  DestDir: {tmp};            Flags: dontcopy;

; Main mod files should always be overwritten.
; NOTE: This line causes any files included above to be counted twice in DiskSpaceMBLabel
Source: "{#SourceDir}\*";                            DestDir: "{app}";          Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "{#BackupFile},d3d9.ini,tsfix.ini,dgVoodoo.conf,\TSFix_Res\inject\*";    AfterInstall: CreateCustomConfig

; Files that should be respected and not overwritten on reinstalls
Source: "{#SourceDir}\d3d9.ini";                     DestDir: "{app}";          Flags: onlyifdoesntexist;
Source: "{#SourceDir}\tsfix.ini";                    DestDir: "{app}";          Flags: onlyifdoesntexist;
Source: "{#SourceDir}\dgVoodoo.conf";                DestDir: "{app}";          Flags: onlyifdoesntexist;

#if Defined BackupFile
Source: "{app}\{#BackupFile}";                       DestDir: "{app}";          Flags: external skipifsourcedoesntexist onlyifdoesntexist uninsneveruninstall; DestName: "{#BackupFile}.bak";

; File bundled in the installer
Source: "{#SourceDir}\{#BackupFile}";                DestDir: "{app}";          Flags: ignoreversion skipifsourcedoesntexist;
#endif

; Texture packs
Source: "{#SourceDir}\TSFix_Res\inject\{#File_dlc_cleanup_ui}";           DestDir: "{app}\TSFix_Res\inject";      Flags: ignoreversion skipifsourcedoesntexist;           Tasks: dlc_cleanup_ui;
Source: "{#SourceDir}\TSFix_Res\inject\{#File_dlc_cleanup_effects}";      DestDir: "{app}\TSFix_Res\inject";      Flags: ignoreversion skipifsourcedoesntexist;           Tasks: dlc_cleanup_effects;
Source: "{#SourceDir}\TSFix_Res\inject\{#File_dlc_cleanup_characters}";   DestDir: "{app}\TSFix_Res\inject";      Flags: ignoreversion skipifsourcedoesntexist;           Tasks: dlc_cleanup_characters;
Source: "{#SourceDir}\TSFix_Res\inject\{#File_dlc_cleanup_font}";         DestDir: "{app}\TSFix_Res\inject";      Flags: ignoreversion skipifsourcedoesntexist;           Tasks: dlc_cleanup_font;

; Button mods
Source: "{#SourceDir}\TSFix_Res\inject\{#File_dlc_gamepad_ps3}";          DestDir: "{app}\TSFix_Res\inject";      Flags: ignoreversion skipifsourcedoesntexist;           Tasks: dlc_gamepad_ps3;
Source: "{#SourceDir}\TSFix_Res\inject\{#File_dlc_gamepad_gc}";           DestDir: "{app}\TSFix_Res\inject";      Flags: ignoreversion skipifsourcedoesntexist;           Tasks: dlc_gamepad_gc;

; 4K texture pack (downloaded during install)
Source: "{tmp}\{#File_dlc_cleanup_4k_upscale}";                           DestDir: "{app}\TSFix_Res\inject";      Flags: external ignoreversion skipifsourcedoesntexist;  Tasks: dlc_cleanup_4k_upscale;

; [Dirs]
; Name: "{app}";          Permissions: users-modify


[Tasks]
; Texture packs
Name: dlc_cleanup_4k_upscale;     Flags: unchecked;              GroupDescription: "General texture packs:";    Description: "4K upscaled textures (downloads 5 GB of additional data)";
Name: dlc_cleanup_ui;             Flags: ;                       GroupDescription: "General texture packs:";    Description: "Cleaned up UI";
Name: dlc_cleanup_effects;        Flags: ;                       GroupDescription: "General texture packs:";    Description: "Cleaned up cloud and visual effects";
Name: dlc_cleanup_characters;     Flags: ;                       GroupDescription: "General texture packs:";    Description: "Cleaned up characters"; 
Name: dlc_cleanup_font;           Flags: ;                       GroupDescription: "General texture packs:";    Description: "Cleaned up font";

; The Xbox buttons are a part of the game, so if that task is checked we just remove the other button mods
Name: dlc_gamepad_xbox;           Flags: exclusive;              GroupDescription: "Button prompts:";           Description: "Xbox";                        
Name: dlc_gamepad_ps3;            Flags: unchecked exclusive;    GroupDescription: "Button prompts:";           Description: "Playstation 3";
Name: dlc_gamepad_gc;             Flags: unchecked exclusive;    GroupDescription: "Button prompts:";           Description: "GameCube";


[Run]
; Checked by default

Filename: "steam://run/{#SteamAppID}";              Description: "Launch game"; \
  Flags: shellexec nowait postinstall runasoriginaluser

Filename: "{#SpecialKHelpURL}";                     Description: "Open the wiki"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

; Unchecked by default

Filename: "{#SpecialKDiscord}";                     Description: "Join the Discord server"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKForum}";                       Description: "Visit the forum"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKPatreon}";                     Description: "Support the project on Patreon"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked


; Game does not handle DPI properly, and since we force it to run at primary desktop resolution we also need to tell Windows to not apply virtual DPI scaling
[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; ValueType: string; ValueName: "{app}\TOS.exe"; ValueData: "~ HIGHDPIAWARE"; Flags: dontcreatekey deletevalue uninsdeletevalue noerror;


[UninstallDelete]
Type: filesandordirs; Name: "{app}\CEGUI"
Type: filesandordirs; Name: "{app}\SK_Res"
Type: filesandordirs; Name: "{app}\Version"
Type: filesandordirs; Name: "{app}\TSFix_Res" 
Type: filesandordirs; Name: "{app}\logs"
Type: files;          Name: "{app}\d3d9.ini"
Type: files;          Name: "{app}\tsfix.ini"
Type: files;          Name: "{app}\dgVoodoo.conf"

