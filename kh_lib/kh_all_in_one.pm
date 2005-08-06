package kh_all_in_one;
use strict;

#-------------------------------#
#   All In One �Ǥε�ư����λ   #
#-------------------------------#

# All In One�ǤǤϡ�
# (1)��config\coder.ini�פ˲����������ä���
#	all_in_one_pack	1
#	sql_username	khc
#	sql_password	khc
#	sql_host	localhost
#	sql_port	3307
# (2) Ʊ������MySQL������
#	�桼��������: khc[khc], root[khcallinone]
#	��khc.ini�פ�ź�դ���

# Win9x���б���

sub init{
	# ��䥤Υѥ�����
	$::config_obj->chasen_path($::config_obj->cwd.'\dep\chasen\chasen.exe')
		unless -e $::config_obj->chasen_path;
	
	# MySQL����ե����뽤����khc.ini��
	my $p1 = $::config_obj->cwd.'\dep\mysql\\';
	my $p2 = $::config_obj->cwd.'\dep\mysql\data\\';
	my $p3 = $p1; chop $p3;
	$p1 =~ s/\\/\//g;
	$p2 =~ s/\\/\//g;
	
	open (MYINI,$::config_obj->cwd.'\dep\mysql\khc.ini') or 
		gui_errormsg->open(
			type    => 'file',
			thefile => ">khc.ini"
		);
	open (MYININ,'>'.$::config_obj->cwd.'\dep\mysql\khc.ini.new') or 
		gui_errormsg->open(
			type    => 'file',
			thefile => ">khc.ini.new"
		);
	while(<MYINI>){
		chomp;
		if ($_ =~ /^basedir = (.+)$/){
			print MYININ "basedir = $p1\n";
		}
		elsif ($_ =~ /^datadir = (.+)$/){
			print MYININ "datadir = $p2\n";
		} else {
			print MYININ "$_\n";
		}
	}
	close (MYINI);
	close (MYININ);
	unlink($::config_obj->cwd.'\dep\mysql\khc.ini') or
		gui_errormsg->open(
			type    => 'file',
			thefile => ">khc.ini"
		);
	rename(
		$::config_obj->cwd.'\dep\mysql\khc.ini.new',
		$::config_obj->cwd.'\dep\mysql\khc.ini'
	) or gui_errormsg->open(
			type    => 'file',
			thefile => ">khc.ini.new"
	);

	# MySQL�ε�ư
	return 1 if mysql_exec->connection_test;
	print "Starting mysql...\n";
	use Win32;
	use Win32::Process;
	my $obj;
	my ($mysql_pass, $cmd_line);
	
	if ( Win32::IsWinNT() ){
		$mysql_pass = $::config_obj->cwd.'\dep\mysql\bin\mysqld-nt.exe';
		$cmd_line = 'bin\mysqld-nt --defaults-file=khc.ini';
	} else {
		$mysql_pass = $::config_obj->cwd.'\dep\mysql\bin\mysqld-opt.exe';
		$cmd_line = 'bin\mysqld-opt --defaults-file=khc.ini';
	}
	Win32::Process::Create(
		$obj,
		$mysql_pass,
		$cmd_line,
		0,
		'CREATE_NO_WINDOW',
		$p3,
	) or gui_errormsg->open(
		type => 'mysql',
		sql  => 'Start'
	);
	return 1;
}

sub mysql_stop{
	mysql_exec->shutdown_db_server;
	#system 'c:\apps\mysql\bin\mysqladmin --port=3307 --user=root --password=khcallinone shutdown';
}

1;