@echo off
REM Script d'export de la base de données PostgreSQL

echo Exportation de la base de donnees immobilier_db...

REM Définir les variables
set DB_NAME=immobilier_db
set DB_USER=postgres
set OUTPUT_FILE=database_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.sql

REM Export
pg_dump -U %DB_USER% -h localhost -p 5432 %DB_NAME% > %OUTPUT_FILE%

if %errorlevel% == 0 (
    echo ✅ Export reussi : %OUTPUT_FILE%
    echo.
    echo Partagez ce fichier avec votre collaborateur
) else (
    echo ❌ Erreur lors de l'export
)

pause
