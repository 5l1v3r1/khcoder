package kh_cod::search;
use base qw(kh_cod);
use strict;

use mysql_exec;

my %sql_join = (
	'bun' =>
		'bun.id = bun_r.id',
	'dan' =>
		'
			    dan.dan_id = bun.dan_id
			AND dan.h5_id = bun.h5_id
			AND dan.h4_id = bun.h4_id
			AND dan.h3_id = bun.h3_id
			AND dan.h2_id = bun.h2_id
			AND dan.h1_id = bun.h1_id
		',
	'h5' =>
		'
			    h5.h5_id = bun.h5_id
			AND h5.h4_id = bun.h4_id
			AND h5.h3_id = bun.h3_id
			AND h5.h2_id = bun.h2_id
			AND h5.h1_id = bun.h1_id
		',
	'h4' =>
		'
			    h4.h4_id = bun.h4_id
			AND h4.h3_id = bun.h3_id
			AND h4.h2_id = bun.h2_id
			AND h4.h1_id = bun.h1_id
		',
	'h3' =>
		'
			    h3.h3_id = bun.h3_id
			AND h3.h2_id = bun.h2_id
			AND h3.h1_id = bun.h1_id
		',
	'h2' =>
		'
			    h2.h2_id = bun.h2_id
			AND h2.h1_id = bun.h1_id
		',
	'h1' =>
		'h1.h1_id = bun.h1_id'
);

sub new{
	my $class = shift;
	my $self;
	$self->{dummy} = '0';
	
	bless $self, $class;
	
	return $self;
}

#------------------------------#
#   ľ�����ϥ����ɤ��ɤ߹���   #

sub add_direct{
	my $self = shift;
	my %args = @_;
	
	# �����ɲä���Ƥ������Ϥ��ä�����
	if ($self->{codes}){
		if ($self->{codes}[0]->name eq 'ľ������'){
			print "Delete old \'direct\'\n";
			shift @{$self->{codes}};
		}
	}
	
	if ($args{mode} eq 'code'){                   #��code�פξ��
		unshift @{$self->{codes}}, kh_cod::a_code->new(
			'ľ������',
			Jcode->new($args{raw})->euc
		);
	} else {                                      # ��AND��,��OR�פξ��
		$args{raw} = Jcode->new($args{raw})->tr('��',' ')->euc;
		$args{raw} =~ tr/\t\n/  /;
		my ($n, $t) = (0,'');
		foreach my $i (split / /, $args{raw}){
			unless ( length($i) ){next;}
			if ($n){$t .= " $args{mode} ";}
			$t .= "$i";
			++$n;
		}
		unshift @{$self->{codes}}, kh_cod::a_code->new(
			'ľ������',
			$t
		);
	}

}

#----------------#
#   �����μ¹�   #

sub search{
	my $self = shift;
	my %args = @_;
	
	$self->{tani} = $args{tani};
	
	# ��ꤢ���������ǥ���
	print "kh_cod::search -> coding...\n";
	foreach my $i (@{$args{selected}}){
		my $res_table = "ct_$args{tani}"."_code_$i";
		$self->{codes}[$i]->ready($args{tani}) or next;
		$self->{codes}[$i]->code($res_table) or next;
		if ($self->{codes}[$i]->res_table){
			push @{$self->{valid_codes}}, $self->{codes}[$i];
		}
	}
	
	# AND���λ��ˡ�0�����ɤ�¸�ߤ�������return
	unless ($self->{valid_codes}){
		return undef;
	}
	if (
		   ( $args{method} eq 'and' )
		&& ( @{$self->{valid_codes}} < @{$args{selected}} )
	) {
		return undef;
	}
	
	# ���פ���ʸ��Υꥹ�Ȥ����
	print "kh_cod::search -> searching...\n";
	my $sql = "SELECT $args{tani}.id\nFROM $args{tani}\n";
	foreach my $i (@{$self->tables}){
		$sql .= "LEFT JOIN $i ON $args{tani}.id = $i.id\n";
	}
	$sql .= "WHERE\n";
	my $n = 0;
	foreach my $i (@{$self->valid_codes}){
		if ($n){ $sql .= "$args{method} "; }
		$sql .= "IFNULL(".$i->res_table.".".$i->res_col.",0)\n";
		++$n;
	}
	my $sth = mysql_exec->select($sql,1)->hundle;
	
	my @result;
	print "kh_cod::search -> fetching";
	while (my $i = $sth->fetch){
		push @result, [
			$i->[0],
			kh_cod::search->get_doc_head($i->[0],$args{tani})
		];
		print ".";
	}
	print "\n";
	
	# ���������Ѥ������ɽ�ءˤΥꥹ��
	print "kh_cod::search -> getting word list...\n";
	my (@words, %words);
	foreach my $i (@{$self->{valid_codes}}){
		if ($i->hyosos){
			foreach my $h (@{$i->hyosos}){
				++$words{$h};
			}
		}
	}
	@words = (keys %words);
	
	# �����ǥ��󥰷�̤򥯥ꥢ
	foreach my $i (@{$self->{codes}}){
		$i->clear;
	}
	$self->{valid_codes} = undef;
	
	return (\@result,\@words);
}

#-----------------------------------------#
#   1�Ĥ�ʸ���Ϳ����줿�����ɤΥꥹ��   #

sub check_a_doc{
	my $self   = shift;
	my $doc_id = shift;
	
	my $table = "$self->{tani}"."tmp";
	
	# �����ǥ��󥰷�̤򥯥ꥢ
	foreach my $i (@{$self->{codes}}){
		$i->clear;
	}
	foreach my $i (mysql_exec->table_list){
		if ( index($i, $table) > -1 ){
			mysql_exec->drop_table($i);
		}
	}
	
	# �ơ��֥����
	mysql_exec->drop_table($table);                         # CREATE
	my $sql;
	$sql .= "CREATE TABLE $table (\n";
	$sql .= "ID int primary key not null,\n";
	foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
		$sql .= "$i"."_id int,\n";
		if ($i eq $self->{tani}){last;}
	}
	chop $sql; chop $sql; $sql .= "\n";
	$sql .= ") TYPE = HEAP";
	mysql_exec->do($sql,1);
	
	$sql = '';                                              # INSERT
	$sql .= "INSERT INTO $table (id,";
	foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
		$sql .= "$i"."_id,";
		if ($i eq $self->{tani}){last;}
	}
	chop $sql;
	$sql .= ")\n";
	$sql .= "SELECT id,";
	foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
		$sql .= "$i"."_id,";
		if ($i eq $self->{tani}){last;}
	}
	chop $sql;
	$sql .= "\n";
	$sql .= "FROM $self->{tani}\n";
	$sql .= "WHERE id = $doc_id\n";
	mysql_exec->do($sql,1);
	
	# �����ǥ���
	my $text = "������ʸ��˥ҥåȤ��������� �ʸ��߳����Ƥ��륳���ǥ��󥰡��롼��ե��������ǡ�\n";
	foreach my $i (@{$self->{codes}}){
		print ".\n";
		unless ($i->{condition}){next;}
		unless ($i->{row_condition}){next;}
		$i->ready($table) or next;
		$i->code('temp') or next;
		if ($i->res_table){
			$text .= "    ".$i->name."\n";
		}
	}
	
	$text = Jcode->new($text)->sjis;
	return $text;
}


#--------------------------#
#   ʸ�����Ƭ��ʬ�����   #

sub get_doc_head{
	my $self = shift;
	my $id   = shift;
	my $tani = shift;
	
	my $sql;
	if ($tani eq 'bun'){
		$sql = "
			SELECT rowtxt
			FROM bun_r, bun
			WHERE
				    bun_r.id = bun.id
				AND bun.id = $id
		";
	} else {
		$sql = "
			SELECT rowtxt
			FROM bun_r, bun, $tani
			WHERE $sql_join{$tani}
				AND bun_r.id = bun.id
				AND $tani.id = $id
			LIMIT 5
		";
	}
	
	my $sth = mysql_exec->select($sql,1)->hundle;
	
	my $r;
	while (my $i = $sth->fetch){
		$r .= $i->[0];
		if (length($r) > $::config_obj->DocSrch_CutLength){
			last;
		}
	}
	
	# �ڤ���Ȥ�
	if (length($r) > $::config_obj->DocSrch_CutLength){
		my $len = $::config_obj->DocSrch_CutLength;
		if (
			substr($r,0,$len) =~ /\x8F$/
			or substr($r,0,$len) =~ tr/\x8E\xA1-\xFE// % 2 
		){
			--$len;
			if (
				substr($r,0,$len) =~ /\x8F$/
				or substr($r,0,$len) =~ tr/\x8E\xA1-\xFE// % 2 
			){
				--$len;
			}
		}
		$r = substr($r,0,$len);
		$r .= '��';
	}
	
	return $r;
	
}



1;