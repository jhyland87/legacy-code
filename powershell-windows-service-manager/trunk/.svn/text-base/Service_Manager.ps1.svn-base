# REMOTE WINDOWS SERVICE MANAGER
# By: Justin Hyland
# Desc: Will stop, start, restart, pause, or resume services on selected servers.
#

# Debugging
#
#$user = [Environment]::UserName
#$domain = [Environment]::UserDOmainName
#Write-Host "Username: $user on $domain"

# Input variables passed via Jenkins
#
$Server 		= ${env:Server}
$Action 		= ${env:Action}
$Display_Name 	= ${env:Service}
$Force 			= ${env:Force}
$Filter 		= "DisplayName='$Display_Name'"

#$Server 		= "wdjen01.lifelock.ad"
#$Action 		= "Restart"
#$Display_Name 	= "World Wide Web Publishing Service"
#$Force 			= "True"
#$Filter 		= "DisplayName='$Display_Name'"


# Include Functions
#
. .\Functions.ps1

# Test connection to $Server
#
Write-Host "Checking connection to $Server ... " -NoNewLine
if ( ( Test-Connection $Server -quiet) -ne $True ) {
	Write-Host "Failed"
	Write-Host "Unable to connect to the target server '$Server'"
	exit
}
else {
	Write-Host "Success"	
}


switch($Action) {
	"Stop" 		{ StopService
				break }
	"Start" 	{ StartService
				break }
	"Restart" 	{ RestartService
				break }
}
Write-Host "Current Status:" (CurrentServiceStatus)