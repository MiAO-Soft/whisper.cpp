@echo off
:: Whisper Server Batch File (Portable with Port Check and Command Preview)
:: Automatically uses the folder where this .bat file is located

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "EXE_PATH=%SCRIPT_DIR%whisper-server.exe"
set "MODEL_PATH=%SCRIPT_DIR%models\ggml-large-v3.bin"
set "VAD_MODEL_PATH=%SCRIPT_DIR%models\ggml-silero-v6.2.0.bin"
set "PUBLIC_DIR=%SCRIPT_DIR%static"
set "PORT=18181"

:: Optional: remove trailing backslash for cleaner display
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Check executable
if not exist "%EXE_PATH%" (
    echo Error: whisper-server.exe not found in %SCRIPT_DIR%
    pause
    exit /b 1
)

:: Check models
if not exist "%MODEL_PATH%" (
    echo Error: Model not found: %MODEL_PATH%
    echo Please download from https://huggingface.co/ggerganov/whisper.cpp
    pause
    exit /b 1
)

if not exist "%VAD_MODEL_PATH%" (
    echo Error: VAD model not found: %VAD_MODEL_PATH%
    echo Please download from https://huggingface.co/ggml-org/whisper-vad
    pause
    exit /b 1
)

:: Prepare static/public dir
if not exist "%PUBLIC_DIR%" mkdir "%PUBLIC_DIR%"
if not exist "%PUBLIC_DIR%\index.html" (
    if exist "%SCRIPT_DIR%\index.html" (
        echo Moving index.html to static folder...
        move /Y "%SCRIPT_DIR%\index.html" "%PUBLIC_DIR%\index.html" >nul
    ) else (
        echo Warning: index.html not found. Web UI may not work properly.
        set "PUBLIC_DIR=."
    )
)

:: === PORT CHECK ===
echo Checking if port %PORT% is already in use...
netstat -ano | findstr :%PORT% >nul
if %errorlevel% equ 0 (
    echo.
    echo Port %PORT% is already in use. A whisper-server instance may already be running.
    echo You can access it at http://localhost:%PORT%
    echo Skipping launch.
    echo.
) else (
    echo Port %PORT% is free. Preparing to start whisper-server...

    :: Build the command string for display
    set "CMD=%EXE_PATH% -m "%MODEL_PATH%" --host 0.0.0.0 --port %PORT% -t 8 -l auto --vad --vad-model "%VAD_MODEL_PATH%" -p 8 -mc 0 --public "%PUBLIC_DIR%""

    echo.
    echo [INFO] Executing command:
    echo !CMD!
    echo.

    :: Launch in background
    start "" !CMD!
    echo whisper-server started in background on port %PORT%.
)

:: Final info
echo.
echo Open http://localhost:%PORT% in your browser to access the interface.
pause