package task;
use strict;

### SUB: TASK
sub task
{
	### Task Given/Switch (list kill or help)
	given($commands[1])
	{
		when (['l', 'list', 'lst']) { &TaskList; }
		when (['k', 'kill'])		{ &TaskKill; }
		when (['h', 'help', '?'])	{ &TaskHelp; }
		default						{ print "\ntask h for help\n"; }
	}
	
	### Task Help
	sub TaskHelp
	{
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
		print "\n\tKill All Tasks With 'win' in title:\n";
		print "\t\t'task kill win', 'task k win', 'tsk k win'\n";
		print "\n\tKill Task(s) with PID(s)\n";
		print "\t\t'task kill 99', 'task k 99', 'tsk k 99 88', 'task kill 99 88'\n";
	}
	
	### Task Kill
	sub TaskKill
	{
		print "\nKilling Task\n";
	}
	
	### Task List
	sub TaskList
	{
		### Is a 3rd arg set? If so..
		if($commands[2])
		{
			### Is it asking for a specific PID?
			if(substr($commands[2], 0, 1) eq "#")
			{
				print "\nPID\n";
			}
			else
			{
				print "\ntitle\n";
			}
		}
		### If 3rd arg not set..
		else
		{
			print "\nListing All\n";
		}
	}
}
