package mysql_exec;
use DBI;
use strict;
use Time::Local;
use Time::CTime;    # Time-modules��Ʊ��
use kh_project;

# Usage:
# 	mysql_exec->[do/select]("sql","[1/0]")
# 		sql: SQLʸ
#		[1/0]: Critical(1) or not(0)

sub drop_table{
	my $class = shift;
	my $table = shift;
	
	$::project_obj->dbh->do("DROP TABLE IF EXISTS $table");
}

sub do{
	my $class = shift;
	my $self;
	$self->{sql} = shift;
	$self->{critical} = shift;
	bless $self, $class;

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
	
	$self->log;
	
	my $t = $::project_obj->dbh->prepare($self->sql);
	$t->execute or $self->print_error;
	$self->{hundle} = $t;
	return $self;
}

sub print_error{
	my $self = shift;
	$self->{err} = "SQL����:\n".$self->sql."\n���顼����:\n"."$DBD::mysql::errstr";
	unless ($self->critical){
		return 0;
	}
	gui_errormsg->open(type => 'mysql',sql => $self->err);
}




#-------------------------------#
#   ���ե������SQLʸ��Ͽ   #
sub log{
	unless ($::config_obj->sqllog){
		return 1;
	}
	
	my $self = shift;
	my $logfile = $::config_obj->sqllog_file;
	open (LOG,">>$logfile") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => "$logfile"
		);
	my $d = strftime("%Y %m/%d %T",localtime);
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
