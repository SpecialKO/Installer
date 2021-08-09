REM Note, this must be run as admin because the task affects all users.
@CD /D %~dp0
@SCHTASKS /create /tn "SK_InjectLogon" /tr "%~dp0\task_inject.bat" /sc ONLOGON /f
@echo > SpecialK.LogOn