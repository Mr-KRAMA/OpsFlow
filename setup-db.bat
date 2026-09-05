@echo off
set PGBIN=C:\Program Files\PostgreSQL\18\bin
set PGPASSWORD=admin

echo Creating opsflow database and user...
"%PGBIN%\psql.exe" -U postgres -c "CREATE USER opsflow WITH PASSWORD 'opsflow123';" 2>&1
"%PGBIN%\psql.exe" -U postgres -c "CREATE DATABASE opsflow_db OWNER opsflow;" 2>&1
"%PGBIN%\psql.exe" -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE opsflow_db TO opsflow;" 2>&1
echo Done!
pause
