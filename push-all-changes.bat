@echo off
setlocal EnableExtensions EnableDelayedExpansion

pushd "%~dp0"

where git >nul 2>nul
if errorlevel 1 (
    echo Git is not installed or not available on PATH.
    popd
    exit /b 1
)

git add -A
if errorlevel 1 (
    echo Failed to stage changes.
    popd
    exit /b 1
)

git diff --cached --quiet
if not errorlevel 1 (
    echo No changes to commit.
    popd
    exit /b 0
)

set "COMMIT_MESSAGE=%~1"
if not defined COMMIT_MESSAGE (
    for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format \"yyyy-MM-dd HH:mm:ss\""') do set "STAMP=%%I"
    set "COMMIT_MESSAGE=Auto update !STAMP!"
)

git commit -m "%COMMIT_MESSAGE%"
if errorlevel 1 (
    echo Commit failed.
    popd
    exit /b 1
)

git push
set "EXIT_CODE=%errorlevel%"

if not "%EXIT_CODE%"=="0" (
    echo Push failed.
)

popd
exit /b %EXIT_CODE%