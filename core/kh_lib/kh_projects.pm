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
	my $st = $dbh->prepare("SELECT * FROM projects");
	$st->execute;
	my $n = 0;
	while (my $r = $st->fetchrow_hashref){
		$self->{project}[$n] =
			kh_project->temp(
				target  => Jcode->new($r->{target})->sjis,
				comment => Jcode->new($r->{comment})->sjis,
				dbname  => Jcode->new($r->{dbname})->sjis
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
				window  => \$::main_gui->{w_new_pro},
				msg     =>
				"���򤵤줿�ե�����ϴ��˥ץ������ȤȤ�����Ͽ����Ƥ��ޤ�"
			);
			return 0;
		}
	}

	# DB����
	my $drh = DBI->install_driver("mysql")
		or gui_errormsg->open(type => 'mysql');
	$drh->func('createdb', $new->dbname,'','','','admin')
		or gui_errormsg->open(type => 'mysql', sql => 'createdb');

	# �ǥե���Ȥ��ʻ�����ơ��֥�����
	my $sql2 = "SELECT hinshi_id, kh_hinshi FROM hinshi_";  # �ʻ�ꥹ�ȼ���
	$sql2 .= $::config_obj->c_or_j;
	my $hst = $self->dbh->prepare($sql2) or die(dbh error 1);
	$hst->execute or die(dbh error 2);
	my $data = $hst->fetchall_arrayref or die (dbh error 3);

	my $temp_new = $new->dbname;                            # MySQL�ơ��֥����
	my $mysql = DBI->connect("DBI:mysql:$temp_new",undef,undef)
		or gui_errormsg->open(type => 'mysql', sql => 'connect');
	my $sql3 = 'create table hselection(
		khhinshi_id int primary key not null,
		ifuse       int,
		name        varchar(20) not null
	)';
	$mysql->do($sql3) or
		gui_errormsg->open(type =>'mysql', sql =>'create table hselection');

	my $sql4 = "INSERT INTO hselection (khhinshi_id,ifuse,name)\nVALUES ";
	my %temp_h;                                             # MySQL�ơ��֥�ؤΥ��󥵡���
	foreach my $i (@{$data}){
		if ($temp_h{$i->[0]}){
			next;
		} else {
			$temp_h{$i->[0]} = 1;
		}
		if ($i->[1] eq "ʣ��̾��"){
			$sql4 .= "($i->[0],0,'$i->[1]'),";
		} 
		elsif ($i->[1] eq "HTML����"){
			$sql4 .= "($i->[0],0,'$i->[1]'),";
		} else {
			$sql4 .= "($i->[0],1,'$i->[1]'),";
		}
	}
	$sql4 .= "(9999,0,'����¾')";
	$mysql->do($sql4) or 
		gui_errormsg->open(type =>'mysql', sql => 'INSERT INTO hselection');

	# ����ơ��֥�κ���
	$mysql->do('create table dmark ( name varchar(200) not null )') or die;
	$mysql->do('create table dstop ( name varchar(200) not null )') or die;
	# ���֥ơ��֥�κ���
	$mysql->do('
		create table status (
			name   varchar(200) not null,
			status INT not null
		)
	');
	$mysql->do("
		INSERT INTO status (name, status)
		VALUES ('morpho',0),('bun',0),('dan',0),('h5',0),('h4',0),('h3',0),('h2',0),('h1',0)
	");

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
