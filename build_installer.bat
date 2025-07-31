@echo off
echo Limpando build anterior...
flutter clean

echo.
echo Baixando dependencias...
flutter pub get

echo.
echo Buildando o projeto Flutter para Windows...
flutter build windows --release

echo.
echo Compilando o instalador com Inno Setup...
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss

echo.
echo Instalador criado com sucesso na pasta installer_output!
echo Arquivo: BotTimerSetup.exe
pause
