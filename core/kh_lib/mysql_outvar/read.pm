package mysql_outvar::read;
use strict;

use mysql_outvar::read::csv;
use mysql_outvar::read::tab;

sub new{
	my $class = shift;
	my %args  = @_;
	my $self = \%args;
	
	bless $self, "$class";
	return $self;
}

sub read{
	my $self = shift;
	
	# �t�@�C������������ɓǂݍ���
	my @data;
	open (CSVD,$self->{file}) or 
		gui_errormsg->open(
			type    => 'file',
			thefile => $self->{file},
		);
	while (<CSVD>){
		chomp;
		my $line = $self->parse($_);
		push @data, $line;
	}
	close (CSVD);
	
	# �P�[�X���̃`�F�b�N
	my $cases_in_file = @data; --$cases_in_file;
	my $cases = mysql_exec->select("SELECT COUNT(*) from $self->{tani}",1)
		->hundle->fetch->[0];
	unless ($cases == $cases_in_file){
		gui_errormsg->open(
			type   => 'msg',
			msg    => Jcode->new("�P�[�X������v���܂���B\n�ǂݍ��ݏ����𒆒f���܂��B")->sjis,
		);
		return 0;
	}
	
	# �����ϐ������������`�F�b�N
	my %name_check;
	my $h = mysql_exec->select("
		SELECT name
		FROM outvar
		ORDER BY id
	",1)->hundle;
	while (my $i = $h->fetch){
			$name_check{$i->[0]} = 1;
	}
	foreach my $i (@{$data[0]}){
		if ($name_check{$i}){
			gui_errormsg->open(
				type   => 'msg',
				msg    => Jcode->new("�������O�̕ϐ������ɓǂݍ��܂�Ă��܂��B\n�ǂݍ��ݏ����𒆒f���܂��B")->sjis,
			);
			return 0;
		}
	}
	
	# �ۑ��p�e�[�u�����̌���
	my $n = 0;
	while (1){
		my $table = 'outvar'."$n";
		if ( mysql_exec->table_exists($table) ){
			++$n;
		} else {
			last;
		}
	}
	my $table = 'outvar'."$n";
	
	# DB�Ƀw�b�_���i�[
	my $cn = 0;
	my $cols = '';
	my $cols2 = '';
	foreach my $i (@{$data[0]}){
		my $col = 'col'."$cn"; ++$cn;
		mysql_exec->do("
			INSERT INTO outvar (name, tab, col, tani)
			VALUES (\'$i\', \'$table\', \'$col\', \'$self->{tani}\')
		",1);
		$cols .= "\t\t\t$col varchar(255),\n";
		$cols2 .= "$col,";
	}
	chop $cols2;
	
	# DB�Ƀf�[�^���i�[
	mysql_exec->do("create table $table
		(
			$cols
			id int auto_increment primary key not null
		)
	",1);
	shift @data;
	$n = 0;
	foreach my $i (@data){
		my $v = '';
		foreach my $h (@{$i}){
			if ($v =~ /^[0-9]+$/o){
				$v .= "$h,";
			} else {
				$v .= "\'$h\',";
			}
		}
		chop $v;
		mysql_exec->do("
			INSERT INTO $table ($cols2)
			VALUES ($v)
		",1);
	}
	
	return 1;
}


1;