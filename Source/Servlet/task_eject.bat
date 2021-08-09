@CD /D "%~dp0"
@START "32BitDeath" /b %SystemRoot%\SysWOW64\rundll32.exe "%~dp0\..\SpecialK32.dll",RunDLL_InjectionManager Remove
@START "64BitDeath" /b rundll32.exe "%~dp0\..\SpecialK64.dll",RunDLL_InjectionManager Remove
