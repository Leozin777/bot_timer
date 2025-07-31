[Setup]
; Informações básicas do aplicativo
AppName=Bot Timer
AppVersion=1.0.0
AppPublisher=Leozin777
AppPublisherURL=https://github.com/Leozin777/bot_timer
AppSupportURL=https://github.com/Leozin777/bot_timer
AppUpdatesURL=https://github.com/Leozin777/bot_timer
DefaultDirName={autopf}\Bot Timer
DefaultGroupName=Bot Timer
AllowNoIcons=yes
LicenseFile=
OutputDir=installer_output
OutputBaseFilename=BotTimerSetup
SetupIconFile=
Compression=lzma
SolidCompression=yes
WizardStyle=modern

; Configurações de arquitetura
ArchitecturesInstallIn64BitMode=x64compatible

; Configurações de permissões
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Executável principal
Source: "build\windows\x64\runner\Release\bot_timer.exe"; DestDir: "{app}"; Flags: ignoreversion

; Todas as DLLs necessárias
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion

; Assets do aplicativo
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Visual C++ Redistributable (se necessário)
; Source: "vcredist_x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\Bot Timer"; Filename: "{app}\bot_timer.exe"
Name: "{group}\{cm:UninstallProgram,Bot Timer}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Bot Timer"; Filename: "{app}\bot_timer.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\bot_timer.exe"; Description: "{cm:LaunchProgram,Bot Timer}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
// Função para verificar se o Visual C++ Redistributable está instalado
function VCRedistNeedsInstall: Boolean;
var
  Version: String;
begin
  if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version) then
  begin
    // Se a versão for menor que 14.0, precisa instalar
    Result := (CompareStr(Version, 'v14.0.0.0') < 0);
  end
  else
  begin
    // Se não encontrou a chave, precisa instalar
    Result := True;
  end;
end;

// Função executada antes da instalação
function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
end;

// Função executada após a instalação
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Criar diretório para áudios personalizados
    if not DirExists(ExpandConstant('{userdocs}\audios_bot')) then
      CreateDir(ExpandConstant('{userdocs}\audios_bot'));
  end;
end;
