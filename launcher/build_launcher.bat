@echo off
setlocal
cd /d "%~dp0"
set "LOG=%~dp0build_log.txt"
echo Log do build > "%LOG%"

rem --- localizar o Python (instala automaticamente se nao existir) ---
call :localizar
if not defined PY (
  echo Python nao encontrado. Instalando automaticamente...
  call :instalar_python
  call :localizar
)
if not defined PY (
  echo [ERRO] Nao foi possivel instalar o Python automaticamente.
  echo        Instale manualmente em python.org e marque "Add Python to PATH".
  goto fim
)
echo Usando: %PY%
%PY% --version

rem --- conferir arquivos necessarios ---
for %%F in (hmax_launcher.py F1_LS_3_1_0.ahk Hmax_AutoUpdate.ahk Pass64_original.exe Pass32.exe Hmaxlogo.ico Hmaxlogo.png) do (
  if not exist "%%F" (
    echo [ERRO] Arquivo ausente na pasta: %%F
    goto fim
  )
)
if not exist "UX" (
  echo [ERRO] Pasta UX ausente.
  goto fim
)

echo === Instalando PyInstaller ===
%PY% -m pip install --upgrade pyinstaller >> "%LOG%" 2>&1
if errorlevel 1 (
  echo [ERRO] Falha ao instalar o PyInstaller. Veja build_log.txt
  type "%LOG%"
  goto fim
)

echo === Gerando Hmax_Python.exe ===
if not exist "fonte_banco.ini" (
  echo [azure]> "fonte_banco.ini"
  echo url=>> "fonte_banco.ini"
)
%PY% -m PyInstaller --noconfirm --clean --onefile --noconsole --name Hmax --icon "Hmaxlogo.ico" --add-data "F1_LS_3_1_0.ahk;." --add-data "Hmax_AutoUpdate.ahk;." --add-data "fonte_banco.ini;." --add-data "Pass64_original.exe;." --add-data "Pass32.exe;." --add-data "Hmaxlogo.ico;." --add-data "Hmaxlogo.png;." --add-data "UX;UX" hmax_launcher.py >> "%LOG%" 2>&1
if errorlevel 1 (
  echo [ERRO] Falha no PyInstaller. Ultimas linhas do log:
  powershell -NoProfile -Command "Get-Content -Tail 25 '%LOG%'"
  goto fim
)

if exist "dist\Hmax.exe" (
  copy /y "dist\Hmax.exe" "Hmax_Python.exe" >nul
  echo.
  echo Pronto! Executavel: %~dp0Hmax_Python.exe
) else (
  echo [ERRO] dist\Hmax.exe nao foi gerado. Veja build_log.txt
)

:fim
echo.
pause
endlocal
exit /b

rem ============================================================
rem  Sub-rotinas
rem ============================================================

:localizar
rem Procura um Python que realmente funcione (ignora o atalho da Microsoft Store)
set "PY="
py -3 --version >nul 2>&1
if not errorlevel 1 (
  set "PY=py -3"
  goto :eof
)
python --version >nul 2>&1
if not errorlevel 1 (
  set "PY=python"
  goto :eof
)
rem Recem-instalado: o PATH desta janela ainda nao atualizou, entao procura nos locais padrao
for %%V in (313 312 311 310) do (
  if not defined PY if exist "%LocalAppData%\Programs\Python\Python%%V\python.exe" set PY="%LocalAppData%\Programs\Python\Python%%V\python.exe"
  if not defined PY if exist "%ProgramFiles%\Python%%V\python.exe" set PY="%ProgramFiles%\Python%%V\python.exe"
)
goto :eof

:instalar_python
rem 1) tenta pelo winget
where winget >nul 2>&1
if not errorlevel 1 (
  echo Instalando Python via winget...
  winget install -e --id Python.Python.3.12 --scope user --silent --accept-package-agreements --accept-source-agreements >> "%LOG%" 2>&1
  call :localizar
  if defined PY goto :eof
)
rem 2) baixa o instalador oficial do python.org
set "PYINST=%TEMP%\python_installer.exe"
echo Baixando instalador do Python (python.org)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri 'https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe' -OutFile '%PYINST%'" >> "%LOG%" 2>&1
if not exist "%PYINST%" (
  echo [ERRO] Falha ao baixar o instalador do Python. Verifique a internet.
  goto :eof
)
echo Instalando Python (aguarde, sem janelas)...
start /wait "" "%PYINST%" /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1 Include_pip=1 Include_test=0 >> "%LOG%" 2>&1
del /q "%PYINST%" >nul 2>&1
goto :eof
