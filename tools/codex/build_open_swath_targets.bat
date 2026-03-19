@echo off
setlocal

rem Build minimal targets needed to run TOPP_OpenSwathWorkflow_16.
rem Uses the existing Ninja build directory at ..\..\bld (repo root: OpenMS\).

set "REPO_ROOT=%~dp0..\.."
cd /d "%REPO_ROOT%"

set "VCVARS64=C:\PROGRA~2\MICROS~2\2022\BUILDT~1\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%VCVARS64%" (
  echo ERROR: vcvars64.bat not found at: %VCVARS64%
  exit /b 1
)

call "%VCVARS64%" >nul

rem Workaround: Windows SDK include/lib paths are not being set by this VS env on this machine.
set "WIN_KITS=C:\PROGRA~2\WI3CF2~1\10"
set "WIN_SDK_VER=10.0.26100.0"

if not exist "%WIN_KITS%\Include\%WIN_SDK_VER%\ucrt\time.h" (
  echo ERROR: Windows SDK headers not found at expected path:
  echo   %WIN_KITS%\Include\%WIN_SDK_VER%\ucrt\time.h
  exit /b 1
)

set "INCLUDE=%WIN_KITS%\Include\%WIN_SDK_VER%\ucrt;%WIN_KITS%\Include\%WIN_SDK_VER%\shared;%WIN_KITS%\Include\%WIN_SDK_VER%\um;%WIN_KITS%\Include\%WIN_SDK_VER%\winrt;%INCLUDE%"
set "LIB=%WIN_KITS%\Lib\%WIN_SDK_VER%\ucrt\x64;%WIN_KITS%\Lib\%WIN_SDK_VER%\um\x64;%LIB%"
set "PATH=%WIN_KITS%\bin\%WIN_SDK_VER%\x64;%PATH%"

rem Mitigation for occasional MSVC heap-space errors on large TU's.
set "CL=/Zm200"

cmake --build bld --target OpenSwathWorkflow OpenSwathMzMLFileCacher FuzzyDiff TargetedFileConverter --parallel 2
