#!/usr/bin/perl
use strict;
#use warnings;
use Getopt::Long;
use Data::Dumper;
use feature qw(switch say);
use File::Basename;

### Use custom modules
use lib "U:\\perl\\scripts\\work\\Cronus\\Commands";
use Task;
use Info;
use Disk;
use Help;
use Top;
use Service;
use Network;
use Psexec;
use Run;
use Reboot;

use vars qw($result $help $server $username $password $ad $command $locator $oWMIService $debug $err @aa $aa $commands @commands $psexec $stdout $stderr);

### HEADER
my $progTitle = "Cronus";
my $email = "J\@adminreference.com";
my $website = "http://adminreference.com/";
my $version = "v1.0";
my $alias = "J";
my $progName = basename($0);
print "\n$progTitle ($version), by $alias ($website - $email)\n\n";


### NO ^C!
$SIG{INT} = \&INTERRUPT;
sub INTERRUPT 
{
	print "\n";
	&MAINLOOP;
}

### Get Arguements, use environment username for default username
$username = $ENV{'USERNAME'};
$result = GetOptions (
                        'help|?'        	=> \$help,
                        "server=s"      	=> \$server,	# REQUIRED
                        "username=s" 		=> \$username,	# REQUIRED
                        "password=s"		=> \$password,
                        "debug"				=> \$debug,
                        "activedirectory"	=> \$ad
                        ) or exit($!); # Chances are, this will only happen if they specify an arguement with no value

### Help Menu for CLI Initiation
if($help) 
{
	&CLI_HELP;
	exit;
}

### No server set?
if(!$server) 
{
	print "ERROR: Please specify a server.\n\n";
	&CLI_HELP;
	exit;
}

### CLI Help Menu: This is whats shown if the program fails to launch
sub CLI_HELP {
	print "HELP MENU\n\n";
	print "\t-s\tServer To Connect To via WMI [Required]\n";
	print "\t-u\tUsername [Default: $username]\n";
	print "\t-p\tPassword, only required if -u implemented\n";
	print "\t-d\tEnable Debugging\n";
	print "\t-a\tUse Active Directory Login\n";
	print "\n";
	print "Example Usage:\n\n";
	print "Logging into remote server with administrator credentials\n";
	print "\t$progName -u administrator -p xxxxxxx -s serverName\n\n";
	print "Logging into remote server as local AD user\n";
	print "\t$progName -s serverName -a\n\n";
	print "Logging into localhost (Must add -a switch for localhost, login locally with un/pw is not allowed)\n";
	print "\t$progName -s localhost -a\n";
}

### Are they trying to connect with active directory? If so.. 
if($ad) 
{
	### Connect to $servers WMI..
	$oWMIService = Win32::OLE->GetObject( "winmgmts:\\\\$server\\root\\CIMV2")
		or die "WMI connection failed.\n";	
	### Did it work? COOL! Go to the loop
	print "Connected to $server... \n\n";
	print "type 'h' for help.\n";	
	&MAINLOOP;
}
### If not..
else 
{
	$| = 1;
	if($debug)
	{
		Win32::OLE->Option(Warn => 9);
	}
	$locator = Win32::OLE->CreateObject('WbemScripting.SWbemLocator') 
		or die "WMI connection failed.\n";	
		
	$oWMIService = $locator->ConnectServer($server, "root\\CIMV2", $username, $password) 
		or die "WMI logon failed. \n";
		print "CONNECTED";	
}


### MAIN Dispatch Loop! Sweetness
sub MAINLOOP 
{
	my ($self,@args) = @_;
	while() 
	{
		print "\n$server> ";
		
		chomp($command = <>);
		@commands = split(/ /, $command);
		given($commands[0])
		{
			when ('about')					{ &About; }
			when (['ifconfig', 'ipconfig'])	{ Network->ipconfig($oWMIService); }
			when (['service', 'svc'])		{ Service->ServiceMain($oWMIService, @commands); }
			when ('top')					{ Top->Watch($oWMIService); }
			when ('du')						{ Disk->Usage($oWMIService); }
			when (['help','h','?','-h'])	{ Help->Commands; }
			when ('info')					{ Info->Details($oWMIService); }
			when (['task', 'tsk'])			{ Task->TaskMain($oWMIService, @commands); }
			when (['reboot', 'restart'])	{ Reboot->Main($oWMIService, @commands); }
			when (['run', 'exec'])			{ Run->Main($oWMIService, @commands); }
			when (['q', 'exit', 'quit']) 	{ &Exit; }
			when (['cls', 'clear', 'c'])	{ system("cls"); }
			default							{ print "\nh for help\n"; }
		}
	}
}

sub Exit
{
	print "\nbye bye..\n";
	exit;
}

sub About 
{
	print "\nAbout $progTitle ($version)\n\nCreated by $alias ($email)\n\n";
	print "Pretty simple really, basically a command line tool for managing windows computers (Desktops and Servers), remotely or locally, with either user credentials or AD authentication.\n\n";
	print "The program relies on the WMI Service (Windows Management Instrumentation) mostly. Some commands will try to execute with PSexec, and if failed, will attempt to execute with WMI queries.";
	print "If you have psexec (downloaded from http://technet.microsoft.com/en-us/sysinternals/bb897553), in your C:\\Windows\\System32\\ then you will be able to execute more commands.";
	print "If you do not have psexec installed, some commands will operate differently, or not be able to run at all (and will not show in the help menu).\n\n";
	print "Please direct your questions to $email, or visit the website at $website\n\n";
}
