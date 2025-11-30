# Script pour tester le système de rôles
Write-Host "🧪 ORCHESTRATION DES TESTS" -ForegroundColor Cyan
Write-Host "=" * 80

# Vérifier si le serveur tourne
$nodeProcess = Get-Process -Name node -ErrorAction SilentlyContinue
if (-not $nodeProcess) {
    Write-Host "❌ Serveur non démarré. Veuillez d'abord démarrer le serveur avec 'npm start'" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Serveur détecté (PID: $($nodeProcess.Id))" -ForegroundColor Green
Write-Host ""

# Attendre 2 secondes pour s'assurer que le serveur est prêt
Start-Sleep -Seconds 2

# Exécuter les tests
Write-Host "▶️  Exécution des tests..." -ForegroundColor Yellow
node test-all-roles.js

Write-Host ""
Write-Host "✅ Tests terminés!" -ForegroundColor Green
