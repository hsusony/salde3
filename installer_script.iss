; Script created by Inno Setup for Sales Management System
; نظام إدارة المبيعات - محدث
; Updated: November 10, 2025

#define MyAppName "نظام إدارة المبيعات"
#define MyAppVersion "1.1.0"
#define MyAppPublisher "Sales Management System"
#define MyAppExeName "sales_management_system.exe"
#define MyAppIcon "windows\runner\resources\app_icon.ico"
#define MyAppURL "https://github.com/hsusony/salde3"

[Setup]
; معلومات التطبيق الأساسية
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Sales Management System
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
; المسار الذي سيتم حفظ ملف التنصيب فيه
OutputDir=installer_output
OutputBaseFilename=SalesManagementSystem_v1.1.0_Setup
SetupIconFile={#MyAppIcon}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; دعم اللغة العربية
LanguageDetectionMethod=locale
; معلومات إضافية
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=نظام إدارة المبيعات الاحترافي
VersionInfoCopyright=Copyright © 2025
UninstallDisplayIcon={app}\{#MyAppExeName}
; تحسينات الأداء
InternalCompressLevel=ultra64

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
; ملفات التوثيق
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion; DestName: "اقرأني.txt"
Source: "QUICK_START.md"; DestDir: "{app}\docs"; Flags: ignoreversion skipifsourcedoesntexist
Source: "USAGE_GUIDE.md"; DestDir: "{app}\docs"; Flags: ignoreversion skipifsourcedoesntexist
Source: "COMPLETE_SETUP_GUIDE.md"; DestDir: "{app}\docs"; Flags: ignoreversion skipifsourcedoesntexist
; ملفات قاعدة البيانات
Source: "database\*.sql"; DestDir: "{app}\database"; Flags: ignoreversion skipifsourcedoesntexist recursesubdirs
Source: "database\*.bat"; DestDir: "{app}\database"; Flags: ignoreversion skipifsourcedoesntexist
; ملفات Backend (اختياري)
Source: "backend-php\*"; DestDir: "{app}\backend"; Flags: ignoreversion skipifsourcedoesntexist recursesubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\دليل الاستخدام"; Filename: "{app}\docs\USAGE_GUIDE.md"; IconFilename: "{sys}\shell32.dll"; IconIndex: 70
Name: "{group}\قاعدة البيانات"; Filename: "{app}\database"; IconFilename: "{sys}\shell32.dll"; IconIndex: 4
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
Type: filesandordirs; Name: "{localappdata}\Sales Management System"

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
