:: Purpose:       Sub-script containing all commands for Tron's Stage 6: Optimize stage. Called by tron.bat and returns control when finished
:: Requirements:  1. Administrator access
::                2. Safe mode is recommended but not required
:: Author:        vocatus on reddit.com/r/TronScript ( vocatus.gate at gmail ) // PGP key: 0x07d1490f82a211a2
:: Version:       1.0.4 * script: Update script to support standalone execution
::                1.0.3 * Clarify log messages if we're skipping defrag because of an error
::                1.0.2 + Add support for multiple SKIP_DEFRAG variable values
::                1.0.1 - Remove internal log function and switch to Tron's external logging function. Thanks to github:nemchik
::                1.0.0 + Initial write
@echo off


:::::::::::::::::::::
:: PREP AND CHECKS ::
:::::::::::::::::::::
set STAGE_6_SCRIPT_VERSION=1.0.4
set STAGE_6_SCRIPT_DATE=2017-02-04

:: Check for standalone vs. Tron execution and build the environment if running in standalone mode
if /i "%LOGFILE%"=="" (
	pushd ..
	
	:: Load the settings file
	call functions\tron_settings.bat

	:: Initialize the runtime environment
	call functions\initialize_environment.bat
)



:::::::::::::::::::::::
:: STAGE 6: Optimize :: // Begin jobs
:::::::::::::::::::::::
call functions\log.bat "%CUR_DATE% %TIME%   stage_6_optimize begin..."


:: JOB: Reset the system page file settings
title Tron v%TRON_VERSION% [stage_6_optimize] [PageFileReset]
if /i %SKIP_PAGEFILE_RESET%==yes (
	call functions\log.bat "%CUR_DATE% %TIME% !  SKIP_PAGEFILE_RESET (-spr) set. Skipping page file reset."
) else (
	call functions\log.bat "%CUR_DATE% %TIME%    Resetting page file settings to Windows defaults..."
	if /i %DRY_RUN%==no %WMIC% computersystem where name="%computername%" set AutomaticManagedPagefile=True >> "%LOGPATH%\%LOGFILE%" 2>&1
	call functions\log.bat "%CUR_DATE% %TIME%    Done."
)


:: JOB: Check status of SKIP_DEFRAG and run defrag if no issues
if /i "%SKIP_DEFRAG%"=="yes" call functions\log.bat "%CUR_DATE% %TIME% !  SKIP_DEFRAG (-sd) set. Skipping defrag of %SystemDrive%."
if /i "%SKIP_DEFRAG%"=="yes_ssd" call functions\log.bat "%CUR_DATE% %TIME%    Solid State hard drive detected. Skipping defrag of %SystemDrive%."
if /i "%SKIP_DEFRAG%"=="yes_vm" call functions\log.bat "%CUR_DATE% %TIME%    Virtual Machine detected. Skipping defrag of %SystemDrive%."
if /i "%SKIP_DEFRAG%"=="yes_error" (
	call functions\log.bat "%CUR_DATE% %TIME% !  WARNING: Error reading %SystemDrive% disk stats. Skipping defrag as a precaution."
	set WARNINGS_DETECTED=yes
)
if /i "%SKIP_DEFRAG%"=="no" (
	title Tron v%TRON_VERSION% [stage_6_optimize] [Defrag]
	call functions\log.bat "%CUR_DATE% %TIME%    Launch job 'Defrag %SystemDrive%'..."
	if /i %DRY_RUN%==no stage_6_optimize\defrag\defraggler.exe %SystemDrive% /MinPercent 5
	call functions\log.bat "%CUR_DATE% %TIME%    Done."
)





:: Stage complete
call functions\log.bat "%CUR_DATE% %TIME%   stage_6_optimize complete."
