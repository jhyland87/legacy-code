package Network;
#use feature qw(switch say);
use strict;
#use Data::Dumper;
use Win32::OLE('in');

use constant bFlagReturnImmediately => 0x10;
use constant bFlagForwardOnly => 0x20;

use vars qw($oWMIService $colItems $objItem @infos $info @array_infos);

# http://msdn.microsoft.com/en-us/library/aa394217%28v=VS.85%29.aspx

sub ipconfig {
	print "\nWindows IP Configuration\n\n";
	$colItems = $_[1]->ExecQuery ( "SELECT * FROM Win32_NetworkAdapterConfiguration", "WQL", bFlagReturnImmediately | bFlagForwardOnly);
	foreach $objItem (in $colItems)
	{
		@infos = qw(Caption IPAddress IPSubnet MACAddress DefaultIPGateway DNSHostName DNSDomain DHCPServer DHCPEnabled Description DNSServerSearchOrder ServiceName KeepAliveTime KeepAliveInterval InterfaceIndex MTU);

		@array_infos = qw(IPAddress IPSubnet DefaultIPGateway DNSServerSearchOrder);
		
		foreach $info ( @infos )
		{
			if($objItem->{'IPEnabled'} eq 1 && $objItem->{$info})
			{
				if(grep $_ eq $info, @array_infos)
				{
					printf("%-20s %-8s\n", $info, join(",", (in $objItem->{$info})));
					#print Dumper($objItem->{$info});
				}
				else
				{
					printf("%-20s %-8s\n", $info, $objItem->{$info});
				}
			}
		}
	}
}

1;
