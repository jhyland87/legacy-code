package Top;
#use strict;
use vars qw($oWMIService $colItems $objItem @infos $info $err $server @aa);
use Data::Dumper;
use Win32::OLE('in');
use Number::Bytes::Human qw(format_bytes);
use POSIX qw/floor/;

use constant bFlagReturnImmediately => 0x10;
use constant bFlagForwardOnly => 0x20;

sub ConvertBytes {
	 my $bytes = shift;
	 my $size = format_bytes($bytes);
	 return $size;
}

sub Watch {
	my ($self,$oWMIService,@args) = @_;
	my $sleep = 3;
	
	WATCH_START:
	
	# GET PROCESSOR INFORMATION
	#my @col = in($oWMIService->ExecQuery("SELECT * FROM Win32_Processor", "WQL", wbemFlagReturnImmediately | wbemFlagForwardOnly));
	my @col = in($oWMIService->ExecQuery("SELECT * FROM Win32_Processor"));
	
	foreach $objItem ( @col )
	{
		system ("cls");
		print "CPU: LoadPercentage: ". $objItem->{LoadPercentage} ."%\n";
	}
	# GET MEMORY INFORMATION
	@col = in($oWMIService->ExecQuery("Select * from Win32_OperatingSystem"));
	print "MEM: ";
	foreach my $objItem ( @col )
	{
		my $total_physical 	= &ConvertBytes($objItem->{TotalVisibleMemorySize});
		my $free_physical	= &ConvertBytes($objItem->{FreePhysicalMemory});
		my $total_virtual	= &ConvertBytes($objItem->{TotalVirtualMemorySize});
		my $free_virtual	= &ConvertBytes($objItem->{FreeVirtualMemory});
		my $used_mem		= &ConvertBytes($objItem->{TotalVisibleMemorySize} - $objItem->{FreePhysicalMemory});
		my $used_mem2		= $objItem->{TotalVisibleMemorySize} - $objItem->{FreePhysicalMemory};
		my $total_physical2	= $objItem->{TotalVisibleMemorySize};
		my $mem_percent 	= $used_mem2 / $total_physical2  * 100;
		
		$mem_percent	= floor($mem_percent);
		
		printf("%-5s %-20s %-25s %-25s\n",  $mem_percent."%,", $total_physical . " Total,", $free_physical . " Free Physical,", $free_virtual . " Free Virtual");
	}
	
	# SHOW TOP 10 PROGRAMS USING MEMORY
	print "\n\tTop 10 memory usage programs\n";
	
	#@col = in($oWMIService->ExecQuery("SELECT * FROM Win32_Process WHERE WorkingSetSize > 20000000", "WQL", wbemFlagReturnImmediately | wbemFlagForwardOnly)) or $err = 1;
	@col = in($oWMIService->ExecQuery("SELECT * FROM Win32_Process WHERE WorkingSetSize > 20000")) or $err = 1;
	
	if($err eq 1)
	{
		print "\n\nUnable to view Win32_Process on ".$server;
	}
	 else 
	{
		@aa = ();
		foreach my $objItem ( @col )
		{
			my $memory = $objItem->{WorkingSetSize}/1024;
			push @aa, [$objItem->{ProcessId}, $objItem->{ParentProcessId}, $objItem->{WorkingSetSize}, $memory, $objItem->{Caption}];
			#print $objItem->{ProcessId};
		}
		
		@aa = sort{my $b->[3] <=> my $a->[3]} @aa;
		my $current 	= 0;
		my $list 		= 20;
					
		print "\n";
		printf("%-6s %-6s %-15s %-10s %-15s %-10s\n", "PID", "PPID", "Time", "Mem (M)", "Name");
		print "\n";
		while ($current < $list)
		{
			printf("%-6s %-6s %-15s %-10s %-15s %-10s\n", $aa[$current][0], $aa[$current][1], $aa[$current][2], $aa[$current][3], $aa[$current][4]);
			$current++;
		}
	}
	$#aa = -1;
	sleep($sleep);
	
	goto WATCH_START;
}
1;
