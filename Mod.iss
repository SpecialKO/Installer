﻿; -- Mod.iss --
;
; This is the install script for the following Special K game mods:
;  - TBFix for Tales of Berseria
;  - TVFix for Tales of Vesperia
;  - UnX   for Final Fantasy X|X-2 HD Remaster
;
; licensed under MIT
; https://github.com/SpecialKO/Installer/blob/main/LICENSE


; NieR: Replicant **DO NOT USE**
;#define Replicant

; Tales of Berseria
#define TBFix

; Tales of Vesperia
;#define TVFix

; Final Fantasy X|X-2 HD Remaster
;#define UnX

#define SpecialKName          "Special K"
#define SpecialKPublisher     "The Special K Group"
#define SpecialKURL           "https://special-k.info/"
#define SpecialKForum         "https://discourse.differentk.fyi/"
#define SpecialKDiscord       "https://discord.gg/specialk"
#define SpecialKPatreon       "https://www.patreon.com/Kaldaien"
#define RedistDir             "Redistributables"              ; Required dependencies and PowerShell helper scripts   
#define OutputDir             "Builds_Mods"                   ; Output folder to put compiled builds of the installer   
#define AssetsDir             "Assets"                        ; LICENSE.txt, icon.ico, WizardImageFile.bmp, and WizardSmallImageFile.bmp

#if Defined Replicant ; NieR: Replicant
  #define SourceDir           "Source_Replicant"
  #define SteamAppID          "1113560"
  #define SpecialKModUninstID "{F11AD53F-5B59-48F6-A550-64E554497FFE}"
  #define SpecialKGameName    "NieR: Replicant"
  #define SpecialKModName     "Radical Replicant"
  #define SpecialKVersion     GetStringFileInfo(SourceDir + '\dxgi.dll', "ProductVersion")
  #define SpecialKHelpURL     "https://wiki.special-k.info/SpecialK/Custom/Replicant"
  #define BackupFile          "NieR Replicant ver.1.22474487139.exe"
  #define DownloadURL         "https://sk-data.special-k.info/misc/nier_replicant_1.0.exe"
  #define DownloadFileName    "NieR Replicant ver.1.22474487139.exe"

#elif Defined TBFix ; Tales of Berseria
  #define SourceDir           "Source_TBFix"
  #define SteamAppID          "429660"
  #define SpecialKModUninstID "{EBE9243D-5ADC-48F2-9716-65F75A4EE203}"
  #define SpecialKGameName    "Tales of Berseria"
  #define SpecialKModName     "TBFix"
  #define SpecialKVersion     GetStringFileInfo(SourceDir + '\tbfix.dll', "ProductVersion")
  #define SpecialKHelpURL     "https://wiki.special-k.info/SpecialK/Custom/TBFix"

#elif Defined TVFix ; Tales of Vesperia
  #define SourceDir           "Source_TVFix"
  #define SteamAppID          "738540"
  #define SpecialKModUninstID "{F6E4AA7A-0E71-48C1-96F4-7497FEBE2819}"
  #define SpecialKGameName    "Tales of Vesperia"
  #define SpecialKModName     "TVFix"
  #define SpecialKVersion     GetVersionNumbersString(SourceDir + '\dxgi.dll') ; "0.5.2.5"
  #define SpecialKHelpURL     "https://wiki.special-k.info/SpecialK/Custom/TVFix"
  #define BackupFile          "TOV_DE.exe"

#elif Defined UnX ; Final Fantasy X|X-2 HD Remaster
  #define SourceDir           "Source_UnX"
  #define SteamAppID          "359870"
  #define SpecialKModUninstID "{0BD6E499-367A-4B80-B38A-DE55B029599F}"
  #define SpecialKGameName    "Final Fantasy X|X-2 HD Remaster"
  #define SpecialKModName     "UnX"
  #define SpecialKVersion     GetStringFileInfo(SourceDir + '\unx.dll', "ProductVersion")
  #define SpecialKHelpURL     "https://wiki.special-k.info/SpecialK/Custom/UnX"

#else
  #define SourceDir           "Source"                        ; Keeps the files and folder structure of the install folder as intended post-install
  ;#define SteamAppID         ""
  ;#define SpecialKGameName   ""
  ;#define SpecialKModName    ""
  #define SpecialKVersion     GetStringFileInfo(SourceDir + '\d3d9.dll', "ProductVersion")
  #define SpecialKHelpURL     "https://wiki.special-k.info/"
#endif

#define SpecialKFileName      StringChange("SpecialK " + SpecialKModName + " " + SpecialKVersion, " ", "_")
#define MusicFileName         "techno_stargazev2.1loop.mp3"

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
LicenseFile                        = {#AssetsDir}\LICENSE_{#SpecialKModName}.txt
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
ConfirmUninstall =Are you sure you want to completely remove %1 and all of its components?%n%nThis may also remove any Special K ({#SpecialKModName}) game data (texture packs, configs, etc).  
DiskSpaceMBLabel =

[Code]
var
  DownloadPage: TDownloadWizardPage;


function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;


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
    WizardForm.DiskSpaceLabel.Parent := PageFromID(wpWelcome).Surface;

    // Sets up the download page
    DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
   
    InitializeMusicPlayback('{#MusicFileName}');
  end;
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


#if Defined DownloadURL
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpReady then begin
    if WizardIsTaskSelected('downgrade') then
    begin
      Log('User selected downgrade.');

      Log('Downloading {#DownloadURL} as {#DownloadFileName} to ' + ExpandConstant('{tmp}'));
      DownloadPage.Clear;
      DownloadPage.Add('{#DownloadURL}', '{#DownloadFileName}', '');
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
    end else
      Result := True;
  end else
    Result := True;
end;
#endif


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

#if Defined UnX
    if FileExists(ExpandConstant('{app}\FFX_LAUnaware.bak')) then
    begin
      Log('Restoring the original file: FFX.exe');
      if not RenameFile(ExpandConstant('{app}\FFX_LAUnaware.bak'), ExpandConstant('{app}\FFX.exe')) then
      begin
        if FileCopy(ExpandConstant('{app}\FFX_LAUnaware.bak'), ExpandConstant('{app}\FFX.exe'), False) then
        begin
          DeleteFile(ExpandConstant('{app}\FFX_LAUnaware.bak'));
        end;
      end;
    end;

    if FileExists(ExpandConstant('{app}\FFX-2_LAUnaware.bak')) then
    begin
      Log('Restoring the original file: FFX-2.exe');
      if not RenameFile(ExpandConstant('{app}\FFX-2_LAUnaware.bak'), ExpandConstant('{app}\FFX-2.exe')) then
      begin
        if FileCopy(ExpandConstant('{app}\FFX-2_LAUnaware.bak'), ExpandConstant('{app}\FFX-2.exe'), False) then
        begin
          DeleteFile(ExpandConstant('{app}\FFX-2_LAUnaware.bak'));
        end;
      end;
    end;

    if FileExists(ExpandConstant('{app}\FFX&X-2_Will_LAUnaware.bak')) then
    begin
      Log('Restoring the original file: FFX&X-2_Will.exe');
      if not RenameFile(ExpandConstant('{app}\FFX&X-2_Will_LAUnaware.bak'), ExpandConstant('{app}\FFX&X-2_Will.exe')) then
      begin
        if FileCopy(ExpandConstant('{app}\FFX&X-2_Will_LAUnaware.bak'), ExpandConstant('{app}\FFX&X-2_Will.exe'), False) then
        begin
          DeleteFile(ExpandConstant('{app}\FFX&X-2_Will_LAUnaware.bak'));
        end;
      end;
    end;
#endif

  end;
end;


[InstallDelete]
Type: files;          Name: "{app}\Version\unins00*"


[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

; NOTE: When solid compression is enabled, be sure to list your temporary files at (or near) the top of the [Files] section.
; In order to extract an arbitrary file in a solid-compressed installation, Setup must first decompress all prior files (to a temporary buffer in memory).
; This can result in a substantial delay if a number of other files are listed above the specified file in the [Files] section.

; Temporary files that are extracted as needed
Source: "{#AssetsDir}\{#MusicFileName}";             DestDir: {tmp};            Flags: dontcopy;

; Main mod files should always be overwritten.
; NOTE: This line causes any files included above to be counted twice in DiskSpaceMBLabel
Source: "{#SourceDir}\*";                            DestDir: "{app}";          Flags: ignoreversion recursesubdirs createallsubdirs; {#if Defined BackupFile} Excludes: "{#BackupFile}" {#endif}

#if Defined BackupFile
Source: "{app}\{#BackupFile}";                       DestDir: "{app}";          Flags: external skipifsourcedoesntexist onlyifdoesntexist uninsneveruninstall; DestName: "{#BackupFile}.bak"; Tasks: downgrade;

; File bundled in the installer
Source: "{#SourceDir}\{#BackupFile}";                DestDir: "{app}";          Flags: ignoreversion skipifsourcedoesntexist;          Tasks: downgrade;

; File downloaded during installation
Source: "{tmp}\{#BackupFile}";                       DestDir: "{app}";          Flags: external ignoreversion skipifsourcedoesntexist; Tasks: downgrade;
#endif


; [Dirs]
; Name: "{app}";          Permissions: users-modify


[Tasks]
#if Defined Replicant
Name: downgrade;   Description: "Downgrade game (required for >60 FPS)";                Flags: unchecked;
#elif Defined TVFix
Name: downgrade;   Description: "Downgrade game (required to access full feature set)";
#endif

[Run]
; Checked by default

Filename: "steam://run/{#SteamAppID}";              Description: "Launch game"; \
  Flags: shellexec nowait postinstall runasoriginaluser

Filename: "{#SpecialKHelpURL}";                     Description: "Open the wiki"; \
  Flags: shellexec nowait postinstall skipifsilent

; Unchecked by default

Filename: "{#SpecialKDiscord}";                     Description: "Join the Discord server"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKForum}";                       Description: "Visit the forum"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKPatreon}";                     Description: "Support the project on Patreon"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked


[UninstallDelete]
Type: filesandordirs; Name: "{app}\CEGUI"
Type: filesandordirs; Name: "{app}\SK_Res"
Type: filesandordirs; Name: "{app}\Version" 
Type: filesandordirs; Name: "{app}\logs"
Type: files;          Name: "{app}\dxgi.ini"
Type: files;          Name: "{app}\d3d9.ini"

