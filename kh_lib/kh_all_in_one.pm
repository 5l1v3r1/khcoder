package kh_all_in_one;
use strict;

#----------------------------------------------#
#   All In One �Ǥ˴ޤޤ��MySQL�ε�ư����λ   #
#----------------------------------------------#

sub mysql_start{
	print "starting mysql...\n";
	use Win32;
	use Win32::Process;	
	my $obj;
	Win32::Process::Create(
		$obj,
		'c:\apps\mysql\bin\mysqld-nt.exe',
		'mysqld-nt --defaults-file=khc.ini',
		0,
		'CREATE_NO_WINDOW',
		'c:\apps\mysql',
	);
}
sub mysql_stop{
	print "shutting down mysql....\n";
	system 'c:\apps\mysql\bin\mysqladmin --port=3307 --user=root --password=khcallinone shutdown';
}

1;