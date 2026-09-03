[Setup]
AppId={{8B1963A9-7A87-4340-9E11-30D1B0ED7502}
AppName=Rukmini Khata
AppVersion=1.0.1
AppPublisher=Shaikh Akram Shakil
DefaultDirName={autopf}\Rukmini Khata
DisableProgramGroupPage=yes
OutputDir=..\build\windows\installer
OutputBaseFilename=RukminiKhata_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\khata_rukmini.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build\windows\x64\runner\Release\sqlite3.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "..\build\windows\x64\runner\Release\pdfium.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "..\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

[Icons]
Name: "{autoprograms}\Rukmini Khata"; Filename: "{app}\khata_rukmini.exe"
Name: "{autodesktop}\Rukmini Khata"; Filename: "{app}\khata_rukmini.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\khata_rukmini.exe"; Description: "{cm:LaunchProgram,Rukmini Khata}"; Flags: nowait postinstall skipifsilent
