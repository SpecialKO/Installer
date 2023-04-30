﻿; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!


#define SpecialKName      "Special K"
#define SpecialKPublisher "The Special K Group"
#define SpecialKURL       "https://special-k.info/"
#define SpecialKHelpURL   "https://wiki.special-k.info/"
#define SpecialKForum     "https://discourse.differentk.fyi/"
#define SpecialKDiscord   "https://discord.gg/specialk"
#define SpecialKPatreon   "https://www.patreon.com/Kaldaien"
#define SpecialKExeName   "SKIF.exe"                                                                                 
#define SourceDir         "Source"                        ; Keeps the files and folder structure of the install folder as intended post-install
#define RedistDir         "Redistributables"              ; Required dependencies and PowerShell helper scripts   
#define OutputDir         "Builds"                        ; Output folder to put compiled builds of the installer   
#define AssetsDir         "Assets"                        ; LICENSE.txt, icon.ico, WizardImageFile.bmp, and WizardSmallImageFile.bmp
#define SpecialKVersion   GetStringFileInfo(SourceDir + '\SpecialK64.dll', "ProductVersion") ; ProductVersion
#define SKIFVersion       GetStringFileInfo(SourceDir + '\SKIF.exe',       "ProductVersion")

#include "SpecialK_Shared.iss"

#define public Dependency_NoExampleSetup
#include "CodeDependencies.iss"


[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
ArchitecturesInstallIn64BitMode    = x64
ArchitecturesAllowed               = x86 x64
; Windows 8.1
MinVersion                        = 6.3.9600
; Windows 7 SP1
;MinVersion                         = 6.1sp1
AppId                              = {{F4A43527-9457-424A-90A6-17CF02ACF677}
AppName                            = {#SpecialKName}
AppVersion                         = {#SpecialKVersion}  
AppVerName                         = {#SpecialKName}
AppPublisher                       = {#SpecialKPublisher}
AppPublisherURL                    = {#SpecialKURL}
AppSupportURL                      = {#SpecialKHelpURL}
AppUpdatesURL                      = 
AppCopyright                       = Copyleft 🄯 2015-2022
VersionInfoVersion                 = {#SpecialKVersion}
VersionInfoOriginalFileName        = SpecialK_{#SpecialKVersion}.exe
VersionInfoCompany                 = {#SpecialKPublisher}
DefaultDirName                     = {autopf}\Special K
;DefaultDirName                    = {userdocs}\My Mods\SpecialK
UsePreviousAppDir                  = yes
DisableDirPage                     = no
DefaultGroupName                   = {#SpecialKName}
DisableProgramGroupPage            = yes
LicenseFile                        = {#AssetsDir}\LICENSE.txt
PrivilegesRequired                 = lowest
PrivilegesRequiredOverridesAllowed = commandline dialog
OutputDir                          = {#OutputDir}
OutputBaseFilename                 = SpecialK_{#SpecialKVersion}
SetupIconFile                      = {#AssetsDir}\icon.ico
Compression                        = lzma2/ultra64
SolidCompression                   = yes
LZMAUseSeparateProcess             = yes
WizardStyle                        = modern
WizardSmallImageFile               = {#AssetsDir}\WizardSmallImageFile.bmp
WizardImageFile                    = {#AssetsDir}\WizardImageFile.bmp
UninstallFilesDir                  = {app}\Servlet
UninstallDisplayIcon               = {app}\SKIF.exe
CloseApplications                  = yes
DisableWelcomePage                 = no
SetupLogging                       = yes


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"


[Messages]
SetupAppTitle    ={#SpecialKName} Setup
SetupWindowTitle ={#SpecialKName} v {#SpecialKVersion}
UninstallAppTitle={#SpecialKName} Uninstall
WelcomeLabel2    =This will install {#SpecialKName} v {#SpecialKVersion} on your computer.%n%nLovingly referred to as the Swiss Army Knife of PC gaming, Special K does a bit of everything. It is best known for fixing and enhancing graphics, its many detailed performance analysis and correction mods, and a constantly growing palette of tools that solve a wide variety of issues affecting PC games.%n%nIt is recommended that you close all other applications before continuing.
ConfirmUninstall =Are you sure you want to completely remove %1 and all of its components?%n%nThis will also remove any Special K game data (screenshots, texture packs, configs) stored in the Profiles subfolder.  
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

    // Fixes Inno Setup no taskbar preview
    // From StackOverflow: https://stackoverflow.com/a/64162597/15133327
    // Created by: https://stackoverflow.com/users/709507/inside-man
    // Licensed under CC BY-SA 4.0, https://creativecommons.org/licenses/by-sa/4.0/
    //
    // Technically wrong: "You must not call SetWindowLong with the GWL_HWNDPARENT index to change the parent of a child window.
    //                     Instead, use the SetParent function." 
    Log('Fixing the no taskbar preview bug of Inno Setup.');
    SetWindowLong(WizardForm.Handle, -8, GetWindowLong(GetWindow(WizardForm.Handle, 4), -8));

    // Have the disk spacel label appear here instead of later
    WizardForm.DiskSpaceLabel.Parent := PageFromID(wpWelcome).Surface;

    Log('Preparing music components.');
    // Some nice background tunes
    MusicPlayback := false;
    ExtractTemporaryFile('techno_stargazev2.1loop.mp3');
    mciSendString(ExpandConstant('open "{tmp}/techno_stargazev2.1loop.mp3" alias soundbg'), 0, 0, 0);
    //mciSendString('play soundbg repeat', 0, 0, 0);
    mciSendString('setaudio soundbg volume to 125', 0, 0, 0);

    ToggleMusicButton         := TNewButton.Create(WizardForm);
    ToggleMusicButton.Parent  := WizardForm;
    ToggleMusicButton.Left    :=
      WizardForm.ClientWidth -
      WizardForm.CancelButton.Left - 
      WizardForm.CancelButton.Width;
    ToggleMusicButton.Top     := WizardForm.CancelButton.Top; //WizardForm.CancelButton.Top + 50;
    ToggleMusicButton.Width   := WizardForm.CancelButton.Width;
    ToggleMusicButton.Height  := WizardForm.CancelButton.Height;
    ToggleMusicButton.Caption := 'Play Music';
    ToggleMusicButton.OnClick := @ToggleButtonClick;
    ToggleMusicButton.Anchors := [akLeft, akBottom];

    CreditMusicButton         := TNewButton.Create(WizardForm);
    CreditMusicButton.Parent  := WizardForm;
    CreditMusicButton.Left    :=
      WizardForm.ClientWidth -
      WizardForm.NextButton.Left -
      WizardForm.NextButton.Width;
    CreditMusicButton.Top     := WizardForm.NextButton.Top; //WizardForm.CancelButton.Top + 50;
    CreditMusicButton.Width   := WizardForm.NextButton.Width;
    CreditMusicButton.Height  := WizardForm.NextButton.Height;
    CreditMusicButton.Caption := 'Music By';
    CreditMusicButton.OnClick := @CreditButtonClick;
    CreditMusicButton.Anchors := [akLeft, akBottom];
  end;
end;


procedure DeinitializeSetup();
begin
  if not WizardSilent() then
  begin 
    Log('Cleaning up music components.');
    if MusicPlayback then
    begin
      // Stop music playback if it's currently playing
      mciSendString(ExpandConstant('stop soundbg'), 0, 0, 0);
      MusicPlayback := false;
    end;
    // Close the MCI device
    mciSendString(ExpandConstant('close all'), 0, 0, 0);
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
    Wizardform.ReadyMemo.Lines.Add('      Special K                           v {#SpecialKVersion}');
    Wizardform.ReadyMemo.Lines.Add('      Special K Injection Frontend (SKIF) v {#SKIFVersion}');
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
  ResultCode       : Integer;
  AppInitDLLs32    : String;
  AppInitDLLs32Pos : Integer;
  AppInitDLLs64    : String;
  AppInitDLLs64Pos : Integer;
  OldDLLsEnding    : String;

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

    // Determine if OneDrive is running and if so prompt user about closing it 
    Log('Checking if OneDrive is used for the Documents folder...');

    if (Pos('OneDrive', ExpandConstant('{app}')) > 0) and (IsOneDriveRunning()) then
    begin 
      Log('Prompting the user about OneDrive...'); 
      WizardForm.PreparingLabel.Caption := 'Prompting user about OneDrive...';

      // If installer is running silently, assume Yes
      if WizardSilent() then
      begin 
        Log('Silent install detected, assuming YES.');
        StopOneDrive();
      end
      else
      begin
        case MsgBox('OneDrive might conflict with the installation. Do you want the installer to close OneDrive? It will restart after the installation have completed.', mbConfirmation, MB_YESNOCANCEL) of
          IDYES:
            StopOneDrive();
          IDCANCEL:
            Result := 'User cancelled the installation.';
        end;
      end;
    end;

    // Continue if the user didn't cancel the installer

    if (Result = '') then
    begin

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

        // Clean up any remains from super duper old legacy global injection method
        WizardForm.PreparingLabel.Caption := 'Determining if a legacy injection method is present on the system...';
        Log('Checking for legacy AppInit_DLLs method.');

        AppInitDLLs32    := '';
        AppInitDLLs64    := '';
        AppInitDLLs32Pos := 0;
        AppInitDLLs64Pos := 0;

        RegQueryStringValue  (HKLM32, 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows', 'AppInit_DLLs', AppInitDLLs32);
        if IsWin64 then
        begin
          RegQueryStringValue(HKLM64, 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows', 'AppInit_DLLs', AppInitDLLs64);
        end;
        AppInitDLLs32Pos := Pos('SpecialK', AppInitDLLs32);
        AppInitDLLs64Pos := Pos('SpecialK', AppInitDLLs64);
        
        if (AppInitDLLs32Pos > 0) or (AppInitDLLs64Pos > 0) then
        begin
          WizardForm.PreparingLabel.Caption := 'Running cleanup commands in an elevated process...';
          Log('AppInitDLLs 32-bit : ' + AppInitDLLs32);
          Log('AppInitDLLs 64-bit : ' + AppInitDLLs64);

          ExtractTemporaryFile('Unregister-AppInitDLLs.ps1');
                 
          Log('Calling an elevated Powershell session to run Unregister-AppInitDLLs.ps1');
          ShellExec('RunAs', 'powershell', ExpandConstant('-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "{tmp}\Unregister-AppInitDLLs.ps1"'), '', SW_SHOW, ewWaitUntilTerminated, ResultCode);      

          Sleep(500);

          if ResultCode <> 0 then
          begin
            Log('Failed to run elevated PowerShell session : ' + IntToStr(ResultCode) + ', ' + SysErrorMessage(ResultCode));
          end;
        end;

        ResultCode   := 0;
      end;
      
      // Stop current running global injection
      if (IsGlobalInjectorOrSKIFRunning()) and (FileExists(ExpandConstant('{app}\SKIF.exe'))) then
      begin 
        Log('Stopping Special K Injection Frontend (SKIF) and the global injection service...');
        WizardForm.PreparingLabel.Caption := 'Stopping Special K Injection Frontend (SKIF) and the global injection service...';

        if FileExists(ExpandConstant('{app}\SpecialK32.dll')) or FileExists(ExpandConstant('{app}\SpecialK64.dll')) then
        begin
          Exec(ExpandConstant('{app}\SKIF.exe'), 'Stop Quit', '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
        end
        else
        begin
          Exec(ExpandConstant('{app}\SKIF.exe'), 'Quit', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
        end;

        Sleep(500);
      end;

      
      // If SKIF is still running, force close it
      if (IsSKIFRunning()) then
      begin 
        Log('Forcefully stopping Special K Injection Frontend (SKIF).');
        WizardForm.PreparingLabel.Caption := 'Forcefully stopping Special K Injection Frontend (SKIF)...';

        StopSKIF();

        Sleep(500);
      end;


      // Remove existing DLL files, or rename them if removing fails
      if FileExists(ExpandConstant('{app}\SpecialK32.dll')) or FileExists(ExpandConstant('{app}\SpecialK64.dll')) then
      begin
        Log('Performing final preparations.');

        WizardForm.PreparingLabel.Caption := 'Performing final preparations...';

        //DeleteFile(ExpandConstant('{app}\SpecialK32.old'));
        //DeleteFile(ExpandConstant('{app}\SpecialK64.old'));

        OldDLLsEnding := '_' + GetDateTimeString('yyyymmdd_hhnn', #0, #0) + '.old';

        if not DeleteFile(ExpandConstant('{app}\SpecialK32.dll')) then
        begin
          RenameFile(ExpandConstant('{app}\SpecialK32.dll'), ExpandConstant('{app}\SpecialK32') + OldDLLsEnding);
        end;

        if not DeleteFile(ExpandConstant('{app}\SpecialK64.dll')) then
        begin
          RenameFile(ExpandConstant('{app}\SpecialK64.dll'), ExpandConstant('{app}\SpecialK64') + OldDLLsEnding);
        end;
      end;
    
    end;
  
  except 
    Log('Catastrophic error in PrepareToInstall()!');
    // Surpresses exception when task does not exist or another issue prevents proper lookup
  finally
    WizardForm.PreparingLabel.Visible := WasVisible;
  end;
end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
    DefaultCaption   : String;
    ResultCode       : Integer;
    InstallFolder    : String;
    IsKernelDriver   : Boolean;
    IsSKIFAutoStart  : Boolean;
    PowerShellArgs   : String;
begin
  if CurUninstallStep = usUninstall then
  begin 
    Log('Preparing Uninstall.');

    DefaultCaption := UninstallProgressForm.StatusLabel.Caption;
    InstallFolder := ExpandConstant('{app}');

    if (FileExists(InstallFolder + '\SKIF.exe')) then
    begin 
      Log('SKIF.exe file check : detected');
      UninstallProgressForm.StatusLabel.Caption := 'Stopping SKIF and the global injection service if they are running...';
      Exec(InstallFolder + '\SKIF.exe', 'Stop Quit', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

      Sleep(500);

      if ResultCode <> 0 then
      begin
        Log('Global injection failed to stop : ' + IntToStr(ResultCode) + ', ' + SysErrorMessage(ResultCode));
      end;
    end;
    

    UninstallProgressForm.StatusLabel.Caption := 'Determining if any Special K components requires elevation to remove...';

    IsKernelDriver := IsKernelDriverInstalled();
    if IsKernelDriver then
    begin
      Log('Kernel driver check : installed');
    end;

    IsSKIFAutoStart := IsSKIFAutoStartEnabled();
    if IsSKIFAutoStart then
    begin
      Log('SKIF scheduled task : detected');
    end;

    PowerShellArgs := '';
    ResultCode := 0;

    if IsSKIFAutoStart then
    begin
      PowerShellArgs := PowerShellArgs + 'Unregister-ScheduledTask -TaskName ''SK_InjectLogon'' -Confirm:$false; Remove-Item -Path ([Environment]::GetFolderPath(''MyDocuments'') + ''\My Mods\SpecialK\Servlet\SpecialK.LogOn''); ';
    end;

    if IsKernelDriver then
    begin
      PowerShellArgs := PowerShellArgs + 'Stop-Service -Name ''SK_WinRing0''; sc.exe delete ''SK_WinRing0''; ';
    end;

    if (IsSKIFAutoStart) or (IsKernelDriver) then
    begin
      UninstallProgressForm.StatusLabel.Caption := 'Running cleanup commands in an elevated process...';
      Log('Calling an elevated Powershell session with the following commands : ' + PowerShellArgs );
      ShellExec('RunAs', 'powershell', '-NoProfile -NonInteractive -WindowStyle Hidden -Command "' + PowerShellArgs + '"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      
      Sleep(500);

      if ResultCode <> 0 then
      begin
        Log('Failed to run elevated PowerShell commands : ' + IntToStr(ResultCode) + ', ' + SysErrorMessage(ResultCode));
      end;
    end;

    UninstallProgressForm.StatusLabel.Caption := DefaultCaption;
  end;
end;


[InstallDelete]
Type: files;          Name: "{userprograms}\Startup\SKIM64.lnk"
Type: files;          Name: "{userprograms}\Startup\SKIF.lnk"
Type: files;          Name: "{userprograms}\Startup\SKIFsvc32.lnk"
Type: files;          Name: "{userprograms}\Startup\SKIFsvc64.lnk"
Type: files;          Name: "{app}\SpecialK32-AVX2.dll"
Type: files;          Name: "{app}\SpecialK64-AVX2.dll"
Type: files;          Name: "{app}\SpecialK32.pdb"
Type: files;          Name: "{app}\SpecialK64.pdb"
Type: files;          Name: "{app}\unins00*"
Type: files;          Name: "{app}\Servlet\unins00*"
Type: files;          Name: "{app}\Servlet\driver_install.bat"
Type: files;          Name: "{app}\Servlet\driver_uninstall.bat"
Type: files;          Name: "{app}\Servlet\driver_install.ps1"
Type: files;          Name: "{app}\Servlet\driver_uninstall.ps1"
Type: files;          Name: "{app}\Servlet\disable_logon.bat"
Type: files;          Name: "{app}\Servlet\enable_logon.bat"
Type: files;          Name: "{app}\Servlet\task_eject.bat"


[Registry]
Root: HKCU; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueName: "Special K 32-bit Global Injection Service Host";                 Flags: dontcreatekey uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueName: "Special K 64-bit Global Injection Service Host";                 Flags: dontcreatekey uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueName: "Special K";                                                      Flags: dontcreatekey uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SKIF.exe";     ValueType: string; ValueData: "{app}\{#SpecialKExeName}"; Flags: dontcreatekey uninsdeletekey   createvalueifdoesntexist
Root: HKCU; Subkey: "SOFTWARE\Kaldaien\Special K";                   ValueName: "Path"; ValueType: string; ValueData: "{app}";                    Flags:               uninsdeletevalue createvalueifdoesntexist


[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

; NOTE: When solid compression is enabled, be sure to list your temporary files at (or near) the top of the [Files] section.
; In order to extract an arbitrary file in a solid-compressed installation, Setup must first decompress all prior files (to a temporary buffer in memory).
; This can result in a substantial delay if a number of other files are listed above the specified file in the [Files] section.

; Temporary files that are extracted as needed
Source: "{#RedistDir}\Unregister-AppInitDLLs.ps1";   DestDir: {tmp};            Flags: dontcopy;
Source: "{#AssetsDir}\techno_stargazev2.1loop.mp3";  DestDir: {tmp};            Flags: dontcopy;

; Main Special K files should always be overwritten
Source: "{#SourceDir}\SKIF.exe";                     DestDir: "{app}";          Flags: ignoreversion;                            Check: IsWin64;
Source: "{#SourceDir}\SKIF32.exe";                   DestDir: "{app}";          Flags: ignoreversion;  DestName: "SKIF.exe";     Check: not IsWin64;  
Source: "{#SourceDir}\SpecialK32.dll";               DestDir: "{app}";          Flags: ignoreversion;
Source: "{#SourceDir}\SpecialK32.pdb";               DestDir: "{app}";          Flags: ignoreversion skipifsourcedoesntexist;
Source: "{#SourceDir}\SpecialK64.dll";               DestDir: "{app}";          Flags: ignoreversion;                            Check: IsWin64;
Source: "{#SourceDir}\SpecialK64.pdb";               DestDir: "{app}";          Flags: ignoreversion skipifsourcedoesntexist;    Check: IsWin64;
Source: "{#SourceDir}\Servlet\SKIFsvc64.exe";        DestDir: "{app}\Servlet";  Flags: ignoreversion;                            Check: IsWin64;
Source: "{#SourceDir}\Servlet\*";                    DestDir: "{app}\Servlet";  Flags: ignoreversion;  Excludes: "SKIFsvc64.exe"  
;Source: "{#SourceDir}\SpecialK32-AVX2.dll";          DestDir: "{app}";          Flags: ignoreversion;
;Source: "{#SourceDir}\SpecialK64-AVX2.dll";          DestDir: "{app}";          Flags: ignoreversion;                            Check: IsWin64; 

; Remaining files should only be created if they do not exist already.
; NOTE: This line causes the files included above to be counted twice in DiskSpaceMBLabel
Source: "{#SourceDir}\*";                            DestDir: "{app}";          Flags: onlyifdoesntexist recursesubdirs createallsubdirs;  Excludes: "SKIF.exe,SKIF32.exe,\SpecialK32.dll,\SpecialK32.pdb,\SpecialK64.dll,\SpecialK64.pdb,\Servlet,\SpecialK32-AVX2.dll,\SpecialK64-AVX2.dll" 


[Dirs]
Name: "{app}";          Permissions: users-modify
Name: "{app}\Profiles"


[Tasks]
Name: desktopicon;   Description: "Create &desktop shortcut";    
Name: startmenu;     Description: "Create start menu shortcut";


[Icons]
Name: "{autoprograms}\{#SpecialKName}";    Filename: "{app}\{#SpecialKExeName}";    Check: SwitchHasValue('Shortcuts', 'true', 'true');    Tasks: startmenu
Name:  "{autodesktop}\{#SpecialKName}";    Filename: "{app}\{#SpecialKExeName}";    Check: SwitchHasValue('Shortcuts', 'true', 'true');    Tasks: desktopicon
Name:     "{userdocs}\My Mods\Special K";  Filename: "{app}";


[Run]
; Checked by default

Filename: "{app}\{#SpecialKExeName}";               Description: "{cm:LaunchProgram,{#StringChange(SpecialKName, '&', '&&')}}"; \
  Flags: nowait postinstall runasoriginaluser skipifsilent

Filename: "{#SpecialKHelpURL}";                     Description: "Open the wiki"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

; Unchecked by default

Filename: "{#SpecialKDiscord}";                     Description: "Join the Discord server"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKForum}";                       Description: "Visit the forum"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

Filename: "{#SpecialKPatreon}";                     Description: "Support the project on Patreon"; \
  Flags: shellexec nowait postinstall skipifsilent unchecked

; Start up OneDrive again after installation has succeeded

Filename: "{code:GetOneDrivePath}";                 Description: "Start OneDrive";    Parameters: "/background"; \
  Flags: nowait;      Check: RestartOneDrive;


[UninstallDelete]
Type: files;          Name: "{userprograms}\Startup\SKIM64.lnk"
Type: files;          Name: "{userprograms}\Startup\SKIF.lnk"
Type: files;          Name: "{userprograms}\Startup\SKIFsvc32.lnk"
Type: files;          Name: "{userprograms}\Startup\SKIFsvc64.lnk"
Type: files;          Name: "{app}\SpecialK32.old"
Type: files;          Name: "{app}\SpecialK64.old" 
Type: filesandordirs; Name: "{app}\Drivers\Dbghelp" 
Type: filesandordirs; Name: "{app}\Drivers\WinRing0"
Type: filesandordirs; Name: "{app}\Assets"
Type: filesandordirs; Name: "{app}\Profiles"
Type: filesandordirs; Name: "{app}\Global"
Type: filesandordirs; Name: "{app}\CEGUI"
Type: filesandordirs; Name: "{app}\Drivers"
Type: filesandordirs; Name: "{app}\PlugIns"
Type: filesandordirs; Name: "{app}\Fonts"
Type: filesandordirs; Name: "{app}\ReadMe"
Type: filesandordirs; Name: "{app}\Servlet"
Type: filesandordirs; Name: "{app}\Version"
Type: filesandordirs; Name: "{app}\imgui.ini"
Type: filesandordirs; Name: "{app}\SKIF.ini"
Type: filesandordirs; Name: "{app}\SKIF.log"
Type: filesandordirs; Name: "{app}\patrons.txt"
Type: dirifempty;     Name: "{app}"  
Type: dirifempty;     Name: "{userdocs}\My Mods"

