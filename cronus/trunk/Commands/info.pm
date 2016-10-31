package Info;
use strict;
use vars qw($oWMIService $colItems $objItem @infos $info @array_infos);
#use Data::Dumper;
use Win32::OLE('in');

use constant bFlagReturnImmediately => 0x10;
use constant bFlagForwardOnly => 0x20;

sub Details {
	print "\n";
	$colItems = $_[1]->ExecQuery ( "SELECT * FROM Win32_ComputerSystem", "WQL", bFlagReturnImmediately | bFlagForwardOnly);
	foreach $objItem (in $colItems)
	{
		@infos = qw(AdminPasswordStatus AutomaticResetBootOption AutomaticResetCapability BootOptionOnLimit BootOptionOnWatchDog 
						BootROMSupported BootupState Caption ChassisBootupState CreationClassName CurrentTimeZone DaylightInEffect
						Description Domain DomainRole EnableDaylightSavingsTime FrontPanelResetStatus InfraredSupported InitialLoadInfo
						InstallDate KeyboardPasswordStatus LastLoadInfo Manufacturer Model Name NameFormat NetworkServerModeEnabled
						NumberOfProcessors OEMLogoBitmap OEMStringArray PartOfDomain PauseAfterReset PowerManagementCapabilities
						PowerManagementSupported PowerOnPasswordStatus PowerState PowerSupplyState PrimaryOwnerContact PrimaryOwnerName
						ResetCapability ResetCount ResetLimit Roles Status SupportContactDescription SystemStartupDelay SystemStartupOptions
						SystemStartupSetting SystemType ThermalState TotalPhysicalMemory UserName WakeUpTime Workgroup);

		@array_infos = qw(InitialLoadInfo OEMLogoBitmap OEMStringArray PowerManagementCapabilities Roles SupportContactDescription SystemStartupOptions);
		
		foreach $info ( @infos )
		{
			if(grep $_ eq $info, @array_infos)
			{
				printf("%-28s %-8s\n", $info, join(",", (in $objItem->{$info})));
			}
			else
			{
				printf("%-28s %-8s\n", $info, $objItem->{$info});
			}
		}
	}
}

1;
