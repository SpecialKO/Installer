; -- SpecialK_Shared.iss --
;
; This script holds code shared between Special K scripts.
;
; licensed under MIT
; https://github.com/SpecialKO/Installer/blob/main/LICENSE


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
  LocPLUGroupName   : String;
  LocINTUserName    : String;
  ToggleMusicButton : TNewButton;
  CreditMusicButton : TNewButton;
  OneDriveStopped   : Boolean;
  OneDrivePath      : String;


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
function mciSendString(lpstrCommand: String; lpstrReturnString: Integer; uReturnLength: Cardinal; hWndCallback: HWND): Cardinal; external 'mciSendStringW@winmm.dll stdcall';


// -----------
// Command line
// -----------

// Used to check for the presence of cmd line switches
function SwitchHasValue(Name: string; Value: string; DefaultValue: string): Boolean;
begin
  Result := CompareText(ExpandConstant('{param:' + Name + '|' + DefaultValue + '}'), Value) = 0;
end;


// -----------
// Music playback
// -----------

// This is called by the OnClick handler of a button
procedure ToggleButtonClick(Sender: TObject);
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

// This is called by the OnClick handler of a button
procedure CreditButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('', 'https://opengameart.org/content/stargazer', '', '', SW_SHOW, ewNoWait, ErrorCode);
end;


// -----------
// Valve Data Format (.VDF and .ACF) handlers
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
  end; 
end;

// Detects and returns the install folder of Special K
// This is called from [Setup] to dynamically set the install folder
function GetSpecialKInstallFolder(SKInstallPath: String): String;
//var
//  SKInstallPath:    String;
begin
  SKInstallPath := ExpandConstant('{reg:HKCU\SOFTWARE\Kaldaien\Special K,Path|{commonpf64}\Special K}');

  if DirExists(SKInstallPath) then
  begin
    Log(Format('Found Special K folder: %s', [SKInstallPath]));
    Result := SKInstallPath;
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
        WbemObjectSet := Null;
          
        WbemObjectSet      := WbemServices.ExecQuery('SELECT * FROM Win32_SystemAccount WHERE (LocalAccount = True) AND (SID = "S-1-5-4")');
        if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
        begin
          LocINTUserName := WbemObjectSet.ItemIndex(0).Name;
        end;
      end;

      Result := IsMember;
    end;

  except 
    Log('Catastrophic error in IsInteractiveInPLU() !');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;


// -----------
// SKIF and Injection Service
// -----------

// Checks if the global injector service of Special K or SKIF is running
function IsGlobalInjectorOrSKIFRunning(): Boolean;
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
    WbemObjectSet := WbemServices.ExecQuery('SELECT Name FROM Win32_Process WHERE (Name = "SKIFsvc.exe" OR Name = "SKIFsvc32.exe" OR Name = "SKIFsvc64.exe" OR Name = "SKIF.exe") OR ((Name = "rundll32.exe") AND (CommandLine LIKE "%SpecialK%" OR CommandLine LIKE "%Special K%" OR CommandLine LIKE "%' + InstallFolder + '%" OR ExecutablePath LIKE "%SpecialK%" OR ExecutablePath LIKE "%Special K%" OR ExecutablePath LIKE "%' + InstallFolder + '%"))');

    if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
    begin      
      Result := true;
    end;

  except 
    Log('Catastrophic error in IsGlobalInjectorOrSKIFRunning()!');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;


// Checks if SKIF is currently running
function IsSKIFRunning(): Boolean;
var
  WbemObjectSet : Variant;
    
begin
  try
    WbemObjectSet := WbemServices.ExecQuery('SELECT Name FROM Win32_Process WHERE (Name = "SKIF.exe")');

    if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
    begin      
      Result := true;
    end;

  except 
    Log('Catastrophic error in IsSKIFRunning()!');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;

// Stops SKIF
function StopSKIF(): Integer;
begin
  try
    Exec('taskkill.exe', '/F /IM SKIF.exe', '', SW_HIDE, ewNoWait, Result);
  except 
    Log('Catastrophic error in StopSKIF()!');
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
  WbemLocator   : Variant;
  WbemServices  : Variant;
  WbemObjectSet : Variant;
  InstallFolder : String;
    
begin
  InstallFolder := ExtractFileName(RemoveBackslashUnlessRoot(ExpandConstant('{app}')));

  if Length(InstallFolder) = 0 then
  begin
    InstallFolder := 'SpecialK';
  end;  

  try
    WbemLocator   := CreateOleObject('WbemScripting.SWbemLocator');
    WbemServices  := WbemLocator.ConnectServer('localhost', 'root\CIMV2');
    WbemObjectSet := WbemServices.ExecQuery('SELECT PathName FROM Win32_SystemDriver WHERE Name = "SK_WinRing0"'); //  AND (PathName LIKE "%SpecialK%" OR PathName LIKE "%Special K%" OR PathName LIKE "%' + InstallFolder + '%")

    if not VarIsNull(WbemObjectSet) and (WbemObjectSet.Count > 0) then
    begin       
      Result := true;
    end;

  except 
    Log('Catastrophic error in IsKernelDriverInstalled() !');
    // Surpresses exception when an issue prevents proper lookup
  end;
end;


[Setup]
; Required as otherwise the file cannot be compiled