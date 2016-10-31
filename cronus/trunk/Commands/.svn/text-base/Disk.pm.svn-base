package Disk;
use feature qw(switch say);
use strict;
#use Data::Dumper;
use Win32::OLE('in');
use Number::Bytes::Human qw(format_bytes);
use POSIX qw/floor/;

use constant bFlagReturnImmediately => 0x10;
use constant bFlagForwardOnly => 0x20;

use vars qw($oWMIService $colItems $objItem @infos $info @array_infos @col);

# http://msdn.microsoft.com/en-us/library/aa394217%28v=VS.85%29.aspx

### Task Dispatch
sub Usage {
	my ($self,$oWMIService,@args) = @_;
	@col = in($oWMIService->ExecQuery("SELECT * FROM Win32_LogicalDisk"));
	foreach $objItem ( @col ) 
	{
		print "\n";
		print "Drive: ". $objItem->{Name}."\n";
		print "Status: ". $objItem->{Status}."\n";
		print "Size: ". ConvertBytes($objItem->{Size})."\n";
		print "Free Space: ". ConvertBytes($objItem->{FreeSpace})."\n";			
	}
}

sub ConvertBytes {
	 my $bytes = shift;
	 my $size = format_bytes($bytes);
	 return $size;
}
1;
