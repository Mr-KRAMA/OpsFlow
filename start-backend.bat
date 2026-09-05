@echo off
set JAVA_HOME=C:\Progra~1\Java\jdk-22
set PATH=%JAVA_HOME%\bin;%PATH%
echo Starting OpsFlow Backend on http://localhost:8080
cd /d d:\Qspider\WEBTECH\WebTechProject\Project\backend
call mvnw.cmd spring-boot:run
pause
