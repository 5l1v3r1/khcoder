package kh_projects;
use kh_project;
use strict;
use DBI;
use DBD::CSV;
use DBD::mysql;
use Jcode;

#--------------------------------------#
#   �ꥹ���ɤ߹��ߡʥ��󥹥ȥ饯����   #
#--------------------------------------#

sub read{
	my $class = shift;
	my $self;
	my $dbh = DBI->connect("DBI:CSV:f_dir=./config");
	$self->{dbh} = $dbh;
	bless $self, $class;

	# �ơ��֥뤬¸�ߤ��ʤ����Ϻ���
	my $save_file = $::config_obj->history_file;
	unless (-e $save_file){
		$self->create_project_list;
	}

	# �ɤ߹���                                    # euc-->sjis�Ѵ���
	my $st = $dbh->prepare("SELECT target,comment,dbname FROM projects")
		or die;
	$st->execute or die;
	my $n = 0;
	while (my $r = $st->fetch){
		$self->{project}[$n] =
			kh_project->temp(
				target  => Jcode->new($r->[0])->sjis,
				comment => Jcode->new($r->[1])->sjis,
				dbname  => Jcode->new($r->[2])->sjis
			);
		++$n;
	}
	return $self;
}

sub create_project_list{
	my $self = shift;
	print "creating project list... ";
	$self->dbh->do(                                 # �롼���󲽡�
		"CREATE TABLE projects (
			target CHAR(225),
			comment CHAR(225),
			dbname CHAR(225)
		)"
	) or die;
	print "ok\n";
}

#--------------------#
#   ������Ͽ����¸   #
#--------------------#

sub add_new{
	my $self = shift;
	my $new  = shift;

	# �ץ������ȡ��ơ��֥뤬¸�ߤ��ʤ����Ϻ���
	my $save_file = $::config_obj->history_file;
	unless (-e $save_file){
		$self->create_project_list;
	}

	# ���˥ե����뤬��Ͽ����Ƥ��ʤ��������å�
	foreach my $i (@{$self->list}){
		if ($i->file_target eq $new->file_target){
			gui_errormsg->open(
				type    => 'msg',
				# window  => \$win,
				msg     =>
				"���򤵤줿�ե�����ϴ��˥ץ������ȤȤ�����Ͽ����Ƥ��ޤ�"
			);
			return 0;
		}
	}

	# �ǥե���Ȥ��ʻ������������
	my $sql2 = "SELECT hinshi_id, kh_hinshi FROM hinshi_";  # �ʻ�ꥹ�ȼ���
	$sql2 .= $::config_obj->c_or_j;
	my $hst = $self->dbh->prepare($sql2) or die(dbh error 1);
	$hst->execute or die(dbh error 2);
	my $data = $hst->fetchall_arrayref or die (dbh error 3);

	# MySQL DB������
	$new->prepare_db($data);

	# �ץ������Ȥ���Ͽ
	my $sql = 'INSERT INTO projects (target, comment, dbname) VALUES (';
	$sql .= "'".$new->file_target."',";
	if ($new->comment){
		$sql .= "'".$new->comment."',";
	} else {
		$sql .= "'no description',";
		$new->comment('no description');
	}
	$sql .= "'".$new->dbname."'";
	$sql .= ')';
	$sql = Jcode->new($sql)->euc;
	$self->dbh->do($sql) or die;

	return 1;
}

#------------------#
#   �������Խ�   #
#------------------#

sub edit{
	my $self = shift;
	my $edp = $self->a_project($_[0]);

	$edp->comment($_[1]);

	my $sql = "UPDATE projects SET comment=";
	if (length($edp->comment)){
		$sql .= "'".$edp->comment."'";
	} else {
		$sql .= 'undef';
	}
	$sql .= " WHERE target = ";
	$sql .= "'".$edp->file_target."'";
	$sql = Jcode->new($sql)->euc;
	$self->dbh->do($sql) or print $sql;
}


#----------#
#   ���   #
#----------#

sub delete{
	my $self = shift;
	my $del = $self->a_project($_[0]);

	my $sql = "DELETE FROM projects WHERE target = ";
	$sql .= "'".$del->file_target."'";
	$sql = Jcode->new($sql)->euc;
	$self->dbh->do($sql) or die;

	# ����Ȣ�ơ��֥뤬¸�ߤ��ʤ����Ϻ��� 
	my $save_file = $::config_obj->history_trush_file;
	unless (-e $save_file){
		$self->dbh->do(                                 # �롼���󲽡�
			"CREATE TABLE projects_trush (
				target CHAR(225),
				comment CHAR(225),
				dbname CHAR(225)
			)"
		) or die;
	}

	# ����Ȣ�ơ��֥���ɲ�
	$sql = 'INSERT INTO projects_trush (target, comment, dbname) VALUES (';
	$sql .= "'".$del->file_target."',";
	if ($del->comment){
		$sql .= "'".$del->comment."',";
	} else {
		$sql .= "undef,";
	}
	$sql .= "'".$del->dbname."'";
	$sql .= ')';
	$sql = Jcode->new($sql)->euc;
	$self->dbh->do($sql) or die;
	
	# MySQL DB����
	mysql_exec->drop_db($del->dbname);
}



#--------------#
#   ��������   #
#--------------#
sub a_project{
	my $self = shift;
	return $self->{project}[$_[0]];
}

sub dbh{
	my $self = shift;
	return $self->{dbh};
}

sub list{
	my $self = shift;
	if (defined(@{$self->{project}})){
		return \@{$self->{project}};
	} else {
		my @hoge;
		return \@hoge;
	}
}


1;
__END__
�ץ������ȥꥹ�Ȥ�
	���ɤ߹��� �ʤ��٤�kh_project->temp��
	���Խ�
	����¸
