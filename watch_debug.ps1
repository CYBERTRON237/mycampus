# Surveillance simple du fichier de debug
$logFile = "c:\wamp64\www\mycampus\debug_preinscription.log"

Write-Host "Surveillance du fichier de debug de préinscription..." -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Instructions:" -ForegroundColor Yellow
Write-Host "1. Lance ce script" -ForegroundColor White
Write-Host "2. Remplis ton formulaire complet dans l'application" -ForegroundColor White
Write-Host "3. Regarde ce qui s'affiche ci-dessous en temps réel" -ForegroundColor White
Write-Host ""
Write-Host "Appuie sur CTRL+C pour arrêter" -ForegroundColor Red
Write-Host ""

# Vérifier si le fichier existe
if (-not (Test-Path $logFile)) {
    Write-Host "Le fichier de log sera créé lors de la première requête..." -ForegroundColor Cyan
}

try {
    Get-Content $logFile -Wait -Tail 0
} catch {
    Write-Host "En attente de la première requête..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    # Recommencer
    & $PSCommandPath $PSCommandArgs
}
