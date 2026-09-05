$pgBin = "C:\Program Files\PostgreSQL\18\bin"
$env:PGPASSWORD = Read-Host "Enter your PostgreSQL 'postgres' user password"

Write-Host "Creating opsflow user and database..." -ForegroundColor Cyan

& "$pgBin\psql.exe" -U postgres -c "CREATE USER opsflow WITH PASSWORD 'opsflow123';" 2>&1
& "$pgBin\psql.exe" -U postgres -c "CREATE DATABASE opsflow_db OWNER opsflow;" 2>&1
& "$pgBin\psql.exe" -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE opsflow_db TO opsflow;" 2>&1

Write-Host ""
Write-Host "Done! Database ready." -ForegroundColor Green
Write-Host "Now start backend with PostgreSQL profile:" -ForegroundColor Yellow
Write-Host '  $env:JAVA_HOME = "C:\Program Files\Java\jdk-22"' -ForegroundColor White
Write-Host '  $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"' -ForegroundColor White
Write-Host '  cd "d:\Qspider\WEBTECH\WebTechProject\Project\backend"' -ForegroundColor White
Write-Host '  .\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=postgres' -ForegroundColor White
