; -- SpecialK_Shared.iss --
;
; This script holds code shared between Special K scripts.
;
; licensed under MIT
; https://github.com/SpecialKO/Installer/blob/main/LICENSE


; -----------
; SHARED DEFINITIONS
; -----------
#define SpecialKUninstID   "{F4A43527-9457-424A-90A6-17CF02ACF677}"
#define SKIFdrvUninstID    "{A459BBFA-0819-49C4-8BF7-5BDF1559ED0C}"
#define ValvePlugUninstID  "{E100754B-5610-4DA5-A572-B37BE59B0562}"
//#define SpecialKModUninstID "" // Holds AppID for game-specific mods; defined in the separate mod install scripts

; -----------
; SHARED CODE
; -----------
[Code]


// -----------
// Constants
// -----------

const
  IMAGE_FILE_AGGRESIVE_WS_TRIM   = $0010;  // 0x10 (16) - Aggressively trim working set
  IMAGE_FILE_LARGE_ADDRESS_AWARE = $0020;  // 0x20 (32) - App can handle >2gb addresses


// -----------
// Global variables
// -----------

var
  WbemLocator       : Variant;
  WbemServices      : Variant;
  MusicPlayback     : Boolean;
  MusicAvailable    : Boolean;
  LocPLUGroupName   : String;
  LocINTUserName    : String;
  ToggleMusicButton : TNewButton;
  CreditMusicButton : TNewButton;
  OneDriveStopped   : Boolean;
  OneDrivePath      : String;
  SteamStopped      : Boolean;


// -----------
// Imported Win32 functions
// -----------

// If Inno Setup ever becomes native 64-bit, the below rows needs to be changed to SetWindowLongPtrW/GetWindowLongPtrW
function SetWindowLong ( Wnd: HWND;  nIndex: Integer;  dwNewLong: Longint): Longint;  external 'SetWindowLongW@user32.dll stdcall';
function GetWindowLong ( Wnd: HWND;  nIndex: Integer)                     : Longint;  external 'GetWindowLongW@user32.dll stdcall';
//function SetWindowLongPtr (Wnd : HWND;  nIndex: Integer;  dwNewLong: Longint): Longint;  external 'SetWindowLongPtrW@user32.dll stdcall';
//function GetWindowLongPtr (Wnd : HWND;  nIndex: Integer)                     : Longint;  external 'GetWindowLongPtrW@user32.dll stdcall';
function GetWindow     (hWnd: HWND;    uCmd: Cardinal)                    : HWND;     external 'GetWindow@user32.dll stdcall'; 

// Retrieves the calling thread's last-error code value.
function GetLastError                                                     : Cardinal; external 'GetLastError@kernel32.dll stdcall';

// Used to play background music during installation
function mciSendString (lpstrCommand: String; lpstrReturnString: Integer; uReturnLength: Cardinal; hWndCallback: HWND): Cardinal; external 'mciSendStringW@winmm.dll stdcall';


// -----------
// Command line
// -----------

// Used to check for the presence of cmd line switches
function SwitchHasValue(Name: String; Value: String; DefaultValue: String): Boolean;
begin
  Result := CompareText(ExpandConstant('{param:' + Name + '|' + DefaultValue + '}'), Value) = 0;
end;


// -----------
// Windows version helpers
// -----------

function IsWindows10OrLater: Boolean;
begin
  Result := (GetWindowsVersion >= $0A002800);
end;

function IsWindows8OrLater: Boolean;
begin
  Result := (GetWindowsVersion >= $06020000);
end;


// -----------
// WMI
// -----------

function InitializeWMI(): Boolean;
begin
  if VarIsEmpty(WbemLocator) or VarIsEmpty(WbemServices) then
  begin
    try
      if VarIsEmpty(WbemLocator) then
      begin
        Log('Creating an IDispatch based COM Automation object...');
        WbemLocator   := CreateOleObject('WbemScripting.SWbemLocator');
      end;

      if not VarIsEmpty(WbemLocator) and VarIsEmpty(WbemServices) then
      begin
        Log('Connecting to the local root\CIMV2 WMI namespace...');
        WbemServices  := WbemLocator.ConnectServer('', 'root\CIMV2'); // Let's not include 'localhost'
      end;

      if not VarIsEmpty(WbemLocator) and not VarIsEmpty(WbemServices) then
      begin       
        Result := true;
      end;
    except 
      Log('Catastrophic error in InitializeWMI() !');
      // Surpresses exception when an issue prevents proper lookup
    end;
  end
  else
  begin
    Result := true;
  end;
end;


// -----------
// Music playback
// -----------

// This is called by the OnClick handler of a button
procedure ToggleButtonClick(Sender: TObject);
begin
  if MusicAvailable then
  begin
    if MusicPlayback then
    begin
      mciSendString('stop soundbg', 0, 0, 0);
      MusicPlayback := false;
      ToggleMusicButton.Caption := 'Play Music';
    end
    else
    begin
      mciSendString('play soundbg repeat', 0, 0, 0);
      MusicPlayback := true;
      ToggleMusicButton.Caption := 'Stop Music';
    end;
  end;
end;

// This is called by the OnClick handler of a button
procedure CreditButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('', 'https://opengameart.org/content/stargazer', '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

function InitializeMusicPlayback(FileName: String): Boolean;
begin
  Result := false;

  if not WizardSilent() then
  begin 
    // Some nice background tunes
    Log('Preparing music components.');
    try
      MusicPlayback  := false;
      MusicAvailable := false;
      ExtractTemporaryFile(FileName);

      // Open the track
      if (0 = mciSendString(ExpandConstant('open "{tmp}/' + FileName + '" alias soundbg'), 0, 0, 0)) then
      begin

        // Adjust the volume
        if (0 = mciSendString('setaudio soundbg volume to 125', 0, 0, 0)) then
        begin

          // Create the UI elements
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

          // If everything worked so far
          MusicAvailable := true;
          Result := true;
        end;
      end;
    except
      Log('Failed initializing music components: ' + AddPeriod(GetExceptionMessage));
    end;
  end;
end;

function DeinitializeMusicPlayback: Boolean;
begin
  Result := false;

  if not WizardSilent() and MusicAvailable then
  begin 
    Log('Cleaning up music components.');
    try
      if MusicPlayback then
      begin
        // Stop music playback if it's currently playing
        mciSendString('stop soundbg', 0, 0, 0);
        MusicPlayback := false;
      end;
      // Close the MCI device
      mciSendString('close all', 0, 0, 0);
      Result := true;
    except
      Log('Failed deinitializing music components: ' + AddPeriod(GetExceptionMessage));
    end;
  end;
end;


// -----------
// Steam / Valve
// -----------

// Parses Valve Data Format (.VDF and .ACF) files
// Based on StackOverflow: https://stackoverflow.com/a/37019690/15133327
// Created by: https://stackoverflow.com/users/850848/martin-prikryl
// Licensed under CC BY-SA 3.0, https://creativecommons.org/licenses/by-sa/3.0/
function GetVDFKeyValues(FileName: String; Key: String; var Values: TArrayOfString): Boolean;
var
  I:                Integer;
  P:                Integer;
  Lines:            TArrayOfString;
  Line:             String;
  LineKey:          String;
  LineValue:        String;
  Count:            Integer;
begin
  Result := LoadStringsFromFile(FileName, Lines);
  Count  := 0;

  for I := 0 to GetArrayLength(Lines) - 1 do
  begin
    Line := Trim(Lines[I]);
    if Copy(Line, 1, 1) = '"' then
    begin
      Delete(Line, 1, 1);
      P := Pos('"', Line);
      if P > 0 then
      begin
        LineKey := Trim(Copy(Line, 1, P - 1));
        Delete(Line, 1, P);
        Line := Trim(Line);
        //Log(Format('Found VDF key "%s"', [LineKey]));

        if (CompareText(
              Copy(LineKey, 1, Length(Key)),
              Key) = 0) and
           (Line[1] = '"') then
        begin
          Delete(Line, 1, 1);
          P := Pos('"', Line);
          if P > 0 then
          begin
            LineValue := Trim(Copy(Line, 1, P - 1));
            StringChange(LineValue, '\\', '\');
            //Log(Format('Found VDF value: %s', [LineValue]));
            Inc(Count);
            SetArrayLength(Values, Count);
            Values[Count - 1] := LineValue;
          end;
        end;
      end;
    end;
  end;
end;

// Parses Valve Data Format (.VDF and .ACF) files
// Based on StackOverflow: https://stackoverflow.com/a/37019690/15133327
// Created by: https://stackoverflow.com/users/850848/martin-prikryl
// Licensed under CC BY-SA 3.0, https://creativecommons.org/licenses/by-sa/3.0/
function GetVDFKeyValue(FileName: String; Key: String; var Value: String): Boolean;
var
  I:                Integer;
  P:                Integer;
  Lines:            TArrayOfString;
  Line:             String;
  LineKey:          String;
  LineValue:        String;
  Count:            Integer;
begin
  Result := LoadStringsFromFile(FileName, Lines);
  Count  := 0;

  for I := 0 to GetArrayLength(Lines) - 1 do
  begin
    Line := Trim(Lines[I]);
    if Copy(Line, 1, 1) = '"' then
    begin
      Delete(Line, 1, 1);
      P := Pos('"', Line);
      if P > 0 then
      begin
        LineKey := Trim(Copy(Line, 1, P - 1));
        Delete(Line, 1, P);
        Line := Trim(Line);
        //Log(Format('Found VDF key "%s"', [LineKey]));

        if (CompareText(
              Copy(LineKey, 1, Length(Key)),
              Key) = 0) and
           (Line[1] = '"') then
        begin
          Delete(Line, 1, 1);
          P := Pos('"', Line);
          if P > 0 then
          begin
            LineValue := Trim(Copy(Line, 1, P - 1));
            StringChange(LineValue, '\\', '\');
            //Log(Format('Found VDF value: %s', [LineValue]));
            Value := LineValue;
            break;
          end;
        end;
      end;
    end;
  end;
end;

// Detects and returns the install folder of a Steam game given its AppID
// This is called from [Setup] to dynamically set the install folder
//    0 = Get the root Steam install folder
function GetSteamInstallFolder(AppID: String): String;
var
  I:                Integer;
  Libraries:        TArrayOfString;
  Library:          String;
  SteamInstallPath: String;
  SteamLibVDFPath:  String;
  GameInstallPath:  String;
  GameInstallDir:   String;
begin
  SteamInstallPath := ExpandConstant('{reg:HKLM32\SOFTWARE\Valve\Steam,InstallPath|{commonpf32}\Steam}');

  if DirExists(SteamInstallPath) then
  begin
    Log(Format('Found Steam folder: %s', [SteamInstallPath]));

    if SameText (AppId, '0') then
    begin
      Log('AppID 0 was given, returning base Steam folder.');
      Result := SteamInstallPath;
    end
    else
    begin
      if FileExists(SteamInstallPath + '\config\libraryfolders.vdf') then
        SteamLibVDFPath := SteamInstallPath + '\config\libraryfolders.vdf'     // Modern location
      else
        SteamLibVDFPath := SteamInstallPath + '\steamapps\libraryfolders.vdf'; // Legacy location

      if GetVDFKeyValues(SteamLibVDFPath, 'path', Libraries) then
      begin
        for I := 0 to GetArrayLength(Libraries) - 1 do
        begin
          Library := Libraries[I];
          GameInstallPath := Library + '\steamapps\common\';

          if FileExists(Library + '\steamapps\appmanifest_' + AppID + '.acf') and
             GetVDFKeyValue(Library + '\steamapps\appmanifest_' + AppID + '.acf', 'installdir', GameInstallDir) then
          begin
            if DirExists(GameInstallPath + GameInstallDir) then
            begin
              Log(Format('Found game folder: %s', [GameInstallPath + GameInstallDir]));
              Result := GameInstallPath + GameInstallDir;
              break;
            end;
          end;
        end;
      end;
    end
  end; 
end;

// Checks if Steam is currently running
function IsSteamRunning(): Boolean;
var
  WbemObjectSet : Variant;
    
begin
  try
    if InitializeWMI() then
    begin
      WbemObjectSet := WbemServices.ExecQuery('SELECT Name FROM Win32_Process WHERE (Name = "Steam.exe")');

      if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
      begin      
        Result := true;
      end;
    end;

  except 
    Log('Catastrophic error in IsSteamRunning()!');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;

// Stops the Steam client
function StopSteam: Boolean;
var
  ResultCode : Integer;
begin
  Log('Shutting down Steam...');
  SteamStopped := ShellExec('', 'steam://exit', '', '', SW_HIDE, ewNoWait, ResultCode);
  Result := SteamStopped;
end;

// Restarts the Steam client if it was stopped by us
function RestartSteam: Boolean;
var
  ResultCode : Integer;
begin
  if SteamStopped then
  begin
    Log('Restarting Steam...');
    Result := ShellExec('', 'steam://', '', '', SW_HIDE, ewNoWait, ResultCode);
  end;
end;



// -----------
// LAAwareness
// -----------

// This is a helper function to convert from Unicode string to Ansi string as
// byte array comparisons with data read using TFileStream otherwise break
// See https://stackoverflow.com/a/43161113/15133327 for more information
// 
// From StackOverflow: https://stackoverflow.com/q/31228103/15133327
// Created by: https://stackoverflow.com/users/3992415/leduc
// Licensed under CC BY-SA 4.0, https://creativecommons.org/licenses/by-sa/4.0/
function BufferToAnsi(const Buffer: String): AnsiString;
var
  W: Word;
  I: Integer;
begin
  SetLength(Result, Length(Buffer) * 2);
  for I := 1 to Length(Buffer) do
  begin
    W := Ord(Buffer[I]);
    Result[(I * 2)]     := Chr(W shr 8); // high byte
    Result[(I * 2) - 1] := Chr(Byte(W)); // low byte
  end;
end;

// Sets IMAGE_FILE_LARGE_ADDRESS_AWARE flag on an executable
// IMAGE_FILE_LARGE_ADDRESS_AWARE = App can handle >2gb addresses
function MakeExecutableLAAware(FileName: String): Boolean;
var
  Stream:    TFileStream;
  Buffer:    String;
  BufferH:   String;
  AnsiStr:   AnsiString;
  HeaderPos: Longint;
  Error:     Cardinal;
  Flag:      Integer;
begin
  Log(Format('Checking LAA on %s', [FileName]));

  if FileExists(FileName) then
  begin
    try
      // Open the file for reading
      Stream := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
      SetLength(Buffer,  1);
      SetLength(BufferH, 2);

      // Detect if we are in an executable
      Stream.Seek(0, soFromBeginning);
      Stream.ReadBuffer(Buffer, 1);
      AnsiStr := BufferToAnsi(Buffer);
      //Log(Format('Byte 01: %2.2x (%s)', [Ord(AnsiStr[1]), AnsiStr[1]]));

      if AnsiStr[1] = #$4D then // M
      begin
        Stream.ReadBuffer(Buffer, 1);
        AnsiStr := BufferToAnsi(Buffer);

        if AnsiStr[1] = #$5A then // Z
        begin
          // We are in an executable!

          // Look up the offset for the PE header
          Stream.Seek(60, soFromBeginning);
          Stream.ReadBuffer(BufferH, 2);
          HeaderPos := Ord(BufferH[1]);
          Log(Format('PE header offset: %d (dec), %x (hex)', [HeaderPos, HeaderPos]));

          // Seek to the offset we found
          Stream.Seek(HeaderPos, soFromBeginning);
          Stream.ReadBuffer(Buffer, 1);
          AnsiStr := BufferToAnsi(Buffer);

          if AnsiStr[1] = #$50 then // P(ortable)
          begin
            Stream.ReadBuffer(Buffer, 1);
            AnsiStr := BufferToAnsi(Buffer);

            if AnsiStr[1] = #$45 then // E(xecutable)
            begin
              // We have located the PE header!

              Stream.Seek(20, soFromCurrent); // Move the cursor 20 steps forward
              Stream.ReadBuffer(Buffer, 1);
              AnsiStr := BufferToAnsi(Buffer);

              Flag := Ord(AnsiStr[1]);
              Log(Format('Got flag: %d', [Flag]));

              if (Flag and IMAGE_FILE_LARGE_ADDRESS_AWARE) = IMAGE_FILE_LARGE_ADDRESS_AWARE then
              begin // LAAware
                Log('Executable is LAAware, nothing to do.');
                Result := True;
              end
              else // LAUnaware
              begin
                Log('Executable is LAUnware, patching...');
                if FileCopy(FileName, ChangeFileExt(FileName, '_LAUnaware.bak'), False) then
                begin
                  Stream.Seek(-1, soFromCurrent); // Move the cursor back one step

                  Flag := (Flag or IMAGE_FILE_LARGE_ADDRESS_AWARE);
                  Log(Format('New flag: %d', [Flag]));

                  Stream.WriteBuffer(Chr(Flag), 1); // IntToStr() results in incorrect data being written, but Chr() writes the right one
                  Log('Executable was patched successfully!');
                  Result := True;
                end
                else
                begin
                  Error := GetLastError;
                  Log(Format('Copying "%s" to "%s" failed with code %d (0x%x) - %s', [
                      FileName, FileName + '_LAUnaware.bak', Error, Error, SysErrorMessage(Error)]));
                end;
              end;
            end;
          end;
        end;
      end;
    except
      Error := GetLastError;
      Log(Format('Operating on "%s" failed with code %d (0x%x) - %s', [
          FileName, Error, Error, SysErrorMessage(Error)]));
    finally
      Stream.Free;
    end;
  end
  else
  begin
    Log('The installer cannot find the file specified.');
  end;
end;


// -----------
// PresentMon
// -----------

// Checks if the required permissions exists for PresentMon stats
function IsInteractiveInPLU(): Boolean;
var
  WbemObjectSet : Variant;
  IsMember      : Boolean;
  ComputerName  : String;
  I             : Integer;      
begin
  try
    (*
      PS C:\> Get-WmiObject -Query "SELECT * FROM Win32_Group WHERE (LocalAccount = True) AND (SID = 'S-1-5-32-559')" | fl

      Caption : <ComputerName>\Performance Log Users
      Domain  : <ComputerName>
      Name    : Performance Log Users
      SID     : S-1-5-32-559

      PS C:\> Get-WMIObject -Query 'ASSOCIATORS OF {Win32_Group.Domain="<ComputerName>",Name="Performance Log Users"} WHERE assocClass=Win32_GroupUser Role=GroupComponent ResultRole=PartComponent' | fl

      Caption : <ComputerName>\INTERACTIVE
      Domain  : <ComputerName>
      Name    : INTERACTIVE
      SID     : S-1-5-4
    *)

    if InitializeWMI() then
    begin
      Log('Attempting to retrieve PLU membership...');

      // Retrieve the localized name of the PLU group  
      WbemObjectSet      := WbemServices.ExecQuery('SELECT * FROM Win32_Group WHERE (LocalAccount = True) AND (SID = "S-1-5-32-559")');

      if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
      begin
        ComputerName    := WbemObjectSet.ItemIndex(0).Domain;
        LocPLUGroupName := WbemObjectSet.ItemIndex(0).Name;
        
        //MsgBox(ComputerName,    mbInformation, MB_OK);
        //MsgBox(LocPLUGroupName, mbInformation, MB_OK);

        if not VarIsNull(ComputerName) and not VarIsNull(LocPLUGroupName) then
        begin
          WbemObjectSet := Null;

          // Retrieve members of the local PLU group
          WbemObjectSet := WbemServices.ExecQuery('ASSOCIATORS OF {Win32_Group.Domain="' + ComputerName + '",Name="' + LocPLUGroupName + '"} WHERE assocClass=Win32_GroupUser Role=GroupComponent ResultRole=PartComponent');
          if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
          begin
            for I := 0 to WbemObjectSet.Count - 1 do
            begin
              // Check if one of the members is NT AUTHORITY\Interactive 
              if (WbemObjectSet.ItemIndex(I).SID = 'S-1-5-4') then
              begin
                IsMember := True;
              end;
            end;
          end;
        end;

        // If Interactive was not a member, we still need to retrieve the localized username
        if not IsMember then
        begin
          Log('Attempting to retrieve localized username for NT AUTHORITY\Interactive...');
          WbemObjectSet := Null;
            
          WbemObjectSet      := WbemServices.ExecQuery('SELECT * FROM Win32_SystemAccount WHERE (LocalAccount = True) AND (SID = "S-1-5-4")');
          if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
          begin
            LocINTUserName := WbemObjectSet.ItemIndex(0).Name;
          end;
        end;

        Result := IsMember;
      end;

    end;

  except 
    Log('Catastrophic error in IsInteractiveInPLU() !');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;


// -----------
// Special K / SKIF / Injection Service
// -----------

// Detects and returns the install folder of Special K
// This is called from [Setup] to dynamically set the install folder
function GetSpecialKInstallFolder(SKInstallPath: String): String;
begin
  if not RegQueryStringValue(HKLM64, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#SpecialKUninstID}_is1', 'InstallLocation', SKInstallPath) then
  begin
    SKInstallPath := ExpandConstant('{reg:HKCU\SOFTWARE\Kaldaien\Special K,Path|{autopf64}\Special K}');
  end;

  if DirExists(SKInstallPath) then
  begin
    Log(Format('Found Special K folder: %s', [SKInstallPath]));
  end
  else
  begin
    Log(Format('Failed to locate Special K folder, using fallback: %s', [SKInstallPath]));
  end;

  Result := SKInstallPath; 
end;

// Checks if the injector service of Special K or SKIF is running
function IsSKIForSvcRunning(): Boolean;
var
  WbemObjectSet : Variant;
  InstallFolder : String;
    
begin
  InstallFolder := ExtractFileName(RemoveBackslashUnlessRoot(ExpandConstant('{app}')));

  if Length(InstallFolder) = 0 then
  begin
    InstallFolder := 'SpecialK';
  end; 

  try

    if InitializeWMI() then
    begin
      WbemObjectSet := WbemServices.ExecQuery('SELECT Name FROM Win32_Process WHERE (Name = "SKIFsvc.exe" OR Name = "SKIFsvc32.exe" OR Name = "SKIFsvc64.exe" OR Name = "SKIF.exe") OR ((Name = "rundll32.exe") AND (CommandLine LIKE "%SpecialK%" OR CommandLine LIKE "%Special K%" OR CommandLine LIKE "%' + InstallFolder + '%" OR ExecutablePath LIKE "%SpecialK%" OR ExecutablePath LIKE "%Special K%" OR ExecutablePath LIKE "%' + InstallFolder + '%"))');

      if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
      begin      
        Result := true;
      end;
    end;

  except 
    Log('Catastrophic error in IsSKIForSvcRunning()!');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;

// Checks if SKIF is currently running
function IsSKIFRunning(): Boolean;
var
  WbemObjectSet : Variant;
    
begin
  try
    if InitializeWMI() then
    begin
      WbemObjectSet := WbemServices.ExecQuery('SELECT Name FROM Win32_Process WHERE (Name = "SKIF.exe")');

      if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
      begin      
        Result := true;
      end;
    end;

  except 
    Log('Catastrophic error in IsSKIFRunning()!');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;

// Forcefully stops SKIF and the service components
function ForceStopSKIFandSvc(): Integer;
begin
  try
    Exec('taskkill.exe', '/F /IM SKIF.exe', '', SW_HIDE, ewNoWait, Result);

    // Not safe to do as it seems to get the service stuck in an unstartable state
    //Exec('taskkill.exe', '/F /IM SKIFsvc32.exe', '', SW_HIDE, ewNoWait, Result);
    //Exec('taskkill.exe', '/F /IM SKIFsvc64.exe', '', SW_HIDE, ewNoWait, Result);
  except 
    Log('Catastrophic error in ForceStopSKIFandSvc()!');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;

// Checks if SKIF is set up to start automatically with Windows
function IsSKIFAutoStartEnabled(): Boolean;
var
  TaskService:    Variant;
  RootFolder:     Variant;
  TaskCollection: Variant;
  I:              Integer;
begin
  try
    TaskService := CreateOleObject('Schedule.Service');
    TaskService.Connect();

    if TaskService.Connected then
    begin
      RootFolder     := TaskService.GetFolder('\');
      TaskCollection :=  RootFolder.GetTasks(0);
      if not VarIsNull(TaskCollection) and (TaskCollection.Count > 0) then
      begin
        for I := 1 to TaskCollection.Count - 1 do // Item enumeration starts at 1 apparently
        begin
          if not VarIsNull(TaskCollection.Item(I)) and (TaskCollection.Item(I).Name = 'SK_InjectLogon') then
          begin
            Result := true;
          end; 
        end;
      end;
    end;
  except 
    Log('Catastrophic error in IsSKIFAutoStartEnabled() !');
    // Surpresses exception when task does not exist or another issue prevents proper lookup
  end;
end;


// -----------
// OneDrive
// -----------

// Checks if OneDrive is currently running
function IsOneDriveRunning(): Boolean;
var
  WbemObjectSet : Variant;
  Path : String;
    
begin
  try
    if InitializeWMI() then
    begin
      WbemObjectSet := WbemServices.ExecQuery('SELECT ExecutablePath FROM Win32_Process WHERE (Name = "OneDrive.exe")');

      if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
      begin
        Path := WbemObjectSet.ItemIndex(0).ExecutablePath;
        if Length(Path) > 0 then
        begin
          OneDrivePath := Path;
          Result := true;
        end;
      end;
    end;
  except 
    Log('Catastrophic error in IsOneDriveRunning()!');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;

// Stops OneDrive
function StopOneDrive(): Integer;
begin
  try
    Exec('taskkill.exe', '/F /IM OneDrive.exe', '', SW_HIDE, ewNoWait, Result);
    OneDriveStopped := True;
  except 
    Log('Catastrophic error in StopOneDrive()!');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;

// Retrieves the path of OneDrive
function GetOneDrivePath(Value: string): string;
begin
  Result := OneDrivePath;
end;

// Returns TRUE if OneDrive was stopped during installation
function RestartOneDrive: Boolean;
begin
  Result := OneDriveStopped;
end;


// -----------
// Kernel Driver
// -----------

// Checks if the WinRing0 kernel driver is installed
function IsKernelDriverInstalled(): Boolean;
var
  WbemObjectSet : Variant;
  //InstallFolder : String;
    
begin
  //InstallFolder := ExtractFileName(RemoveBackslashUnlessRoot(ExpandConstant('{app}')));

  //if Length(InstallFolder) = 0 then
  //begin
  //  InstallFolder := 'SpecialK';
  //end;

  try
    if InitializeWMI() then
    begin
      WbemObjectSet := WbemServices.ExecQuery('SELECT PathName FROM Win32_SystemDriver WHERE Name = "SK_WinRing0"'); //  AND (PathName LIKE "%SpecialK%" OR PathName LIKE "%Special K%" OR PathName LIKE "%' + InstallFolder + '%")

      if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
      begin       
        Result := true;
      end;
    end;

  except 
    Log('Catastrophic error in IsKernelDriverInstalled() !');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;


// -----------
// Check if contants can be expanded successfully
// -----------
function TryExpandConstant(ConstantFolder: String): Boolean;
var
  Folder: String;

begin
  Result := false;

  try
    // Test if we can expand the userdocs constant and if it exists
    Folder := ExpandConstant('{' + ConstantFolder + '}');
    if DirExists(Folder) then
    begin
      Result := true;
    end;
  except
    Log('Failed to expand constant: ' + AddPeriod(GetExceptionMessage));
  end;
end;



// -----------
// Procedure to extract a ZIP archive
// -----------
// CC BY-SA 4.0: https://stackoverflow.com/a/40706549/15133327
const
  SHCONTCH_NOPROGRESSBOX = 4;
  SHCONTCH_RESPONDYESTOALL = 16;

procedure UnZip(ZipPath, TargetPath: string); 
var
  Shell: Variant;
  ZipFile: Variant;
  TargetFolder: Variant;
begin
  Shell := CreateOleObject('Shell.Application');

  ZipFile := Shell.NameSpace(ZipPath);
  if VarIsClear(ZipFile) then
    RaiseException(
      Format('ZIP file "%s" does not exist or cannot be opened', [ZipPath]));

  TargetFolder := Shell.NameSpace(TargetPath);
  if VarIsClear(TargetFolder) then
    RaiseException(Format('Target path "%s" does not exist', [TargetPath]));

  TargetFolder.CopyHere(
    ZipFile.Items, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
end;


[Setup]
; Required as otherwise the file cannot be compiled