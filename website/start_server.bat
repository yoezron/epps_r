@echo off
REM ============================================================================
REM EPPS Website - Simple HTTP Server Launcher (Windows)
REM ============================================================================

echo ======================================
echo   EPPS Analysis Report Website
echo   PT. Nirmala Satya Development
echo ======================================
echo.

set PORT=8000

echo Starting local web server...
echo.
echo Server will be available at:
echo    http://localhost:%PORT%
echo    http://127.0.0.1:%PORT%
echo.
echo Press Ctrl+C to stop the server
echo.
echo ======================================
echo.

REM Try Python 3 first, then Python 2
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Using Python...
    python -m http.server %PORT%
) else (
    echo Python not found!
    echo.
    echo Please install Python or use one of these alternatives:
    echo.
    echo 1. Node.js http-server:
    echo    npm install -g http-server
    echo    http-server -p %PORT%
    echo.
    echo 2. PHP built-in server:
    echo    php -S localhost:%PORT%
    echo.
    echo 3. Double-click index.html to open in browser
    pause
)
