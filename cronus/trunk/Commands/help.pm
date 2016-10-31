package Help;
use strict;
use Psexec;
use vars qw(%commands $cmd $desc);

sub Commands {
	### HELP ARRAY
	%commands = (
				"info",		"Get information about target server (CPU info, memory info)",
				"service",	"list, stop, start, or restart a service",
				"rdp",		"Opens RDP Session with target server",
				"help", 	"Prints This Menu",
				"task",		"List or kill tasks",
				"reboot",	"Reboots target server",
				"top",		"Live report of top processes, (ctrl + c to stop)",
				"du",		"Show disk usage for all disks",
				"exit",		"Exits $0",
				"run",		"Runs any command via the server",
				"ipconfig",	"Displays the IP configuration of the server",
				"who",		"Displays active terminal sessions",
				);
	### Test for psexec, add more help items
	if(Psexec->Test())
	{
		$commands{"psexec"}	=	"Connects to target server via psexec";
		$commands{"kick"}	=	"Kick a session ID on the server";
		$commands{"msg"}	=	"Message a user on the server";
		$commands{"cons"}	=	"Luist Ports, IP's and connections, (cons -d for detailed list)";
	}

	print "\n";
	printf("%-15s %8s\n", "COMMAND", "DESCRIPTION");
	while (($cmd, $desc) = each(%commands)){
		printf("%-15s %8s\n", $cmd, $desc);
	}
	print "\nYou can get more information by adding 'help' to the end of any command\n";
	if(!Psexec->Test())
	{
		print "\nNOTE: If you download psexec (http://technet.microsoft.com/en-us/sysinternals/bb897553) and install it into your C:\\Windows\\System32\\ folder, you will have more functionality\n";
	}
}

1;
