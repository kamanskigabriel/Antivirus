@echo off
chcp 65001 >nul
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js nao encontrado. Instale em https://nodejs.org e tente de novo.
  pause
  exit /b 1
)
echo === Antivirus: varredura e limpeza ===
echo Voce vai decidir o que fazer com cada arquivo suspeito.
echo.
node src\cli.js clean %*
echo.
pause
