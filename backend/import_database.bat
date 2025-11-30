@echo off
REM Script d'import de la base de données PostgreSQL

echo Import de la base de donnees immobilier_db...

REM Définir les variables
set DB_NAME=immobilier_db
set DB_USER=postgres

REM Demander le fichier à importer
set /p SQL_FILE="Entrez le nom du fichier SQL a importer : "

if not exist "%SQL_FILE%" (
    echo ❌ Fichier non trouve : %SQL_FILE%
    pause
    exit /b
)

REM Créer la base si elle n'existe pas
psql -U %DB_USER% -h localhost -c "CREATE DATABASE %DB_NAME%;" 2>nul

REM Importer
psql -U %DB_USER% -h localhost -d %DB_NAME% < "%SQL_FILE%"

if %errorlevel% == 0 (
    echo ✅ Import reussi !
) else (
    echo ❌ Erreur lors de l'import
)

pause
