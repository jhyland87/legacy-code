package Run;
#use strict;
#use Data::Dumper;
use Win32::OLE('in');
use Win32::OLE::Variant;
#use constant bFlagReturnImmediately => 0x10;
#use constant bFlagForwardOnly => 0x20;

use vars qw($oWMIService $colItems $objItem @infos $info @array_infos @col $run_arg $arg $proc $vPid);

sub Main {
	my ($self,$oWMIService,@args) = @_;
	print "\n";
	delete $args[0]; #Remove "run"
	
	if($args[1])
	{
		$run_arg = "";
				
		# Construct command to run
		foreach $arg (@args)
		{
			chomp($arg);
			$run_arg = $run_arg."$arg ";
		}
		
		$run_arg = substr($run_arg, 1);
		$run_arg = substr($run_arg, 0, -1);
	
		@col = ($oWMIService->Get('Win32_Process'));

		foreach $proc ( @col ) 
		{
			$vPid = Variant(VT_I4 | VT_BYREF, 0);
			# Create the new process
			if ($proc->Create($run_arg, undef, undef, $vPid) == 0)
			{
				print "Command: $run_arg\n";
				print "Process Created ok, pid=$vPid";
			}
			else
			{
				print "Process create failed (Possibly an unknown command) $^E";
			}
		}
	}
	else
	{
		$self->Help;
	}
	print "\n";
}

sub Help {
	print "Simply type 'run' followed by a command you wish to run.\n\nNOTE: You will not be able to see the output of the command\n\nEG: run shutdown /r /f /t 00";
}
1;
