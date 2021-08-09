@CD /D "%~dp0"
@START "32BitLife" /b %SystemRoot%\SysWOW64\rundll32.exe "%~dp0\..\SpecialK32.dll",RunDLL_InjectionManager Install
@START "64BitLife" /b rundll32.exe "%~dp0\..\SpecialK64.dll",RunDLL_InjectionManager Install
