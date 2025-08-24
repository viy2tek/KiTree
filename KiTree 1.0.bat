@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

:: --- LANGUAGE SELECTION / SELEÇÃO DE IDIOMA ---
:CHOOSE_LANG
cls
echo.
echo ===============================================
echo               KiTree v1.0
echo ===============================================
echo.
echo  Choose your language / Escolha seu idioma:
echo.
echo  1. Portugues (Brasil)
echo  2. English
echo.
set /p "langChoice=Enter option (1 or 2): "
if "%langChoice%"=="1" goto SET_LANG_PT
if "%langChoice%"=="2" goto SET_LANG_EN
echo Invalid option. Tente novamente. / Invalid option. Please try again.
timeout /t 2 >nul
goto CHOOSE_LANG

:: --- LANGUAGE VARIABLES (PORTUGUESE) ---
:SET_LANG_PT
set "TITLE=KiTree v1.0 - Criador de Estrutura para Drumkits"
set "ERR_INVALID_CHARS=[ERRO] O nome contém caracteres inválidos."
set "MSG_WELCOME=Este script criará uma estrutura personalizada de pastas para seu drumkit."
set "PROMPT_KIT_NAME=Digite o nome do seu kit: "
set "ERR_NAME_EMPTY=[ERRO] O nome do kit não pode ser vazio. Tente novamente."
set "WARN_FOLDER_EXISTS=[AVISO] Uma pasta chamada"
set "PROMPT_OVERWRITE=já existe. Deseja continuar e adicionar pastas a ela? (S/N): "
set "MSG_CREATING_KIT=Criando drumkit:"
set "ERR_MKDIR_FAILED=[ERRO] Não foi possível criar a pasta principal. Verifique suas permissões."
set "MSG_CREATING_FOLDER=  - Criando pasta:"
set "MSG_DONE=CRIAÇÃO CONCLUÍDA!"
set "MSG_KIT_CREATED=Drumkit criado:"
set "MSG_LOCATION=Localização:"
set "MSG_CREDITS=Feito por @viy2tek"
set "YES_CHAR=S"
set "NO_CHAR=N"
set "CUSTOM_TITLE=Criação de Pastas - Modo Interativo"
set "TEMPLATE_TITLE=Template de Pastas Disponíveis:"
set "CUSTOM_PROMPT=Digite os NÚMEROS das pastas que deseja criar (separados por vírgula): "
set "PROMPT_ADD_SUBFOLDERS=Adicionar subpastas em"
set "PROMPT_SUBFOLDER_NAMES=Digite os nomes das subpastas (separados por vírgula):"
goto PREPARE_VARS

:: --- LANGUAGE VARIABLES (ENGLISH) ---
:SET_LANG_EN
set "TITLE=KiTree v1.0 - Drumkit Folder Structure Creator"
set "ERR_INVALID_CHARS=[ERROR] The name contains invalid characters."
set "MSG_WELCOME=This script will create a custom folder structure for your drumkit."
set "PROMPT_KIT_NAME=Enter the name for your kit: "
set "ERR_NAME_EMPTY=[ERROR] The kit name cannot be empty. Please try again."
set "WARN_FOLDER_EXISTS=[WARNING] A folder named"
set "PROMPT_OVERWRITE=already exists. Do you want to continue and add folders to it? (Y/N): "
set "MSG_CREATING_KIT=Creating drumkit:"
set "ERR_MKDIR_FAILED=[ERROR] Could not create the main folder. Check your permissions."
set "MSG_CREATING_FOLDER=  - Creating folder:"
set "MSG_DONE=CREATION COMPLETE!"
set "MSG_KIT_CREATED=Drumkit created:"
set "MSG_LOCATION=Location:"
set "MSG_CREDITS=Made by @viy2tek"
set "YES_CHAR=Y"
set "NO_CHAR=N"
set "CUSTOM_TITLE=Folder Creation - Interactive Mode"
set "TEMPLATE_TITLE=Available Folder Template:"
set "CUSTOM_PROMPT=Enter the NUMBERS of the folders to create (separated by comma): "
set "PROMPT_ADD_SUBFOLDERS=Add subfolders to"
set "PROMPT_SUBFOLDER_NAMES=Enter subfolder names (separated by comma):"
goto PREPARE_VARS

:: --- SCRIPT SETUP ---
:PREPARE_VARS
:: Template apenas com pastas principais
set "template=808,Clap,Snare,HH_Hats,Kick,OH_Open_Hats,Perc,FX,Loops,Texture,Vox"
set count=0
for %%A in (%template%) do (
    set /a count+=1
    set "folder[!count!]=%%A"
)
set "totalFolders=%count%"

:: --- MAIN SCRIPT LOGIC ---
:MAIN_SCRIPT
title %TITLE%

:START
cls
echo.
echo ===============================================
echo               KiTree v1.0
echo ===============================================
echo.
echo %MSG_WELCOME%
echo.

:GET_NAME
set "kitname="
set /p "kitname=%PROMPT_KIT_NAME%"
if not defined kitname (
    echo %ERR_NAME_EMPTY%
    timeout /t 2 >nul
    goto GET_NAME
)
call :VALIDATE_NAME "%kitname%"
if errorlevel 1 (
    timeout /t 3 >nul
    goto GET_NAME
)

if exist "%kitname%" (
    echo.
    echo %WARN_FOLDER_EXISTS% "%kitname%".
    set /p "overwrite=%PROMPT_OVERWRITE%"
    if /i not "!overwrite!"=="!YES_CHAR!" goto START
)
echo.
echo %MSG_CREATING_KIT% %kitname%
mkdir "%kitname%" >nul 2>&1
if errorlevel 1 (
    echo %ERR_MKDIR_FAILED%
    pause
    exit /b 1
)
pushd "%kitname%"

:: --- INTERACTIVE FOLDER CREATION ---
:CUSTOM_CREATION
cls
echo.
echo %CUSTOM_TITLE%
echo.
echo %TEMPLATE_TITLE%
for /l %%i in (1,1,%totalFolders%) do (
    set "displayName=!folder[%%i]!"
    set "displayName=!displayName:_= !"
    echo   %%i. !displayName!
)
echo.
set "choices="
set /p "choices=%CUSTOM_PROMPT%"
echo.
if not defined choices goto FINALIZE

:: Convert commas to spaces for processing
set "choices=!choices:,= !"
for %%C in (!choices!) do (
    set "choiceNum=%%C"
    if defined folder[%%C] (
        set "currentFolder=!folder[%%C]!"
        set "displayFolder=!currentFolder:_= !"
        echo %MSG_CREATING_FOLDER% !displayFolder!
        mkdir "!displayFolder!" >nul 2>&1
        call :CREATE_SUBFOLDERS "!displayFolder!"
    )
)
goto FINALIZE

:: --- SUB-ROUTINE: CREATE SUBFOLDERS ---
:CREATE_SUBFOLDERS
set "mainFolder=%~1"
set "addSubs="
echo.
set /p "addSubs=%PROMPT_ADD_SUBFOLDERS% [%mainFolder%]? (%YES_CHAR%/%NO_CHAR%): "
if /i not "!addSubs!"=="!YES_CHAR!" exit /b 0

echo.
set "subNames="
set /p "subNames=%PROMPT_SUBFOLDER_NAMES% "
if not defined subNames exit /b 0

:: Process comma-separated subfolders
set "remaining=!subNames!"
:PROCESS_SUBFOLDER
if not defined remaining goto END_SUBFOLDERS

:: Extract first subfolder name
for /f "tokens=1* delims=," %%A in ("!remaining!") do (
    set "subName=%%A"
    set "remaining=%%B"
)

:: Trim spaces from subfolder name
for /f "tokens=* delims= " %%A in ("!subName!") do set "subName=%%A"
for /l %%A in (1,1,100) do if "!subName:~-1!"==" " set "subName=!subName:~0,-1!"

if defined subName (
    call :VALIDATE_NAME "!subName!"
    if not errorlevel 1 (
        echo   %MSG_CREATING_FOLDER% %mainFolder%\!subName!
        mkdir "%mainFolder%\!subName!" >nul 2>&1
    )
)
goto PROCESS_SUBFOLDER

:END_SUBFOLDERS
echo.
exit /b 0

:: --- SUB-ROUTINE: VALIDATE NAME ---
:VALIDATE_NAME
set "inputName=%~1"
set "hasInvalidChar=0"

:: Check for invalid characters one by one
echo "%inputName%" | find "\" >nul && set "hasInvalidChar=1"
echo "%inputName%" | find "/" >nul && set "hasInvalidChar=1"
echo "%inputName%" | find ":" >nul && set "hasInvalidChar=1"
echo "%inputName%" | find "*" >nul && set "hasInvalidChar=1"
echo "%inputName%" | find "?" >nul && set "hasInvalidChar=1"
echo "%inputName%" | find "<" >nul && set "hasInvalidChar=1"
echo "%inputName%" | find ">" >nul && set "hasInvalidChar=1"
echo "%inputName%" | find "|" >nul && set "hasInvalidChar=1"

if "%hasInvalidChar%"=="1" (
    echo %ERR_INVALID_CHARS%
    exit /b 1
)
exit /b 0

:: --- SCRIPT FINALE ---
:FINALIZE
popd
cls
echo.
echo ===============================================
echo              %MSG_DONE%
echo ===============================================
echo.
echo %MSG_KIT_CREATED% %kitname%
echo %MSG_LOCATION% %cd%\%kitname%
echo.
if exist "%cd%\%kitname%" (
    start "" "%cd%\%kitname%"
)
echo.
echo %MSG_CREDITS%
pause
exit /b 0
