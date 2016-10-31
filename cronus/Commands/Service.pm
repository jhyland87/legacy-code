package Service;
use feature qw(switch say);
use strict;
use Data::Dumper;
use Win32::OLE('in');

use constant bFlagReturnImmediately => 0x10;
use constant bFlagForwardOnly => 0x20;

use vars qw($oWMIService $colItems $objItem @infos $info @array_infos @col @matches %matches $sid $service $service_state);

### Task Dispatch
sub ServiceMain {
	my ($self,$oWMIService,@args) = @_;
	### Task Given/Switch (list kill or help)
	given($args[1])	{
		when (['list', 'l', 'lst']) 				{ $self->ServiceList($oWMIService); }
		when (['--status', 's', '--status-all'])	{ $self->ServiceStatus; }
		when (['h', 'help', '?'])					{ $self->ServiceHelp; }
		default										{ $self->ServiceAction($oWMIService,@args); }
	}
};

### Get Matches: This will regex for a friendly name of a service "Description" and return values
sub GetMatches
{
	my ($self,$oWMIService,@args) = @_;
	my $input_svc = $args[0];
	# EMPTY ARRAY TO GET POSSIBLE MATCHES
	my $count = 0;
	my %matches = ();
	$#matches = -1;
	@col = in($oWMIService->ExecQuery("Select * from Win32_Service"));
	
	foreach $objItem ( @col ) 
	{
		if($objItem->{Caption} =~ /$input_svc/i)
		{
			$count++;
			$matches{$count} = $objItem->{Caption};
		}
	}
	
	### If only one result, return that, if not, allow a selection
	if($matches{'2'})
	{
		print "\nPlease Select a Service..\n\n";
		foreach $sid (sort keys(%matches))
		{
			printf("%-3s %8s\n", $sid, $matches{$sid});
		}
		print "\n(Ctrl+C to Cancel)";
		print "\n\n>> ";
		chomp(my $effect = <>);
		if($matches{$effect})
		{
			return $matches{$effect};
		}
	}
	else
	{
		return $matches{'1'};
	}
}

### Get service status. Used to check actions, and service status
sub CurrentStatus {
	my ($self,$oWMIService,@args) = @_;
	$service = $args[0];
	@col = in($oWMIService->ExecQuery("Select * from Win32_Service WHERE DisplayName = '$service'"));
	foreach $objItem ( @col ) 
	{
		$service_state = $objItem->{State};
	}
	return $service_state;
}

### Service Dispatch (Start, stop, etc)
sub ServiceAction {
	my ($self,$oWMIService,@args) = @_;
	given($args[2]) {
			when ('stop')	{ $self->ServiceStop($oWMIService,$args[1]); }
			when ('start')	{ $self->ServiceStart($oWMIService,$args[1]); }
			when ('pause')	{ $self->ServicePause($oWMIService,$args[1]); }
			when ('resume')	{ $self->ServiceResume($oWMIService,$args[1]); }
			when ('restart'){ $self->ServiceRestart($oWMIService,$args[1]); }
			when ('status')	{ $self->ServiceStatus($oWMIService,$args[1]); }
			default			{ $self->ServiceHelp; }
	}
}

### STOP A SERVICE
sub ServiceStop {
	my ($self,$oWMIService,@args) = @_;
	my $service = $self->GetMatches($oWMIService, $args[0]);
	print "\nCtrl+c aborts wait..\n";
	print "\nStopping '$service'... ";
	@col = in($oWMIService->ExecQuery("Select * from Win32_Service WHERE DisplayName = '$service'"));
	foreach $objItem ( @col ) 
	{
		$objItem->{StopService};
	}
	$service_state = $self->CurrentStatus($oWMIService,$service);
	while($service_state ne "Stopped")
	{
		sleep(1);
		$service_state = $self->CurrentStatus($oWMIService,$service);
	}
	print "Stopped.\n";
}

### START A SERVICE
sub ServiceStart {
	my ($self,$oWMIService,@args) = @_;
	my $service = $self->GetMatches($oWMIService, $args[0]);
	print "\nCtrl+c aborts wait..\n";
	print "\nStarting '$service'... ";
	@col = in($oWMIService->ExecQuery("Select * from Win32_Service WHERE DisplayName = '$service'"));
	foreach $objItem ( @col ) 
	{
		$objItem->{StartService};
	}
	$service_state = $self->CurrentStatus($oWMIService,$service);
	while($service_state ne "Running")
	{
		sleep(1);
		$service_state = $self->CurrentStatus($oWMIService,$service);
	}
	print "Started.\n";
}

### PAUSE A SERVICE
sub ServicePause {
	my ($self,$oWMIService,@args) = @_;
	my $service = $self->GetMatches($oWMIService, $args[0]);
	print "\nCtrl+c aborts wait..\n";
	print "\nPausing '$service'... ";
	@col = in($oWMIService->ExecQuery("Select * from Win32_Service WHERE DisplayName = '$service'"));
	foreach $objItem ( @col ) 
	{
		$objItem->{PauseService};
	}
	$service_state = $self->CurrentStatus($oWMIService,$service);
	while($service_state ne "Paused")
	{
		sleep(1);
		$service_state = $self->CurrentStatus($oWMIService,$service);
	}
	print "Paused.\n";
}

### RESUME FROM PAUSE
sub ServiceResume {
	my ($self,$oWMIService,@args) = @_;
	my $service = $self->GetMatches($oWMIService, $args[0]);
	print "\nCtrl+c aborts wait..\n";
	print "\nResuming '$service'... ";
	@col = in($oWMIService->ExecQuery("Select * from Win32_Service WHERE DisplayName = '$service'"));
	foreach $objItem ( @col ) 
	{
		$objItem->{ResumeService};
	}
	$service_state = $self->CurrentStatus($oWMIService,$service);
	while($service_state ne "Running")
	{
		sleep(1);
		$service_state = $self->CurrentStatus($oWMIService,$service);
	}
	print "Resumed.\n";
}

### STOP THEN START SERVICE
sub ServiceRestart {
	my ($self,$oWMIService,@args) = @_;
	my $service = $self->GetMatches($oWMIService, $args[0]);

	$self->ServiceStop($oWMIService,$service);
	$self->ServiceStart($oWMIService,$service);
}

### LIST ALL SERVICES, PID's, and STATUSES
sub ServiceList {
	my ($self,$oWMIService,@args) = @_;
	@col = in($oWMIService->ExecQuery("Select * from Win32_Service"));
	printf("%-8s %-65s %8s\n", "PID", "SERVICE NAME", "STATE");
	print "\n";
	foreach $objItem ( @col ) 
	{
		printf("%-8s %-65s %8s\n", $objItem->{ProcessId}, $objItem->{Caption}, $objItem->{State});
	}
	print "\n";
	printf("%-8s %-65s %8s\n", "PID", "SERVICE NAME", "STATE");
}

### GET STATUS OF SPECIFIC SERVICE
sub ServiceStatus {
	my ($self,$oWMIService,@args) = @_;
	my $service = $self->GetMatches($oWMIService, $args[0]);
	print "\n".$service." - ". $self->CurrentStatus($oWMIService,$service)."\n";
}

### 'service' FOR DUMMIES
sub ServiceHelp {
	print "\n'Service' - Start, Stop, Restart, Pause, Resume or get the current status of any given service\n";
	print "\nStart A Service (EG: Apache)\n\t";
	print "service apache start\n";
	print "\nStop A Service\n\t";
	print "service apache stop\n";
	print "\nPause A Service\n\t";
	print "service apache pause\n";
	print "\nResume A Service\n\t";
	print "service apache resume\n";
	print "\nStatus A Service\n\t";
	print "service apache status\n";
	print "\nNOTE: The service name should not contain spaces or quotes. Cronus will regex for matching serviecs and list available services to run your query on.\n"; 
}

1;
