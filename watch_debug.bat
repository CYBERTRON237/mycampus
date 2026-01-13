@echo off
echo Surveillance du fichier de debug de preinscription...
echo ==================================================
echo.
cd /d c:\wamp64\www\mycampus
if not exist debug_preinscription.log (
    echo Le fichier de log va etre cree lors de la premiere requete...
    echo.
)

:loop
cls
echo === DERNIÈRES LIGNES DU LOG ===
echo =================================
echo.
if exist debug_preinscription.log (
    powershell -Command "Get-Content debug_preinscription.log -Tail 20"
) else (
    echo En attente de la premiere requete...
)
echo.
echo =================================
echo CTRL+C pour arreter
timeout /t 2 >nul
goto loop
