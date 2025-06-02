@echo off

set SCRIPT_DIR=%~dp0
set SCRIPT_NAME=summarizeDiffs.m
set MATLAB_EXE="C:\Program Files\MATLAB\R2025a\bin\matlab.exe"
%MATLAB_EXE% -nosplash -r "cd('%SCRIPT_DIR%'); open('%SCRIPT_NAME%'); run('%SCRIPT_NAME%');"