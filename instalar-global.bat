@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Instalando o comando "antivirus-node" para usar em qualquer pasta do CMD...
call npm link
if errorlevel 1 (
  echo.
  echo Falhou. Tente abrir este arquivo como administrador.
  pause
  exit /b 1
)
echo.
echo Pronto! Em qualquer CMD, use:
echo   antivirus-node clean
echo   antivirus-node scan
echo   antivirus-node watch --quarantine
echo   antivirus-node quarantine list
pause
