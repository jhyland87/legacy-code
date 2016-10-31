package Task;
use feature qw(switch say);
use strict;
use Data::Dumper;
use vars qw (@commands $ids $commands $self $oWMIService $pid $a $b $Proc $title @pidArray @col @col2 $count $objItem2 $objItem $thispid $checked $killed $info @infos);
use Win32::OLE('in');
use Number::Bytes::Human qw(format_bytes);
use POSIX qw/floor/;

use constant bFlagReturnImmediately => 0x10;
use constant bFlagForwardOnly => 0x20;

### Task Dispatch
sub TaskMain {
	my ($self,$oWMIService,@args) = @_;
	### Task Given/Switch (list kill or help)
	given($args[1])	{
		when (['l', 'list', 'lst']) { $self->TaskList($oWMIService,@args); }
		when (['k', 'kill'])		{ $self->TaskKill($oWMIService,@args); }
		when (['h', 'help', '?'])	{ $self->TaskHelp($oWMIService,@args); }
		when (['d', 'detail'])		{ $self->TaskDetail($oWMIService,@args); }
		default						{ print "\ntask h for help \n"; }
	}
};

### Task Help
sub TaskHelp {
	my ($self,@args) = @_;

	print "\n# LIST TASKS: list, l, lst\n";
	print "\nEXAMPLES\n";
	print "\n\tList All Tasks:\n";
	print "\t\t'task list', 'task l', 'tsk l', 'tsk lst'\n";
	print "\n\tList All Tasks with 'win' in the name:\n";
	print "\t\t'task list win', 'task l win', 'tsk l win', 'tsk lst win'\n";
	print "\n\tList Task with PID 999:\n";
	print "\t\t'task list #999', 'task l #999', 'tsk l #999', 'tsk lst #999'\n";
	print "\n";
	print "# KILL TASKS: kill, k\n";
	print "\nEXAMPLES\n";
	print "\n\tKilasks With 'win' in title:\n";
	print "\t\t'task kill win', 'task k win', 'tsk k win'\n";
	print "\n\tKill Task(s) with PID(s)\n";
	print "\t\t'task kill 99', 'task k 99', 'tsk k 99 88', 'task kill 99 88'\n";
};

### Task Kill
sub TaskKill {
	my ($self,$oWMIService,@args) = @_;
	if($args[2])
	{
		### Is it asking for a specific PID?
		if(substr($args[2], 0, 1) eq "#")
		{
			$pid = substr($args[2], 1);
			$self->TaskTerminate($oWMIService, $pid);
			
		}
		else
		{
			$title = $args[2];
			@pidArray = $self->TaskGetPID($oWMIService, $title);
			foreach $pid (@pidArray)
			{
				$self->TaskTerminate($oWMIService, $pid);
			}
		}
	}
	### If 3rd arg not set..
	else
	{
		print "\nMust specify a title or PID, use 'task list' to list all tasks\n";
	}
	
};

### Task List
sub TaskList {
	my ($self,$oWMIService,@args) = @_;
	### Is a 3rd arg set? If so..
	if($args[2])
	{
		### Is it asking for a specific PID?
		if(substr($args[2], 0, 1) eq "#")
		{
			$pid = substr($args[2], 1);
			printf("%-12s %-25s %-20s\n", "PID", "PROCESS", "MEM USAGE");
			foreach $Proc ( sort {lc $a->{Name} cmp lc $b->{Name}} in( $oWMIService->InstancesOf( "Win32_Process" ) ) )
			{
				if($Proc->{ProcessID} =~ /$pid/)
				{
					printf("%-12s %-25s %12s\n", $Proc->{ProcessID}, $Proc->{Name}, &ConvertBytes($Proc->{WorkingSetSize}));
				}
			}
		}
		else
		{
			$title = $args[2];
			printf("%-12s %-25s %-20s\n", "PID", "PROCESS", "MEM USAGE");
			foreach $Proc ( sort {lc $a->{Name} cmp lc $b->{Name}} in( $oWMIService->InstancesOf( "Win32_Process" ) ) )
			{
				if($Proc->{Name} =~ /$title/i)
				{
					printf("%-12s %-25s %-20s\n", $Proc->{ProcessID}, $Proc->{Name}, &ConvertBytes($Proc->{WorkingSetSize}));
				}
			}
		}
	}
	### If 3rd arg not set..
	else
	{
		print "\n";
		printf("%-12s %-25s %-20s\n", "PID", "PROCESS", "MEM USAGE");
		foreach $Proc ( sort {lc $a->{Name} cmp lc $b->{Name}} in( $oWMIService->InstancesOf( "Win32_Process" ) ) )
		{
			printf("%-12s %-25s %12s\n", $Proc->{ProcessID}, $Proc->{Name}, &ConvertBytes($Proc->{WorkingSetSize}));
		}
	}
};

### Get a list, or specific PID, to get the FullDetauls from
sub TaskDetail {
	my ($self,$oWMIService,@args) = @_;
	if(substr($args[2], 0, 1) eq "#")
	{
		print "\n";
		$pid = $args[2];
		$self->FullDetails($oWMIService, $pid);
	}
	else
	{
		$title = $args[2];
		@pidArray = $self->TaskGetPID($oWMIService, $title);
		foreach $pid (@pidArray)
		{
			$self->FullDetails($oWMIService, $pid);
		}
	}
}

### Return full details for a task
sub FullDetails {
	my ($self,$oWMIService,@args) = @_;
	$pid = $args[0];
	@col = in($oWMIService->ExecQuery("Select * from Win32_Process Where ProcessID = '$pid'"));
	@infos = qw(Caption CommandLine Description ExecutablePath ExecutionState Handle HandleCount InstallDate MaxWOrkingSetSize
				MinimumWorkingSetSize Name OSName PageFaults PageFileUsage ParentProcessId PeakPageFileUsage PeakVirtualSize
				PeakWorkingSetSize Priority Status TerminationDate ThreadCount VirtualSize WindowsVersion WorkingSetSize );
	foreach $objItem ( @col ) 
	{
		print "INFORMATION ON: ".$objItem->{Name}." (".$objItem->{ProcessID}.")\n";
		foreach $info (@infos)
		{
			print "$info: ".$objItem->{$info}."\n";
		}
		print "\n";
	}
}

### Kill the task by PID
sub TaskTerminate {
	my ($self,$oWMIService,@args) = @_;
	$pid = $args[0];
	@col = in($oWMIService->ExecQuery("Select * from Win32_Process Where ProcessID = '$pid'"));
	foreach $objItem ( @col ) 
	{
		if($objItem->{ProcessID} eq $pid)
		{
			#Grab PID and Process name
			print "Killing ". $objItem->{Name} ." (". $objItem->{ProcessID} .") ";
			
			# Terminate, check 10 times, every 1 second
			$objItem->{Terminate};
			sleep(1);
			$killed = 0;
			$checked = '0';
			while($killed eq 0 || $checked ne "10")
			{
				@col2 = in($oWMIService->ExecQuery("Select * from Win32_Process Where ProcessID = '$thispid'"));
				$count = 0;
				foreach $objItem2 ( @col2 ) 
				{
					$count ++;
				}
		
				if($count eq 0)
				{
					$killed = 1;
				}
				else
				{
					print ".";
					$checked++;
					sleep(1);
				}
			}
	
			if($killed eq 1)
			{
				print " Failed\n";
			}
			else
			{
				print " Success\n";
			}
		}
	}
}

### Get a specific PID from a regexed title, used for detail, or kill
sub TaskGetPID {
	my ($self,$oWMIService,@args) = @_;
	$title = $args[0];
	@pidArray = ();
	$count = 0;
	print "\nSelect the processes from below (Separated by spaces). * to select all listed. Ctrl+c to cancel\n\n";
	printf("%-12s %-25s %-20s\n", "PID", "PROCESS", "MEM USAGE");
	foreach $Proc ( sort {lc $a->{Name} cmp lc $b->{Name}} in( $oWMIService->InstancesOf( "Win32_Process" ) ) )
	{
		if($Proc->{Name} =~ /$title/i)
		{
			printf("%-12s %-25s %-20s\n", $Proc->{ProcessID}, $Proc->{Name}, &ConvertBytes($Proc->{WorkingSetSize}));
			push(@pidArray, $Proc->{ProcessID});
			$count++;
		}
	}
	if($count ne 0)
	{
		print "\n>> ";
		chomp($ids = <>);
		print "\n";
		if($ids eq '*')
		{
			return @pidArray;
		}
		else
		{
			@pidArray = ();
			@pidArray = split(/ /, $ids);
			return @pidArray;
		}
	}
	else
	{
		print "\nNothing found for '$title'\n";
		return;
	}
}

sub ConvertBytes {
	 my $bytes = shift;
	 my $size = format_bytes($bytes);
	 return $size;
}
1;
