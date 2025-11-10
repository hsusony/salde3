; Script created by Inno Setup for Sales Management System - EXE2
; نظام إدارة المبيعات - النسخة الذكية
; يفحص SQL Server ويثبته تلقائياً إذا لم يكن موجود

#define MyAppName "نظام إدارة المبيعات"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Sales Management System"
#define MyAppExeName "sales_management_system.exe"
#define MyAppIcon "windows\runner\resources\app_icon.ico"

[Setup]
; معلومات التطبيق الأساسية
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Sales Management System
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
; المسار الذي سيتم حفظ ملف التنصيب فيه
OutputDir=installer_output
OutputBaseFilename=SalesManagementSystem_Setup_EXE2
SetupIconFile={#MyAppIcon}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; دعم اللغة العربية
LanguageDetectionMethod=locale

; الحد الأدنى للنظام
MinVersion=6.1sp1
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
; ملفات التطبيق الرئيسية من مجلد Release
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; ملفات إضافية
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion; DestName: "اقرأني.txt"
; ملفات SQL Server (للتثبيت التلقائي عند الحاجة)
Source: "sqlserver_config.ini"; DestDir: "{app}"; Flags: ignoreversion
Source: "install_sqlserver.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
; تثبيت SQL Server تلقائياً إذا لم يكن موجود
Filename: "{app}\install_sqlserver.bat"; Description: "تثبيت SQL Server (مطلوب)"; Flags: postinstall runascurrentuser; Check: NeedsSQLServer
; تشغيل البرنامج
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
Type: filesandordirs; Name: "{localappdata}\Sales Management System"

[Code]
var
  SQLServerPage: TOutputMsgWizardPage;
  SQLServerInstalled: Boolean;

// فحص إذا كان SQL Server مثبت
function IsSQLServerInstalled(): Boolean;
var
  RegKey: String;
  Value: String;
begin
  Result := False;
  
  // فحص SQL Server في Registry
  RegKey := 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL';
  
  // فحص SQLEXPRESS
  if RegQueryStringValue(HKLM, RegKey, 'SQLEXPRESS', Value) then
  begin
    Result := True;
    Exit;
  end;
  
  // فحص MorabSQLE
  if RegQueryStringValue(HKLM, RegKey, 'MorabSQLE', Value) then
  begin
    Result := True;
    Exit;
  end;
  
  // فحص MSSQLSERVER (الافتراضي)
  if RegQueryStringValue(HKLM, RegKey, 'MSSQLSERVER', Value) then
  begin
    Result := True;
    Exit;
  end;
  
  // فحص 64-bit
  if RegQueryStringValue(HKLM64, RegKey, 'SQLEXPRESS', Value) then
  begin
    Result := True;
    Exit;
  end;
  
  if RegQueryStringValue(HKLM64, RegKey, 'MorabSQLE', Value) then
  begin
    Result := True;
    Exit;
  end;
end;

// تحديد إذا كان يحتاج تثبيت SQL Server
function NeedsSQLServer(): Boolean;
begin
  Result := not SQLServerInstalled;
end;

// رسالة توضيحية
function InitializeSetup(): Boolean;
begin
  Result := True;
  SQLServerInstalled := IsSQLServerInstalled();
  
  if SQLServerInstalled then
  begin
    MsgBox('تم اكتشاف SQL Server مثبت على جهازك.' + #13#10 + 
           'سيتم تخطي تثبيت SQL Server.' + #13#10#13#10 +
           'اضغط موافق للمتابعة...', 
           mbInformation, MB_OK);
  end
  else
  begin
    if MsgBox('لم يتم اكتشاف SQL Server على جهازك.' + #13#10 + 
              'البرنامج يحتاج SQL Server 2008 R2 Express للعمل.' + #13#10#13#10 +
              'سيتم تثبيت SQL Server تلقائياً بعد التنصيب.' + #13#10 +
              'هذا قد يستغرق 10-15 دقيقة.' + #13#10#13#10 +
              'هل تريد المتابعة؟', 
              mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := False;
    end;
  end;
end;

// صفحة معلومات SQL Server
procedure InitializeWizard();
begin
  if not SQLServerInstalled then
  begin
    SQLServerPage := CreateOutputMsgPage(wpWelcome,
      'متطلبات النظام', 
      'SQL Server مطلوب',
      'لم يتم اكتشاف SQL Server على جهازك.' + #13#10#13#10 +
      'سيتم تثبيت SQL Server 2008 R2 Express تلقائياً بعد الانتهاء من التنصيب.' + #13#10#13#10 +
      'المعلومات:' + #13#10 +
      '• حجم التحميل: 250 MB تقريباً' + #13#10 +
      '• وقت التثبيت: 10-15 دقيقة' + #13#10 +
      '• يتطلب اتصال بالإنترنت' + #13#10 +
      '• Instance Name: MorabSQLE' + #13#10#13#10 +
      'يرجى الانتظار حتى انتهاء التثبيت الكامل.');
  end;
end;

// رسالة بعد انتهاء التثبيت
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if not SQLServerInstalled then
    begin
      MsgBox('سيبدأ الآن تثبيت SQL Server...' + #13#10#13#10 +
             'يرجى الانتظار حتى اكتمال العملية.' + #13#10 +
             'قد يستغرق هذا 10-15 دقيقة.' + #13#10#13#10 +
             'لا تغلق النافذة!', 
             mbInformation, MB_OK);
    end;
  end;
end;

procedure DeinitializeSetup();
begin
  if SQLServerInstalled then
  begin
    MsgBox('تم تثبيت البرنامج بنجاح!' + #13#10#13#10 +
           'SQL Server موجود بالفعل - تم تخطي التثبيت.', 
           mbInformation, MB_OK);
  end
  else
  begin
    MsgBox('إذا فشل تثبيت SQL Server، يمكنك:' + #13#10#13#10 +
           '1. تثبيته يدوياً من قائمة البرامج' + #13#10 +
           '2. تحميله من موقع Microsoft' + #13#10 +
           '3. الاتصال بالدعم الفني', 
           mbInformation, MB_OK);
  end;
end;
