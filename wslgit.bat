@echo off
If %PROCESSOR_ARCHITECTURE% == x86 (
	C:\Windows\sysnative\wsl.exe git %*
) Else (
	wsl git %*
)