#define MyAppName "PyColorToggle-HDR-SDR"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "anish7m@github.com"
#define MyAppExeName "PyColorToggle-HDR-SDR.exe"
#define MyAppDataDirName "PyAutoActions"
#define MySettingsRegistryKey "Software\7gxycn08@Github\PyAutoActions"
#define MyLegacyStartupShortcutName "PyAutoActions.lnk"
#define MyUninstallRegistryKey "Software\Microsoft\Windows\CurrentVersion\Uninstall\{D83D3A7A-A715-40E9-94F5-3F5C1B07E2EF}_is1"

[Setup]
AppId={{D83D3A7A-A715-40E9-94F5-3F5C1B07E2EF}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={commonpf64}\{#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=LICENSE
OutputDir=installer-dist
OutputBaseFilename=PyColorToggle-HDR-SDR-x64-{#MyAppVersion}
SetupIconFile=Resources\main.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
UninstallDisplayIcon={app}\{#MyAppExeName}
MinVersion=10.0.22000
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "dist\PyColorToggle-HDR-SDR\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
Type: files; Name: "{userstartup}\{#MyAppName}.lnk"
Type: files; Name: "{commonstartup}\{#MyAppName}.lnk"
Type: files; Name: "{userstartup}\{#MyLegacyStartupShortcutName}"
Type: files; Name: "{commonstartup}\{#MyLegacyStartupShortcutName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent

[Code]
var
  RemoveApplicationSettings: Boolean;

function StripQuotes(Value: string): string;
begin
  Result := Value;

  if (Length(Result) >= 2) and (Copy(Result, 1, 1) = '"') and (Copy(Result, Length(Result), 1) = '"') then
  begin
    Result := Copy(Result, 2, Length(Result) - 2);
  end;
end;

function GetInstalledUninstaller(var UninstallerPath: string): Boolean;
begin
  Result :=
    RegQueryStringValue(HKLM64, '{#MyUninstallRegistryKey}', 'UninstallString', UninstallerPath) or
    RegQueryStringValue(HKLM, '{#MyUninstallRegistryKey}', 'UninstallString', UninstallerPath) or
    RegQueryStringValue(HKCU, '{#MyUninstallRegistryKey}', 'UninstallString', UninstallerPath);

  if Result then
  begin
    UninstallerPath := StripQuotes(UninstallerPath);
    Result := FileExists(UninstallerPath);
  end;
end;

function IsProcessRunning(FileName: string): Boolean;
var
  WMILocator: Variant;
  WMIService: Variant;
  Processes: Variant;
begin
  Result := False;

  try
    WMILocator := CreateOleObject('WbemScripting.SWbemLocator');
    WMIService := WMILocator.ConnectServer('.', 'root\CIMV2');
    Processes := WMIService.ExecQuery('SELECT ProcessId FROM Win32_Process WHERE Name = "' + FileName + '"');
    Result := Processes.Count > 0;
  except
    Result := False;
  end;
end;

function InitializeSetup(): Boolean;
var
  UninstallerPath: string;
  UninstallResult: Integer;
begin
  Result := True;

  if not GetInstalledUninstaller(UninstallerPath) then
  begin
    Exit;
  end;

  if MsgBox(
    '{#MyAppName} is already installed.' + #13#10 + #13#10 +
    'The current installation must be uninstalled first before installing this version.' + #13#10 + #13#10 +
    'Do you want to continue?',
    mbConfirmation,
    MB_YESNO
  ) <> IDYES then
  begin
    Result := False;
    Exit;
  end;

  if IsProcessRunning('{#MyAppExeName}') then
  begin
    MsgBox(
      '{#MyAppName} is currently running.' + #13#10 + #13#10 +
      'Please exit the program from the tray icon, then run setup again.',
      mbInformation,
      MB_OK
    );
    Result := False;
    Exit;
  end;

  if not Exec(UninstallerPath, '/NORESTART', '', SW_SHOW, ewWaitUntilTerminated, UninstallResult) then
  begin
    MsgBox(
      'Setup could not start the existing uninstaller.' + #13#10 + #13#10 +
      'Please uninstall {#MyAppName} manually, then run setup again.',
      mbError,
      MB_OK
    );
    Result := False;
    Exit;
  end;

  if UninstallResult <> 0 then
  begin
    MsgBox(
      'The existing uninstall was canceled or did not complete.' + #13#10 + #13#10 +
      'Please complete the uninstall, then run setup again.',
      mbInformation,
      MB_OK
    );
    Result := False;
    Exit;
  end;

  if GetInstalledUninstaller(UninstallerPath) then
  begin
    MsgBox(
      'The existing installation was not fully removed.' + #13#10 + #13#10 +
      'Please complete the uninstall, then run setup again.',
      mbInformation,
      MB_OK
    );
    Result := False;
  end;
end;

function InitializeUninstall(): Boolean;
var
  SettingsChoice: Integer;
begin
  Result := True;
  RemoveApplicationSettings := False;

  if IsProcessRunning('{#MyAppExeName}') then
  begin
    MsgBox(
      '{#MyAppName} is currently running.' + #13#10 + #13#10 +
      'Please exit the program from the tray icon, then run uninstall again.',
      mbInformation,
      MB_OK
    );
    Result := False;
    Exit;
  end;

  SettingsChoice := MsgBox(
    'Do you want to remove application settings too?' + #13#10 + #13#10 +
    'Choose Yes to remove saved settings and app data.' + #13#10 +
    'Choose No to keep them for a reinstall.',
    mbConfirmation,
    MB_YESNOCANCEL
  );

  if SettingsChoice = IDCANCEL then
  begin
    Result := False;
    Exit;
  end;

  RemoveApplicationSettings := SettingsChoice = IDYES;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if (CurUninstallStep = usPostUninstall) and RemoveApplicationSettings then
  begin
    DelTree(ExpandConstant('{userappdata}\{#MyAppDataDirName}'), True, True, True);
    RegDeleteKeyIncludingSubkeys(HKEY_CURRENT_USER, '{#MySettingsRegistryKey}');
  end;
end;
