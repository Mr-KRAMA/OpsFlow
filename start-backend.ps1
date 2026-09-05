$env:JAVA_HOME = "C:\Program Files\Java\jdk-22"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
Set-Location "d:\Qspider\WEBTECH\WebTechProject\Project\backend"
.\mvnw.cmd spring-boot:run
