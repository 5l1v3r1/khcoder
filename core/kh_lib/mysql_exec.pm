package mysql_exec;
use DBI;
use strict;
use Time::Local;
use kh_project;

# ����: MySQL�ȤΤ��Ȥ�Ϥ��٤ơ����Υ��饹���̤��ƹԤ�

# �Ȥ���:
# 	mysql_exec->[do/select]("sql","[1/0]")
# 		sql: SQLʸ
#		[1/0]: Critical(1) or not(0)

my $username = $::config_obj->sql_username;
my $password = $::config_obj->sql_password;
my $host     = $::config_obj->sql_host;
my $port     = $::config_obj->sql_port;

my $mysql_version;
my $win_9x = 0;

$username = '' unless defined ($username);
$password = '' unless defined ($password);
$host     = '' unless defined ($host);
$port     = '' unless defined ($port);

#------------#
#   DB���   #
#------------#

# ��¸DB��Connect
sub connect_db{
	my $dbname     = $_[1];
	my $no_verbose = $_[2];
	my $dsn = 
		"DBI:mysql:database=$dbname;$host;port=$port;mysql_local_infile=1";
	my $dbh = DBI->connect($dsn,$username,$password,{mysql_enable_utf8 => 1})
		or gui_errormsg->open(type => 'mysql', sql => 'Connect');

	# MySQL�ΥС����������å�
	my $t = $dbh->prepare("show variables like \"version\"");
	$t->execute;
	my $r = $t->fetch;
	$r = $r->[1] if $r;
	if ($r =~ /^(.+)\-[a-z]+$/){
		$r = $1;
	}
	if ($r =~ /^([0-9]+\.[0-9]+)\.[0-9]+/){
		$r = $1;
	}
	$mysql_version = $r;
	print "Connected to MySQL $r, $dbname.\n" unless $no_verbose;

	# OS�ΥС����������å�
	if ($::config_obj->os eq 'win32'){
		$win_9x = 1 unless Win32::IsWinNT();
	}

	# ʸ�������ɤ�����
	#if ( substr($r,0,3) > 4 ){
	#	$dbh->do("SET NAMES ujis");
	#	print "Performed \"SET NAMES ujis\"\n" unless $no_verbose;
	#}
	$dbh->do("SET NAMES utf8mb4");

	return $dbh;
}

# DB�ؤ���³�ƥ���
sub connection_test{
	# ���󥽡���ؤΥ��顼��������
	my $temp_file = 'temp.txt';
	while (-e $temp_file){
		$temp_file .= '.tmp';
	}
	open (STDERR,">$temp_file");
	
	# �ƥ��ȼ¹�
	print "Checking MySQL connection...\n";
	my $if_error = 0;
	my $dsn = 
		"DBI:mysql:database=mysql;$host;port=$port;mysql_local_infile=1";
	my $dbh = DBI->connect($dsn,$username,$password)
		or $if_error = 1;
	unless ($if_error){
		my @r = $dbh->func('_ListDBs') or $if_error = 1;
		if (@r){
			$dbh->disconnect;
		} else {
			$if_error = 1;
		}
	}

	# ���顼���������β��
	close (STDERR);
	open(STDERR,'>&STDOUT') or die;
	unlink($temp_file);
	
	if ($if_error){
		return 0;
	} else {
		return 1;
	}
}

# ����DB�κ���
sub create_new_db{
	# DB̾����
	my $drh = DBI->install_driver("mysql") or
		gui_errormsg->open(type => 'mysql',sql=>'install_driver');
	my @dbs = $drh->func($host,$port,$username,$password,'_ListDBs') or 
		gui_errormsg->open(type => 'mysql', sql => 'List DBs');
	my %dbs;
	foreach my $i (@dbs){
		$dbs{$i} = 1;
		# print "$i\n";
	}
	my $n = 0;
	while ( $dbs{"khc$n"} ){
		++$n;
	}
	my $new_db_name = "khc$n";

	# DB����
	my $dsn = 
		"DBI:mysql:database=mysql;$host;port=$port;mysql_local_infile=1";
	my $dbh = DBI->connect($dsn,$username,$password)
		or gui_errormsg->open(type => 'mysql', sql => 'Connect');

	# Check MySQL Ver.
	my $t = $dbh->prepare("show variables like \"version\"");
	$t->execute;
	my $r = $t->fetch;
	$t->finish;
	$r = $r->[1] if $r;
	print "Connected to MySQL $r. Creating new DB...\n";

	my $sql = '';
	$sql .= "create database $new_db_name";
	$sql .= " default character set utf8mb4"; # if substr($r,0,3) >= 4.1;
	$dbh->do($sql)
		or gui_errormsg->open(type => 'mysql', sql => 'Create DB');

#	$dbh->func("createdb", $new_db_name,$host,$username,$password,'admin')
#		or gui_errormsg->open(type => 'mysql', sql => 'Create DB');
	$dbh->disconnect;
	
	return $new_db_name;
}

# DB��Drop
sub drop_db{
	my $drop = $_[1];

	my $dsn = 
		"DBI:mysql:database=mysql;$host;port=$port;mysql_local_infile=1";
	my $dbh = DBI->connect($dsn,$username,$password)
		or gui_errormsg->open(type => 'mysql', sql => 'Connect');

	$dbh->func("dropdb", $drop,$host,$username,$password,'admin')
		or gui_errormsg->open(
			type => 'msg',
			msg => 'Could not delete the database from MySQL'
		);

	$dbh->disconnect;
}

# DB Server�Υ���åȥ�����

sub shutdown_db_server{
	my $dsn = 
		"DBI:mysql:database=mysql;$host;port=$port;mysql_local_infile=1";
	my $dbh = DBI->connect($dsn,$username,$password);
		#or gui_errormsg->open(type => 'mysql', sql => 'Connect');

	$dbh->func("shutdown",$host,$username,$password,'admin') if $dbh;
		#or gui_errormsg->open(type => 'mysql', sql => 'Drop DB');
		# ���Υ롼����Ͻ�λ�����ǸƤФ��ʤϤ��ˤʤΤǡ��㳰�ϥ�ɥ�󥰤�
		# �ʤ��ƽ�λ������ġ�
}

#------------------#
#   �ơ��֥����   #
#------------------#

sub drop_table{
	my $class = shift;
	my $table = shift;
	
	$::project_obj->dbh->do("DROP TABLE IF EXISTS $table");
}

sub table_exists{
	my $class = shift;
	my $table = shift;
	
	my $t = $::project_obj->dbh->prepare("SELECT * FROM $table LIMIT 1")
		or return 0;
	$t->{PrintError} = 0; # �ơ��֥뤬¸�ߤ��ʤ��ä����Υ��顼���Ϥ�����
	$t->execute or return 0;
	$t->finish;
	
	return 1;
}

#sub table_exists{
#	my $class = shift;
#	my $table = shift;
#	my $r = 0;
#	foreach my $i ( &table_list ){
#		if ($i eq $table){
#			$r = 1;
#			last;
#		}
#	}
#	return $r;
#}

sub clear_tmp_tables{
	my $class = shift;
	foreach my $i ( &table_list ){
		if ( index($i,'ct_') == 0){
			$::project_obj->dbh->do("drop table $i");
		}
	}
}

sub table_list{
	my $class = shift;
	
	my @r = map { $_ =~ s/.*\.//; $_ } $::project_obj->dbh->tables();
	foreach my $i (@r){
		$i = $1 if $i =~ /`(.*)`/;
	}
	return @r;
}

#----------------#
#   Do��Select   #
#----------------#

sub do{
	my $class = shift;
	my $self;
	$self->{sql} = shift;
	$self->{critical} = shift;
	bless $self, $class;

	$self->{sql} =~ s/TYPE\s*=\s*HEAP/ENGINE = HEAP/ig
		if $mysql_version >= 5.5;
	$self->{sql} =~ s/LOAD DATA LOCAL INFILE/LOAD DATA INFILE/
		if $win_9x; # for Win9x
	
	$self->log;

	$::project_obj->dbh->do($self->sql)
		or $self->print_error;
	return $self;
}

sub select{
	my $class = shift;
	my $self;
	$self->{sql} = shift;
	$self->{critical} = shift;
	bless $self, $class;
	
	$self->{sql} =~ s/TYPE\s*=\s*HEAP/ENGINE = HEAP/ig
		if $mysql_version >= 5.5;
	$self->{sql} =~ s/LOAD DATA LOCAL INFILE/LOAD DATA INFILE/
		if $win_9x; # for Win9x

	$self->log;
	
	my $t = $::project_obj->dbh->prepare($self->sql) or $self->print_error;
	$t->execute or $self->print_error;
	$self->{hundle} = $t;
	return $self;
}

sub selected_rows{
	my $self = shift;
	return $self->{hundle}->rows;
}

sub print_error{
	my $self = shift;
	$self->{err} =
		"SQL Input:\n".$self->sql."\nError:\n".
		$::project_obj->dbh->{'mysql_error'};
	unless ($self->critical){
		return 0;
	}
	gui_errormsg->open(type => 'mysql',sql => $self->err);
}

sub quote{
	my $class = shift;
	my $input = shift;

	return $::project_obj->dbh->quote($input);
}

sub version_number{
	my $t = $::project_obj->dbh->prepare("show variables like \"version\"");
	$t->execute;
	my $r = $t->fetch;
	$r = $r->[1] if $r;
	if ($r =~ /^([0-9]+\.[0-9]+)\./){
		$r = $1;
	}
	return $r;
}

#-------------------------------#
#   ���ե������SQLʸ��Ͽ   #
sub log{
	return 1 unless $::config_obj->sqllog;
	
	use POSIX 'strftime';
	my $self = shift;
	my $logfile = $::config_obj->sqllog_file;
	open (LOG,">>$logfile") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => "$logfile"
		);
	my $d = strftime('%Y %m/%d %H:%M:%S',localtime);
	print LOG "$d\n";
	print LOG $self->sql."\n\n";
	close LOG;
	return 1;
}
#--------------#
#   ��������   #
#--------------#
sub sql{
	my $self = shift;
	return $self->{sql};
}
sub critical{
	my $self = shift;
	return $self->{critical};
}
sub err{
	my $self = shift;
	return $self->{err};
}
sub hundle{
	my $self = shift;
	return $self->{hundle};
}
1;
