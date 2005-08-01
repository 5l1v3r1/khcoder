package kh_cod::a_code;
use kh_cod::a_code::atom;
use gui_errormsg;
use mysql_exec;
use strict;

#----------------------#
#   �����ǥ��󥰼¹�   #

sub code{
	my $self           = shift;	
	$self->{if_done}   = 1;
	
	unless ($self->{condition}){
		return 0;
	}
	unless ($self->{row_condition}){
		return 0;
	}
	unless ($self->tables){
		$self->{tables} = [];
		#return 0;
	}

	$self->{res_table} = shift;

	mysql_exec->drop_table($self->{res_table});
	mysql_exec->do("
		CREATE TABLE $self->{res_table} (
			id int not null primary key,
			num int
		) type = heap
	",1);

	my $sql = '';
	$sql .= "INSERT INTO $self->{res_table} (id, num)\n";
	$sql .= "SELECT $self->{tani}.id, ";
	my $nn = 0;
	foreach my $i (@{$self->{condition}}){
		if ($nn){ $sql .= " + "; } else { $nn = 1; }
		$sql .= $i->num_expr();
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
	#print "$sql\n";
	
	my $check = mysql_exec->do($sql);             # ��ʸ���顼�����ä����
	if ($check->err){
		$self->{res_table} = '';
		gui_errormsg->open(
			type => 'msg',
			msg  =>
				"�����ǥ��󥰡��롼��ν񼰤˸�꤬����ޤ�����\n".
				"����ޤॳ���ɡ� ".$self->name."\n".$check->err
		);
		return 0;
	}
	
	if ($self->tables && $self->{parents}){          # ����ơ��֥�κ��
		foreach my $i (@{$self->tables}){
			mysql_exec->drop_table($i);
		}
	}
	
	
	my $check2 = mysql_exec->select(
		"SELECT * FROM $self->{res_table} LIMIT 1"
	)->hundle;
	unless (my $ch = $check2->fetch){
		$self->{res_table} = '';
		return 0;
	}
	
	# $self->{tani}.num ��0���ä����Τ���μ���
	mysql_exec->do("
		UPDATE $self->{res_table}
		SET    num = 1
		WHERE  num = 0
	",1);
	
	return $self;
}

#----------------------#
#   �����ǥ��󥰽���   #

sub ready{
	my $self = shift;
	my $tani = shift;
	$self->{tani} = $tani;
	unless ($self->{condition}){
		return 0;
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
	my $n = 0;
	foreach my $i (@t){
		# �ơ��֥����
		mysql_exec->drop_table("ct_$tani"."_$n");
		my $sql =
			"CREATE TABLE ct_$tani"."_$n ( id int primary key not null,\n";
		foreach my $h (@{$i}){
			# print "atom table: $h\n";
			my $col = (split /\_/, $h)[2].(split /\_/, $h)[3];
			$sql .= "$col INT,"
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
			$sql .= " $h.num ";
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
	$condition =~ tr/\t\n\r/   /;
	#print "$condition\n";
	my @temp = split / /, $condition;
	
	foreach my $i (@temp){
		unless ( length($i) ){next;}
		#print "$i,";
		push @{$self->{condition}}, kh_cod::a_code::atom->new($i);
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
	if ( length($val) ){
		$self->{res_table} = $val;
	}
	return $self->{res_table};
}

sub res_col{                  # �����ǥ��󥰷�̤���¸���������
	my $self = shift;
	my $val  = shift;
	if ( length($val) ){
		$self->{res_col} = $val;
	}
	
	if (length($self->{res_col})){
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