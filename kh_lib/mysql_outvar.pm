package mysql_outvar;
use strict;

use mysql_exec;
use gui_errormsg;
use mysql_outvar::a_var;

#-----------------------------------#
#   CSV�ե����뤫���ѿ����ɤ߹���   #
#-----------------------------------#

sub read{
	my $class = shift;
	my %args  = @_;
	
	# CSV�ե������������ɤ߹���
	my @data;
	open (CSVD,$args{file}) or 
		gui_errormsg->open(
			type    => 'file',
			thefile => $args{file},
		);
	while (<CSVD>){
		chomp;
		my @line = split /,/, Jcode->new($_)->euc;
		push @data, \@line;
	}
	close (CSVD);
	
	# ���������Υ����å�
	my $cases_in_file = @data; --$cases_in_file;
	my $cases = mysql_exec->select("SELECT COUNT(*) from $args{tani}",1)
		->hundle->fetch->[0];
	unless ($cases == $cases_in_file){
		gui_errormsg->open(
			type   => 'msg',
			msg    => Jcode->new("�������������פ��ޤ���\n�ɤ߹��߽��������Ǥ��ޤ���")->sjis,
		);
		return 0;
	}
	
	# Ʊ���ѿ�̾��̵���������å�
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
				msg    => Jcode->new("Ʊ��̾�����ѿ��������ɤ߹��ޤ�Ƥ��ޤ���\n�ɤ߹��߽��������Ǥ��ޤ���")->sjis,
			);
			return 0;
		}
	}
	
	# ��¸�ѥơ��֥�̾�η���
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
	
	# DB�˥إå����Ǽ
	my $cn = 0;
	my $cols = '';
	my $cols2 = '';
	foreach my $i (@{$data[0]}){
		my $col = 'col'."$cn"; ++$cn;
		mysql_exec->do("
			INSERT INTO outvar (name, tab, col, tani)
			VALUES (\'$i\', \'$table\', \'$col\', \'$args{tani}\')
		",1);
		$cols .= "\t\t\t$col varchar(255),\n";
		$cols2 .= "$col,";
	}
	chop $cols2;
	
	# DB�˥ǡ������Ǽ
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
			$v .= "$h,";
		}
		chop $v;
		mysql_exec->do("
			INSERT INTO $table ($cols2)
			VALUES ($v)
		",1);
	}
	
	return 1;
}

#----------------------#
#   �ѿ��ꥹ�Ȥ��֤�   #
#----------------------#

sub get_list{
	my $h = mysql_exec->select("
		SELECT tani, name
		FROM outvar
		ORDER BY id
	",1)->hundle->fetchall_arrayref;
	
	return $h;
}

#----------------#
#   �ѿ�����   #
#----------------#

sub delete{
	my $class = shift;
	my %args  = @_;
	
	mysql_exec->do("
		DELETE FROM outvar
		WHERE
			    tani = \'$args{tani}\'
			AND name = \'$args{name}\'
	",1);
}


1;