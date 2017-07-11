@echo off
set DATETMP=%DATE%
rem Mon 08/18/2014
set TIMETMP=%TIME%
rem 10:36:23.65
set TIMETMP=%TIMETMP::=%
set TIMETMP=%TIMETMP: =0%
set TIMETMP=%TIMETMP:~0,6%
set DATETMP=%DATETMP:/=%
set DATETMP=%DATETMP:-=%
set DATETMP=%DATETMP: =_%
set TIMESTAMP=%DATETMP%_%TIMETMP%
@echo on
ant deploy -v > "logs/deploy_%TIMESTAMP%.log" 2>&1