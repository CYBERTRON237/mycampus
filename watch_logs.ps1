# Script PowerShell pour surveiller les logs Apache
Write-Host "Surveillance des logs Apache en temps réel..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

$logPath = "c:\wamp64\logs\apache_error.log"

if (Test-Path $logPath) {
    Get-Content $logPath -Wait -Tail 0
} else {
    Write-Host "Fichier de logs non trouvé: $logPath" -ForegroundColor Red
    Write-Host "Vérifie le chemin d'installation de WAMP" -ForegroundColor Yellow
}
