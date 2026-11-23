@echo off
chcp 65001 >nul
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js nao encontrado. Instale em https://nodejs.org e tente de novo.
  pause
  exit /b 1
)
echo === Antivirus: protecao em tempo real ===
echo Arquivos maliciosos novos em Downloads e Desktop vao para a quarentena.
echo Feche esta janela ou aperte Ctrl+C para parar.
echo.
node src\cli.js watch --quarantine %*
pause
