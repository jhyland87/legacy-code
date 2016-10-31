# FUNCTIONS
# By: Justin Hyland
# Desc: Used by Service_Manager.ps1
#

clear

# PID
# Get the PID of the service (Used for force kills and restarts)
#
function PID {
	$WMISVC = Get-WmiObject -computer $Server -query "Select ProcessID from Win32_Service Where DisplayName='$Display_Name'"
	return $WMISVC.ProcessID
}


# Get Current Service Status
#
function CurrentServiceStatus {
	$WMISVC = Get-WmiObject -computer $Server -query "Select State from Win32_Service Where DisplayName='$Display_Name'"
	return $WMISVC.State
}

# Start Service
#
function StartService {
	Write-Host "Starting $Display_Name ..." -NoNewLine

	# Start the service via WMI
	#
	$wmi_query = (gwmi -computername $Server -class win32_service -filter "$Filter").StartService()
	
	# Wait for it to started, then show it started. If it takes 3 minutes, fail
	#
	$looped=0

	do {
		$looped++;
		Write-Host ".." -NoNewLine
		
		if($looped -eq "180") {
				Write-Host "Failed (Took too long)"
				exit 1
		}
		
		sleep 1
	}
	while((CurrentServiceStatus) -ne "Running")
	
	$Return = $wmi_query.ReturnValue
	
	Write-Host $StatusCode[[int]$Return]
}

# Stop Service
#
function StopServiceGraceful {
	Write-Host "Stopping $Display_Name ..." -NoNewLine

	# Stop the service via WMI
	#
	$wmi_query = (gwmi -computername $Server -class win32_service -filter "$Filter").StopService()
	
	# Wait for it to stop, then show it stopped. If it takes 3 minutes, fail
	#
	$looped=0

	do {
		$looped++;
		Write-Host ".." -NoNewLine
		
		if($looped -eq "180") {
				Write-Host "Failed (Took too long)"
				exit 1
		}
		sleep 1
	}
	while((CurrentServiceStatus) -ne "Stopped")
	
	$Return = $wmi_query.ReturnValue
	
	Write-Host $StatusCode[[int]$Return]
}

# Force Stop Service
#
function StopServiceForceful {
	$ProcessID = (PID)
	Write-Host "Forcefully stopping $Display_Name (PID $ProcessID) ..." -NoNewLine
	
	$Process = Get-WmiObject -Computer $Server -Class Win32_Process -Filter "ProcessId='$ProcessID'"
	
	if($Process -eq $null) {
		Write-Host "Failed. Unable to find the process ID $ProcessID"
		exit 1
	}
	else {
		$KillResult = $Process.InvokeMethod("Terminate", "Killed via Jenkins")
		
		if($KillResult -ne 0) {
			Write-Host "Failed"
			exit 1
		}
		else {
			$looped=0

			do {
				$looped++;
				Write-Host ".." -NoNewLine
				
				if($looped -eq "180") {
						Write-Host "Failed (Took too long)"
						exit 1
				}
				sleep 1
			}
			while((CurrentServiceStatus) -ne "Stopped")
			
			Write-Host "Success"
		}
	}
}

# Stop Service Main (Chooses force or not)
#
function StopService {
	if( $Force -eq "True" ) {
		(StopServiceForceful)
	}
	else {
		(StopServiceGraceful)
	}
}

# Restart Service
#
function RestartService {
	if( $Force -eq "True" ) {
		(StopServiceForceful)
	}
	else {
		(StopService)
	}
	(StartService)
}

# WMI Return Codes to Plain Text
#
$StatusCode = @{
	0 = "Success"
	1 = "Not Supported"
	2 = "Access Denied"
	3 = "Dependent Services Running"
	4 = "Invalid Service Control"
	5 = "Service Cannot Accept Control"
	6 = "Service Not Active"
	7 = "Service Request Timed Out"
	8 = "Unknown Failure"
	9 = "Path Not Found"
	10 = "Service Already Running"
	11 = "Service Database Locked"
	12 = "Service Dependency Deleted"
	13 = "Service Dependency Failure"
	14 = "Service Disabled"
	15 = "Service Logon Failure"
	16 = "Service Marked For Deletion"
	17 = "Service No Thread" # Wtf does that mean?
	18 = "State Circular Dependency"
	19 = "Status Duplicate Name"
	20 = "Status Invalid Name"
	21 = "Status Invalid Parameter"
	22 = "Status Invalid Service Acount"
	23 = "Status Service Exists"
	24 = "Service Already Paused"
}