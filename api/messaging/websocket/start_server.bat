@echo off
echo Démarrage du serveur WebSocket MyCampus...
echo.

cd /d "%~dp0"

echo Démarrage du serveur WebSocket sur ws://127.0.0.1:8080
echo Appuyez sur Ctrl+C pour arrêter
echo.

c:\wamp64\bin\php\php8.3.28\php.exe server_simple.php

pause
