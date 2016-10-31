package Reboot;
#use feature qw(switch say);
use strict;
use Data::Dumper;
use Win32::OLE('in');
use feature qw(switch say);

use constant bFlagReturnImmediately => 0x10;
use constant bFlagForwardOnly => 0x20;

use vars qw($oWMIService $colItems $objItem @infos $info @array_infos @cols $service_state $objItem);

sub Main {
	my ($self,$oWMIService,@args) = @_;
	given($args[1])
	{
		when (['help','h','?','-h'])		{ $self->Help; }
		when (['-f', '/f', 'f', 'force'])	{ $self->Reboot($oWMIService, @args); }
		default								{ $self->Confirm($oWMIService, @args); }
	}
}

sub Reboot {
	my ($self,$oWMIService,@args) = @_;
	print "\n";
	@cols = in($oWMIService->ExecQuery("Select * from Win32_OperatingSystem"));
	foreach $objItem ( @cols) 
	{
		$service_state = $objItem->{Reboot};
	}
	#system("start ping -t " . $svr_ip);
	print "Reboot Command Sent";
	print "\n";
}

sub Confirm {
	my ($self,$oWMIService,@args) = @_;
	print "\nAre you sure you want to reboot this system? (y/n) >";
	chomp($info = <>);
	given($info)
	{
		when (['y', 'Y','yes','Yes','YES','yea'])	{ $self->Reboot($oWMIService, @args); }
		default										{ print "\nCanceled\n"; }
	}
}

sub Help {
	print "\nReboot\n";
	print "\t-f\tForce Reboot Without Confirmation\n";
	print "\t-h\tHelp (This menu)\n\n";	
}

1;
