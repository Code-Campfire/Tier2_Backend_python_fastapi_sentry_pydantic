@echo off
SETLOCAL EnableDelayedExpansion

echo Starting Codefire FastAPI Setup for Windows
echo.

:: Navigate to project root (regardless of where the script is run from)
SET "SCRIPT_DIR=%~dp0"
SET "PROJECT_DIR=%SCRIPT_DIR%.."
cd %PROJECT_DIR%
echo Working directory: %cd%
echo.

:: Check if Python is installed
python --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo Python is not installed. Please install Python 3.9 or higher before proceeding.
    echo Visit https://www.python.org/downloads/ to download and install Python.
    echo.
    echo Recommended: Install Python 3.13+ for best compatibility with all features.
    echo Trying to open the Python download page in your browser...
    start https://www.python.org/downloads/
    exit /b 1
)

echo Checking Python version...
FOR /F "tokens=2" %%G IN ('python --version') DO SET pyversion=%%G
FOR /F "tokens=1,2 delims=." %%G IN ('echo %pyversion%') DO (
    SET pyversion_major=%%G
    SET pyversion_minor=%%H
)

echo Found Python !pyversion_major!.!pyversion_minor!
IF !pyversion_major! LSS 3 (
    echo Python 3.9 or higher is required. You have Python !pyversion_major!.!pyversion_minor!.
    echo Please install Python 3.9 or higher.
    exit /b 1
)
IF !pyversion_major! EQU 3 (
    IF !pyversion_minor! LSS 9 (
        echo Python 3.9 or higher is required. You have Python !pyversion_major!.!pyversion_minor!.
        echo Please install Python 3.9 or higher.
        exit /b 1
    )
)

echo Python !pyversion_major!.!pyversion_minor! is installed. Continuing setup...
echo.

:: Check if Poetry is installed
poetry --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo Poetry is not installed. Installing poetry...
    
    :: Install Poetry
    curl -sSL https://install.python-poetry.org | python -
    
    :: Check if installation was successful
    poetry --version >nul 2>&1
    IF ERRORLEVEL 1 (
        echo Failed to install Poetry. Please install it manually: 
        echo https://python-poetry.org/docs/#installation
        echo.
        echo Alternatively, you can proceed with pip installation.
        SET /P USE_PIP="Continue with pip instead of Poetry? (y/n): "
        IF /I NOT "!USE_PIP!"=="y" (
            exit /b 1
        )
        SET "USE_PIP=true"
    ) ELSE (
        echo Poetry installed successfully!
        SET "USE_PIP=false"
    )
) ELSE (
    echo Poetry is already installed.
    SET "USE_PIP=false"
)

echo.
echo ===== Installing dependencies =====
IF "!USE_PIP!"=="true" (
    :: Create a virtual environment with pip
    python -m venv venv
    call venv\Scripts\activate.bat
    pip install --upgrade pip
    pip install -r requirements.txt
) ELSE (
    :: Use Poetry for dependency management
    poetry install
)

echo.
echo ===== Creating environment file =====
IF NOT EXIST .env (
    copy .env_sample.txt .env
    echo .env file created from template
) ELSE (
    echo .env file already exists, keeping it as is
)

echo.
echo ===== Running tests =====
IF "!USE_PIP!"=="true" (
    python -m pytest
    SET TEST_RESULT=!ERRORLEVEL!
) ELSE (
    poetry run pytest
    SET TEST_RESULT=!ERRORLEVEL!
)

IF NOT "!TEST_RESULT!"=="0" (
    echo Tests failed. Please check the output above.
    exit /b 1
) ELSE (
    echo Tests passed successfully!
)

echo.
echo ===== Testing the application setup =====
echo Attempting to start the app to test the setup...

:: Start the server in the background
IF "!USE_PIP!"=="true" (
    start /B "" python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
) ELSE (
    start /B "" poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000
)

:: Wait for the server to start
timeout /T 5 /NOBREAK >nul

:: Check if the server is responding
curl -s http://localhost:8000/api/health >nul 2>&1
IF ERRORLEVEL 1 (
    echo Server failed to start properly.
) ELSE (
    echo Server started successfully!
)

:: Find and kill the server process
FOR /F "tokens=5" %%P IN ('netstat -ano ^| findstr :8000') DO (
    IF NOT "%%P"=="" (
        echo Stopping test server...
        taskkill /F /PID %%P >nul 2>&1
    )
)

echo.
echo ===== Setup Complete! =====
echo.
IF "!USE_PIP!"=="true" (
    echo To activate the virtual environment, use:
    echo   %PROJECT_DIR%\venv\Scripts\activate.bat  # On Windows
    echo.
    echo To run the development server, use:
    echo   python -m uvicorn app.main:app --reload
) ELSE (
    echo To run the development server, use:
    echo   poetry run uvicorn app.main:app --reload
)
echo This will start the development server at http://localhost:8000/
echo.
echo API will be available at http://localhost:8000/api/
echo.
echo API docs will be available at http://localhost:8000/docs/

ENDLOCAL 