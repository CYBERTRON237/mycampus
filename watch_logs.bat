@echo off
echo Surveillance des logs Apache en temps reel...
echo ========================================
echo.
cd /d c:\wamp64\logs
tail -f apache_error.log
