@echo off
title DSH LAN - Windows port-forward setup
echo Applying DeepSeek Harness LAN port-forward + firewall (admin required)...
echo.
powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-NoExit','-File','C:\Users\Public\dsh-lan.ps1'"
echo A UAC prompt should have appeared on your screen - click Yes.
echo The elevated window prints the phone URLs and stays open until you close it.
echo.
timeout /t 3 >nul
