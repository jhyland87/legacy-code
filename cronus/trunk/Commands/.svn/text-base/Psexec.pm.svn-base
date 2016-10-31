package Psexec;
use feature qw(switch say);
use strict;
#use Data::Dumper;

use vars qw($command $stdout $stderr);

### Task psexec (will return false boolean if `psexec` fails
sub Test {
	$command = 'psexec';
	close STDERR;

	$stdout = do {
		open(local *STDERR, ">", \$stderr) or die "Could not capture STDERR: $!";
			`$command`;
	};
				
	if(!$stdout)
	{
		return 0;
	} 
	else 
	{
		return 1;
	}
}

1;
