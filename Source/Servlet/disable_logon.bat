REM Note, this must be run as admin because the task affects all users.
@CD /D %~dp0
@SCHTASKS /delete /tn "SK_InjectLogon" /f
@DEL SpecialK.LogOn