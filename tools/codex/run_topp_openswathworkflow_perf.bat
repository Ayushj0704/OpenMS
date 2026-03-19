@echo off
setlocal enabledelayedexpansion

rem Run one or more TOPP_OpenSwathWorkflow_* tests with PERF logging enabled.
rem Usage:
rem   tools\codex\run_topp_openswathworkflow_perf.bat [ctest_regex]
rem Example:
rem   tools\codex\run_topp_openswathworkflow_perf.bat TOPP_OpenSwathWorkflow_16$

set "REPO_ROOT=%~dp0..\.."
set "BUILD_DIR=%REPO_ROOT%\bld"
set "REGEX=%~1"
if "%REGEX%"=="" set "REGEX=TOPP_OpenSwathWorkflow_16$"

if not exist "%BUILD_DIR%\CTestTestfile.cmake" (
  echo ERROR: Build directory not found at: "%BUILD_DIR%"
  echo Expected to find: "%BUILD_DIR%\CTestTestfile.cmake"
  exit /b 1
)

set "OPENMS_PROFILE_OPENSWATH=1"
set "OMP_NUM_THREADS=1"

set "LOG_DIR=%REPO_ROOT%\tools\codex\logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

set "TS=%RANDOM%"

set "LOG=%LOG_DIR%\ctest_%REGEX%_%TS%.log"

pushd "%BUILD_DIR%" >nul
echo Running: pixi run -- ctest -R "%REGEX%" -V
pixi run -- ctest -R "%REGEX%" -V > "%LOG%" 2>&1
set "RC=%ERRORLEVEL%"
popd >nul

echo Log: "%LOG%"
exit /b %RC%
