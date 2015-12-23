package kh_cod::a_code;
use kh_cod::a_code::atom;
use gui_errormsg;
use mysql_exec;
use strict;

my $debug = 0;

#----------------------#
#   �����ǥ��󥰼¹�   #

sub code{
	my $self           = shift;
	$self->{res_table} = shift;
	$self->{sort}      = shift;
	$self->{if_done}   = 1;

	print "* Coding: Checking conditions...\n" if $debug;
	print "\tres_table: $self->{res_table}\n" if $debug;
	unless ($self->{condition}){
		$self->{res_table} = '';
		return 0;
	}
	unless ($self->{row_condition}){
		$self->{res_table} = '';
		return 0;
	}
	unless ($self->tables){
		$self->{tables} = [];
	}

	# ����å����̵ͭ������å�
	my $raw = $self->{ed_condition};
	$raw =~ s/'/\\'/g;
	my $kind = 'code';
	if (defined($self->{sort}) && $self->{sort} eq 'tf*idf'){
		$kind .= '_idf_m';
	}
	elsif (defined($self->{sort}) && $self->{sort} eq 'tf/idf'){
		$kind .= '_idf_d';
	}
	my $tani = $self->{tani};
	my @c_c = kh_cod::a_code->cache_check(
		tani => $tani,
		kind => $kind,
		name => $raw
	);
	my $cache_table = "ct_$tani"."_ccode_"."$c_c[1]";

	#print "1st: $c_c[0]\n";
	#print "2nd: $c_c[1]\n";
	#print "table: $cache_table\n";
	print "\tcache found[1]\n" if $c_c[0] && $debug;

	# ����å��夬̵�����Ϥޤ�����å�������
	unless ($c_c[0]){

		mysql_exec->drop_table($cache_table);               # �ơ��֥����
		mysql_exec->do("
			CREATE TABLE $cache_table (
				id int not null primary key,
				num float
			)
		",1);

		my $sql = '';                                       # �������å�
		$sql .= "INSERT INTO $cache_table (id, num)\n";
		$sql .= "SELECT $self->{tani}.id, ";
		my $nn = 0;
		foreach my $i (@{$self->{condition}}){
			if ($nn){ $sql .= " + "; } else { $nn = 1; }
			$sql .= $i->num_expr($self->{sort});
		}
		$sql .= "\n";
		$sql .= "FROM $self->{tani}\n";
		foreach my $i (@{$self->tables}){
			unless ($i){next;}
			$sql .= "\tLEFT JOIN $i ON $self->{tani}.id = $i.id\n";
		}
		$sql .= "WHERE\n";
		foreach my $i (@{$self->{condition}}){
			$sql .= "\t".$i->expr()."\n";
		}
		
		my $error_flag = 0;                                 # ���顼�����å�
		my $check = mysql_exec->do($sql);
		if ($check->err){
			gui_errormsg->open(
				type => 'msg',
				msg  =>
					Jcode->new( kh_msg->get('syntax_error') )->euc#"�����ǥ��󥰡��롼��ν񼰤˸�꤬����ޤ�����\n����ޤॳ���ɡ� "
					.$self->name."\n".$check->err
			);
			$error_flag = 1;
		}
		unless ($error_flag){
			my $check2 = mysql_exec->select(
				"SELECT * FROM $cache_table LIMIT 1"
			)->hundle;
			unless (my $ch = $check2->fetch){
				$self->{res_table} = '';
				$error_flag = 1;
			}
		}
		
		my $words = '';                                     # ����å������Ͽ
		my $n =0;
		foreach my $i (@{$self->{hyosos}}){
			$words .= "\t" if $n;
			$words .= $i;
			++$n;
		}
		$words = '-1' if $error_flag;
		$self->cache_regist(
			tani   => $tani,
			kind   => $kind,
			name   => $raw,
			hyosos => $words,
		);
	}
	
	# ����å����$self->{res_table}�˥��ԡ�
	my $chk = $self->cache_code_if_ok(
			tani   => $tani,
			kind   => $kind,
			name   => $raw,
	);
	unless ($chk){
		print "\nthis is an error code (cache)!\n" if $debug;
		$self->{res_table} = '';
		return 0;
	}

	mysql_exec->drop_table($self->{res_table});
	mysql_exec->do("
		CREATE TABLE $self->{res_table} (
			id int not null primary key,
			num float
		) type = heap
	",1);
	mysql_exec->do("
		INSERT INTO $self->{res_table} (id, num)
		SELECT id, num
		FROM   $cache_table
	",1);
	
	# �����˻��Ѥ���ʸ����Υꥹ��
	foreach my $i (@{$self->{condition}}){
		if ($i->name eq 'string'){
			my $t = $i->raw;
			chop $t;
			substr($t, 0, 1) = '';
			push @{$self->{strings}}, $t;
		}
	}
	
	# $self->{tani}.num ��0���ä����Τ���μ���
	mysql_exec->do("
		UPDATE $self->{res_table}
		SET    num = 1
		WHERE  num = 0
	",1);
	
	#print " done\n" if $debug;

	return $self;
}

#----------------------#
#   �����ǥ��󥰽���   #

sub ready{
	my $self = shift;
	my $tani = shift;
	my $sort = shift;
	
	print "***\n" if $debug;
	print "* Coding: making tables for atoms...\n" if $debug;

	$self->{tani} = $tani;
	unless ($self->{condition}){
		return 0;
	}

	# ����å���Υ����å�
	my $raw = $self->{ed_condition};
	$raw =~ s/'/\\'/g;
	print Jcode->new("raw: $raw\n",'euc')->sjis if $debug;
	my $kind = 'code';
	if (defined($sort) && $sort eq 'tf*idf'){
		$kind .= '_idf_m';
	}
	elsif (defined($sort) && $sort eq 'tf/idf'){
		$kind .= '_idf_d';
	}
	my @c_c = kh_cod::a_code->cache_check(
		tani => $tani,
		kind => $kind,
		name => $raw
	);
	
	if ( $c_c[0] == 1 ) {                            # ����å���ͭ��ξ��
		print "\tcache found[0]!\n" if $debug;
		my $t = mysql_exec->select("
			SELECT hyosos
			FROM ct_cache_tables
			WHERE id = $c_c[1]
		",1)->hundle->fetch->[0];
		my @words = split /\t/, $t;
		$self->{hyosos} = \@words;
		return $self;
	}
	
	# ATOM���ȤΥơ��֥�����
	my %words;
	my ($length_frag,$n,$n0, $n1,$unique_check,@tmp_tab) = (0,0,0,0,undef,undef);
	my @t = ();
	foreach my $i (@{$self->{condition}}){
		$i->ready($tani);
		my $temp_w = $i->hyosos;
		if ($temp_w){
			foreach my $h (@{$temp_w}){
				++$words{$h};
			}
		}
		if ($i->name eq 'length'){$length_frag = 1;}
		if ( ($i->tables) and not ($i->name eq 'length') ){
			$n0 += @{$i->tables};
			$n  += @{$i->tables};
			if ($n0 > 25){
				++$n1; $n0 = 0;
			}
			$i->parent_table("ct_$tani"."_$n1");
			foreach my $h (@{$i->tables}){
				if ($unique_check->{$n1}{$h}){
					next;
				} else {
					push @{$t[$n1]}, $h;
					if ($h) {push @tmp_tab,   $h;}
					$unique_check->{$n1}{$h} = 1;
				}
			}
		}
	}
	my @words = (keys %words);
	$self->{hyosos} = \@words;
	if ($length_frag) {push @{$self->{tables}},"$tani"."_length";}
	
	#if ($n < 30){
	#	$self->{parents} = 0;
	#	$self->{tables}  = \@tmp_tab;
	#	print "tables: $n\n";
	#	return 1;
	#} else {
	#	$self->{parents} = 1;
	#}
	unless ($unique_check){return 1;}
	
	# ATOM�ơ��֥��ޤȤ��
	print "* Coding: Joining the tables...\n" if $debug;
	$n = 0;
	foreach my $i (@t){
		# �ơ��֥����
		mysql_exec->drop_table("ct_$tani"."_$n");
		my $sql =
			"CREATE TABLE ct_$tani"."_$n ( id int primary key not null,\n";
		foreach my $h (@{$i}){
			# print "atom table: $h\n";
			my $col = (split /\_/, $h)[2].(split /\_/, $h)[3];
			$sql .= "$col FLOAT,"
		}
		chop $sql;
		$sql .= ') TYPE = HEAP ';
		mysql_exec->do($sql,1);
		push @{$self->{tables}}, "ct_$tani"."_$n";
		
		# INSERT
		$sql = '';
		$sql .= "INSERT INTO ct_$tani"."_$n\n(id,";
		foreach my $h (@{$i}){
			my $col = (split /\_/, $h)[2].(split /\_/, $h)[3];
			$sql .= "$col,";
		}
		chop $sql;
		$sql .= ")\n";
		$sql .= "SELECT $tani.id,";
		foreach my $h (@{$i}){
			$sql .= "$h.num,";
		}
		chop $sql;
		$sql .= "\n";
		$sql .= "FROM $tani \n";
		foreach my $h (@{$i}){
			$sql .= "\tLEFT JOIN $h ON $tani.id = $h.id\n"
		}
		$sql .= "WHERE ";
		my $nn = 0;
		foreach my $h (@{$i}){
			if ($nn){ $sql .= ' OR '; }
			$sql .= " $h.num is not null";
			++$nn;
		}
		mysql_exec->do($sql,1);
		
		++$n;
	}
	return $self;
}

#------------------------------#
#   �����ǥ��󥰥롼��β��   #

sub new{
	my $self;
	my $class = shift;
	$self->{name} = shift;
	$self->{row_condition} = shift;
	
	my $condition = Jcode->new($self->{row_condition},'euc')->tr('��',' ');

	$condition =~ tr/\t\n\r/   /;                 # ���֡����Ԥ򥹥ڡ������Ѵ�

	$condition =~ s/(?:\x0D\x0A|[\x0D\x0A])?$/ /;
	my @temp = map{/^'(.*)'$/ ? scalar(s/''/'/g, $_) : $_}
		($condition =~ /('(?:[^']|'')*'|"(?:[^"]|"")*"|[^ ]*) /g);

=pod

���󥰥륯�����ȡ�'�פǳ���Ƥ�����ʬ�ϡ��������Ⱦ�ѥ��ڡ��������äƤ�ʬ�䤷�ʤ����ޤ�������ǥ��󥰥륯�����Ȥ���Ѥ��������ϡ�''�פ�ɽ�����롣

CSV�ե�����β����ˡ�򻲹ͤˤ�����
http://www.din.or.jp/~ohzaki/perl.htm#CSV2Values

�ʰʲ����嵭URL���ȴ�� 2013/03/09��

# CSV������ $line �����ͤ���Ф��� @values �������

{
  my $tmp = $line;
  $tmp =~ s/(?:\x0D\x0A|[\x0D\x0A])?$/,/;
  @values = map {/^"(.*)"$/ ? scalar($_ = $1, s/""/"/g, $_) : $_}
                ($tmp =~ /("[^"]*(?:""[^"]*)*"|[^,]*),/g);
}
CSV(Comma Separated Value)�����Ȥ����Τϡ� �����˥��ץꥱ�������˰�¸���������Ǥ���Τǡ� ���Υ�����ץȤǤ����륢�ץꥱ������󤬰��� CSV������ �Ԥ����ͤ���Ф���櫓�ǤϤ���ޤ��󡥤��Υ�����ץȤϤ�äȤ���פ� ����Ȼפ�졤�ޤ������Ū����Ū������Ǥ��� Excel �����Ϥ��� CSV�����ˤĤ��ư������ȤȤ��ޤ�����Excel �����Ϥ��� CSV�������ɤΤ褦�ʤ�Τ� Excel �Υإ�פ˺ܤä� ���ޤ���Ǥ��������䤬�ȼ���Ĵ�٤���̰ʲ��Τ褦�ʤ�ΤǤ���Ȥ��ޤ�����

����Ū�˥���ޤǶ��ڤä���ʬ�����ڡ�����ޤ���ͤǤ��롥
�ͤ˥���ޤ���֥륯�������Ȥ��ޤޤ����ϡ� �����Τ���֥륯�������ȤǰϤࡥ
�ͤ˴ޤޤ����֥륯�������Ȥ� "" �Ȥʤ롥
���Υ�����ץȤǤϡ��ޤ��Ϥ���� $line �Υ��ԡ��� $tmp �˼�äƤ���������Ƥ��ޤ��� ���ԡ����餺�˽�������ȡ� ���ν����� $line ���ѹ����Ƥ��ޤ����Ȥˤʤ뤿��Ǥ��� ����Ū�ˤϡ���н������ñ�ˤ��뤿��ˡ��Ǹ���ͤθ��� ����ޤ�Ĥ��ä��Ƥ��ޤ������ΤȤ� $line �κǸ�� ���ԥ����ɤ��Ĥ��Ƥ�������ͤ������ԥ����ɤκ����Ʊ���˹ԤʤäƤ��ޤ��� �����ޤǤν����� $line ����Ȥ� ��,��,��, �Ȥ����褦�� ��, �η����֤��ˤʤäƤ��ޤ���

���� ��,��,��, �Ȥ���������ġ����ͤ� ���Ф��櫓�Ǥ����������Ԥʤ� ����˽����� g ��Ĥ��� �ѥ�����ޥå���Ԥʤ��ޤ��������� g ��Ĥ��� �ѥ�����ޥå���ꥹ�ȥ���ƥ����ȤǼ¹Ԥ���ȡ� ()�ˤ�륰�롼�פ˥ޥå�������ʬʸ����Υꥹ�Ȥ� �֤��ޤ����ͤ���ʬ�˥ޥå���������ɽ���򥰥롼�פˤ��Ƥ����С� �ͤΥꥹ�Ȥ���Ф����Ȥ��Ǥ���櫓�Ǥ���

��������դ�ɬ�פʤΤϡ���, �ȤʤäƤ����Τȡ� "��", �ȤʤäƤ����Τ� 2���ब���뤳�ȤǤ��������ơ�"��", �η��������ͤˤϥ���ޤ��ޤޤ�Ƥ����ǽ��������ޤ����������äơ� ñ��� split /,/, $tmp �� ($tmp =~ /([^,]*),/g) �Τ褦�ˤ��Ƥ��ޤ��ȡ� �ͤ���Υ���ޤˤ�ä��ͤ� 2�Ĥ��̤�Ƥ��ޤ����Ȥˤʤ�ޤ��� �����Ǥޤ����ͤ���ڤäƤ��륳��ޤ� �� �� "��" �����Τ˼��Ф����Ȥ�ͤ��ޤ���

��, �η����ͤˤϥ���ޤ��ޤޤ�Ƥ��ޤ��󤫤顤 �� ����ʬ�˥ޥå�������ˤ� /([^,]*),/ �Ȥ���Ф������Ȥˤʤ�ޤ��� ������"��", �η��� "��" ����ʬ�˥ޥå�������ˤϡ�/("[^"]*"),/ �Ȥ���Ф����褦�˻פ����⤷��ޤ��󤬡�CSV������ 3���ܤ�����ˤ�ꡤ�ͤˤ� "" �Ȥ����Τ��ޤޤ�Ƥ����ǽ��������ޤ��������ǡ� [^"] �ʳ��� "" �ξ���ͤ��� /("(?:[^"]|"")*"),/ �Ȥ���Ф������Ȥˤʤ�ޤ������� 2�Ĥη���������ơ� ($tmp =~ /("(?:[^"]|"")*"|[^,]*),/g) �Ȥʤ�ޤ��� ����� �� �ޤ��� "��" �Υꥹ�ȤȤ��� ���Ф����Ȥ��Ǥ��ޤ�������������ɽ������ʬ�Ϥ��ΤޤޤǤ⤤���ΤǤ����� ������ץȤǤϤ���ˤ�������ɽ���� Jeffrey E. F. Friedl�� �����ˤ��־��� ����ɽ���פ� �֥롼��Ÿ���פȤ��ƽ񤫤�Ƥ��� ��ˡ���ѷ����¹�®�٤�®�����Ƥ���ޤ���

�Ǹ�� "��" �����ͤ���������ɬ�פ�����ޤ��� �� �η��ʤ餽�Τޤޡ�"��" �η��ʤ��ξ¦�Υ��֥륯�������Ȥ������������� "" �� " ���Ѵ����ޤ��� ���ν����� map �ؿ� ����ǹԤʤäƤ��ޤ��� �����CSV�����ιԤ����ͤ���Ф����Ȥ��Ǥ��ޤ���

=cut

	my $n = 0;
	foreach my $i (@temp){
		next unless length($i);
		next if ($i eq ' ');
		#if ($i =~ /^"(.+)"$/){
		#	$i = $1;
		#	$i =~ s/""/"/g;
		#}
		
		#print "raw: $i,";
		my $the_atom = kh_cod::a_code::atom->new($i);
		push @{$self->{condition}}, $the_atom;
		$self->{ed_condition} .= ' ' if $n;
		$self->{ed_condition} .= $the_atom->raw_for_cache_chk;
		++$n;
	}
	#print "\n";
	
	bless $self, $class;
	return $self;
}

# ���Ѹ�Υꥹ�Ȥ��֤�
sub hyosos{
	my $self = shift;
	return $self->{hyosos};
}
sub strings{
	my $self = shift;
	return $self->{strings};
}

# 2���ܰʹߤΥ����ǥ��󥰤�������
sub clear{
	my $self = shift;
	
	$self->{res_table} = undef;
	$self->{res_col}   = undef;
	$self->{tables}    = undef;
	$self->{tani}      = undef;
	$self->{if_done}   = 0;
	foreach my $i (@{$self->{condition}}){
		$i->{tables} = undef;
		$i->clear;
	}
}

#--------------------#
#   ����å������   #
#--------------------#

sub cache_check{
	my $self_ = shift;
	my %args = @_;

	# ����å���ꥹ�Ȥ�¸�ߤ�����
	if ( mysql_exec->table_exists('ct_cache_tables') ){
		# ���˥���å��夬���뤫�ɤ����򸡺�
		$args{name} = mysql_exec->quote($args{name});
		my $h = mysql_exec->select("
			SELECT id
			FROM ct_cache_tables
			WHERE 
				    tani = \"$args{tani}\"
				AND kind = \"$args{kind}\"
				AND name = binary \"$args{name}\"
		",1)->hundle;
		my $n = $h->fetch;
		if ($n){                        # ����å��夬¸�ߤ������
			#print "[list y, cache y]\n" if $debug;
			return (1,$n->[0]);
		} else {                        # ����å��夬¸�ߤ��ʤ��ä����
			my $num = 0;
			if ($args{kind} =~ /^code/ ){
				# �ֹ���֤�
				$num = mysql_exec->select("
					SELECT MAX(id)
					FROM   ct_cache_tables
				",1)->hundle->fetch->[0];
				++$num;
				#print "[list y, cache n, code y]\n" if $debug;
			} else {
				# ��������å���Ȥ�����Ͽ
				mysql_exec->do("
					INSERT INTO ct_cache_tables (tani,kind,name)
					VALUES (\"$args{tani}\", \"$args{kind}\",\"$args{name}\")
				",1);
				# �ֹ���֤�
				$num = mysql_exec->select("
					SELECT MAX(id)
					FROM   ct_cache_tables
				",1)->hundle->fetch->[0];
				#print "[list y, cache n, code n]\n"  if $debug;
			}
			return (0, $num);
		}
	}
	# ����å���ꥹ�Ȥ�¸�ߤ��ʤ��ä����
	else {
		mysql_exec->do("
			CREATE TABLE ct_cache_tables (
				id     int auto_increment primary key not null,
				tani   varchar(5),
				kind   varchar(20),
				name   text,
				hyosos text
			)
		",1);
		# ���ब��code�פǤʤ������Ͽ���Ƥ��ޤ�
		mysql_exec->do("
			INSERT INTO ct_cache_tables (tani,kind,name)
			VALUES (\"$args{tani}\", \"$args{kind}\",\"$args{name}\")
		",1) unless ($args{kind} =~ /^code/ );
		return (0,1);
	}
}

sub cache_regist{
	my $self_ = shift;
	my %args = @_;
	$args{name} = mysql_exec->quote($args{name});
	
	# ��������å���Ȥ�����Ͽ
	mysql_exec->do("
		INSERT INTO ct_cache_tables (tani,kind,name,hyosos)
		VALUES (
			\"$args{tani}\",
			\"$args{kind}\",
			\"$args{name}\",
			\"$args{hyosos}\"
		)
	",1);
}

sub cache_code_if_ok{
	my $self_ = shift;
	my %args = @_;
	$args{name} = mysql_exec->quote($args{name});

	my $h = mysql_exec->select("
		SELECT hyosos
		FROM ct_cache_tables
		WHERE 
			    tani = \"$args{tani}\"
			AND kind = \"$args{kind}\"
			AND name = \"$args{name}\"
	",1)->hundle;
	my $t = $h->fetch;
	$t = $t->[0];
	print "cache code chk: $t\n" if $debug;
	#return 0 unless $t;
	return 0 if $t eq '-1';
	return 1;
}

#--------------#
#   ��������   #

sub if_done{                  # �����ǥ��󥰤��¹Ԥ���Ƥ��뤫
	my $self = shift;
	return $self->{if_done};
}

sub tables{                   # ���ȥࡦ�ơ��֥��ޤȤ᤿�ơ��֥�Υꥹ��
	my $self = shift;
	return $self->{tables};
}

sub tani{                     # �����ǥ���ñ��
	my $self = shift;         # $self->ready("ñ��")�ǻ��ꤵ�줿���
	return $self->{tani};
}

sub res_table{                # �����ǥ��󥰷�̤���¸�����ơ��֥�
	my $self = shift;         # $self->code("�ơ��֥�̾")�ǻ��ꤵ�줿���
	my $val  = shift;
	if ( defined($val) && length($val) ){
		$self->{res_table} = $val;
	}
	return $self->{res_table};
}

sub res_col{                  # �����ǥ��󥰷�̤���¸���������
	my $self = shift;
	my $val  = shift;
	if ( defined($val) && length($val) ){
		$self->{res_col} = $val;
	}
	
	if ( defined($self->{res_col}) && length($self->{res_col}) ){
		return $self->{res_col};
	} else {
		return 'num';
	}
}

sub name{                     # ������̾
	my $self = shift;         # �ե����뤫���ɤ߹���
	return $self->{name};
}
sub row_condition{
	my $self = shift;
	return $self->{row_condition};
}

1;