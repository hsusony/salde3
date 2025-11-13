; Script generated for 9Soft Sales Management System
; November 2025 - Version 3.0.0

#define MyAppName "نظام إدارة المبيعات - 9Soft"
#define MyAppVersion "3.0.0"
#define MyAppPublisher "9Soft"
#define MyAppURL "http://www.9soft.com/"
#define MyAppExeName "sales_management_system.exe"
#define MyAppAssocName "SalesSystem File"
#define MyAppAssocExt ".sales"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
AppId={{9SOFT-SALES-SYSTEM-2025}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\9Soft\SalesSystem
DisableProgramGroupPage=yes
LicenseFile=LICENSE
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=installer_output
OutputBaseFilename=SalesSystem_Setup_v3.0.0
SetupIconFile=assets\icons\app_icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=نظام متكامل لإدارة المبيعات والمخازن
VersionInfoCopyright=Copyright (C) 2025 9Soft
WizardImageFile=assets\images\installer_banner.bmp
WizardSmallImageFile=assets\images\installer_small.bmp

[Languages]
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "إنشاء اختصار في شريط المهام"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "README.md"; DestDir: "{app}"; DestName: "README.txt"; Flags: ignoreversion
Source: "QUICK_START.md"; DestDir: "{app}"; DestName: "دليل_البدء_السريع.txt"; Flags: ignoreversion
Source: "9soft.md"; DestDir: "{app}"; DestName: "معلومات_المنتج.txt"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".myp"; ValueData: ""

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[CustomMessages]
arabic.WelcomeLabel1=مرحباً بك في معالج تثبيت نظام إدارة المبيعات
arabic.WelcomeLabel2=سيقوم هذا المعالج بتثبيت نظام إدارة المبيعات الشامل على جهازك.%n%nيُنصح بإغلاق جميع البرامج الأخرى قبل المتابعة.%n%nالمميزات الجديدة في الإصدار 3.0.0:%n• نظام إدارة منتجات محسّن بـ 5 أقسام%n• 14 حقل جديد للمنتجات%n• نافذة إضافة فئة احترافية بـ 11 حقل%n• اختيار من 8 ألوان و 8 أيقونات%n• تكامل كامل مع قاعدة البيانات%n%nاضغط التالي للمتابعة.
arabic.FinishedLabel=تم تثبيت نظام إدارة المبيعات بنجاح!%n%nشكراً لاختيارك 9Soft%n%nمعلومات الدخول الافتراضية:%nاسم المستخدم: admin%nكلمة المرور: admin%n%nللدعم الفني:%nsupport@9soft.com

[Code]
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  
  // Check for Windows 10 or later
  if Version.Major < 10 then
  begin
    MsgBox('هذا البرنامج يتطلب Windows 10 أو أحدث.' + #13#10 +
           'This program requires Windows 10 or later.', 
           mbCriticalError, MB_OK);
    Result := False;
    Exit;
  end;
  
  // Check for 64-bit system
  if not Is64BitInstallMode then
  begin
    MsgBox('هذا البرنامج يتطلب نظام 64-bit.' + #13#10 +
           'This program requires a 64-bit system.', 
           mbCriticalError, MB_OK);
    Result := False;
    Exit;
  end;
  
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Create data directory
    CreateDir(ExpandConstant('{app}\data'));
    CreateDir(ExpandConstant('{app}\data\database'));
    CreateDir(ExpandConstant('{app}\data\backups'));
    CreateDir(ExpandConstant('{app}\data\exports'));
    CreateDir(ExpandConstant('{app}\data\images'));
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if MsgBox('هل تريد حذف بيانات البرنامج أيضاً؟' + #13#10 +
              'Do you want to delete program data as well?', 
              mbConfirmation, MB_YESNO) = IDYES then
    begin
      DelTree(ExpandConstant('{app}\data'), True, True, True);
    end;
  end;
end;

function GetUninstallString: String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;

function IsUpgrade: Boolean;
begin
  Result := (GetUninstallString() <> '');
end;

function UnInstallOldVersion: Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
  Result := 0;
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

procedure InitializeWizard;
var
  UpgradeResult: Integer;
begin
  if IsUpgrade() then
  begin
    if MsgBox('تم اكتشاف نسخة قديمة من البرنامج. هل تريد إزالتها؟' + #13#10 +
              'An old version was detected. Do you want to remove it?', 
              mbConfirmation, MB_YESNO) = IDYES then
    begin
      UpgradeResult := UnInstallOldVersion();
      if UpgradeResult = 2 then
        MsgBox('فشل في إزالة النسخة القديمة. الرجاء إزالتها يدوياً.' + #13#10 +
               'Failed to remove old version. Please remove it manually.', 
               mbError, MB_OK);
    end;
  end;
end;
