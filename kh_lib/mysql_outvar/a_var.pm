package mysql_outvar::a_var;
use strict;
use mysql_exec;

sub new{
	my $class = shift;
	my $self;
	$self->{name} = shift;
	$self->{id}   = shift;
	bless $self, $class;
	
	if (defined($self->{name}) && length($self->{name}) ){# �ѿ�̾����¾�ξ�������
		my $i = mysql_exec->select("
			SELECT tab, col, tani, id
			FROM outvar
			where name = \'$self->{name}\'
		",1)->hundle->fetch;
		
		if ($i){
			$self->{table}  = $i->[0];
			$self->{column} = $i->[1];
			$self->{tani}   = $i->[2];
			$self->{id}     = $i->[3];
		}
	} else {                                      # �ѿ�ID����¾�ξ�������
		my $i = mysql_exec->select("
			SELECT tab, col, tani, name
			FROM outvar
			where id = \'$self->{id}\'
		",1)->hundle->fetch;
		$self->{table}  = $i->[0];
		$self->{column} = $i->[1];
		$self->{tani}   = $i->[2];
		$self->{name}   = $i->[3];
	}
	unless ( defined($self->{id}) ){
		return $self;
	}
	
	my $i = mysql_exec->select("
		SELECT val, lab
		FROM outvar_lab
		WHERE var_id = $self->{id}
	",1)->hundle->fetchall_arrayref;
	foreach my $h (@{$i}){
		$self->{labels}{$h->[0]} = $h->[1];
	}
	
	return $self;
}

sub copy {
	my $self = shift;
	my $name = shift;
	
	my @data;
	
	push @data, [ $name ];
	
	my $sql = '';
	$sql .= "SELECT $self->{column} FROM $self->{table} ";
	$sql .= "ORDER BY id";

	my $type = 'INT';

	my $h = mysql_exec->select($sql,1)->hundle;
	while (my $i = $h->fetch){
		push @data, [ $i->[0] ];
		if ( $i->[0] =~ /[^0-9]/ ){
			$type = '';
		}
	}
	
	&mysql_outvar::read::save(
		data     => \@data,
		tani     => $self->{tani},
		var_type => $type,
	) or return 0;
	return 1;
}

# �ͤΥꥹ�Ȥ��֤��������ͤ��֤���
sub values{
	my $self = shift;

	my @v = ();
	my $names = '';

	# �ͥꥹ�Ȥμ���
	my $f = mysql_exec->select("
		SELECT $self->{column}
		FROM   $self->{table}
		GROUP BY $self->{column}
	",1)->hundle;
	while (my $i = $f->fetch){
		push @v, $i->[0];
		$names .= $i->[0];
	}

	# ������
	if ($names =~ /\A[0-9]+\Z/){
		@v = sort {$a <=> $b} @v;
	} else {
		@v = sort @v;
	}

	return \@v;
}

# �ͤΥꥹ�Ȥ��֤����ͥ�٥뤬������ϥ�٥���֤���
sub print_values{
	my $self = shift;
	
	# �ꥹ�Ȥμ���
	my $raw_values = $self->values;
	my @v = ();
	my $names = '';
	my $names_v = '';
	foreach my $i (@{$raw_values}){
		push @v, $self->print_val($i);
		$names .= $self->print_val($i);
		$names_v .= $i;
	}
	
	# ������
	unless ( $names_v =~ /\A[0-9]*\.*[0-9]*\Z/ ) {# �ͤ����ͤΤߤʤ��ͤǥ�����
		if ($names =~ /\A[0-9]+\Z/){
			@v = sort {$a <=> $b} @v;
		} else {
			@v = sort @v;
		}
	}

	return \@v;
}



# �ͥ�٥�⤷�����ͤ�Ϳ����줿���ˡ��ͤ��֤�
sub real_val{
	my $self = shift;
	my $val  = shift;
	
	# print "val: $val\n";
	# print "val-sjis: ", Jcode->new($val,'euc')->sjis, "\n";
	
	foreach my $i (keys %{$self->{labels}}){
		if ($val eq $self->{labels}{$i}){
			$val = $i;
			last;
		}
	}
	return $val;
}

# �����ʸ���Ϳ����줿�ͤ��֤�
sub doc_val{
	my $self = shift;
	my %args = @_;
	
	my $doc_id;
	if ($self->{tani} eq $args{tani}){
		$doc_id = $args{doc_id};
	} else {
		my $sql = "SELECT $self->{tani}.id\n";
		$sql .=   "FROM   $args{tani}, $self->{tani}\n";
		$sql .=   "WHERE\n";
		$sql .=   "\t$args{tani}.id = $args{doc_id}\n";
		
		foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
			$sql .= "\tAND $self->{tani}.$i"."_id = $args{tani}.$i"."_id\n";
			last if $i eq $self->{tani};
		}
		$doc_id = mysql_exec->select("$sql",1)->hundle->fetch->[0];
		# print "$sql";
		# print "doc_id_var: $doc_id\n";
	}
	
	return mysql_exec->select("
		SELECT $self->{column}
		FROM   $self->{table}
		WHERE  id = $doc_id
	",1)->hundle->fetch->[0];
}

# �ͤ�Ϳ����줿���ˡ��ͥ�٥뤫�ͤ��֤�
sub print_val{
	my $self = shift;
	if ($self->{labels}{$_[0]}){
		return $self->{labels}{$_[0]};
	} else {
		return $_[0];
	}
}

# �ͥ�٥��ñ����ɽ���֤�
sub detail_tab{
	my $self = shift;
	
	my $names = '';
	
	# �ٿ���ñ�㽸�ס˼���
	my $f = mysql_exec->select("
		SELECT $self->{column}, COUNT(*)
		FROM   $self->{table}
		GROUP BY $self->{column}
	",1)->hundle;
	while (my $i = $f->fetch){
		$self->{freqs}{$i->[0]} = $i->[1];
		$names .= $i->[0];
	}
	
	# �꥿���󤹤�ɽ�����
	my @data;
	
	if ($names =~ /\A[0-9]+\Z/){
		foreach my $i (sort {$a <=> $b} keys %{$self->{freqs}}){
			push @data, [$i, $self->{labels}{$i}, $self->{freqs}{$i} ];
		}
	} else {
		foreach my $i (sort keys %{$self->{freqs}}){
			push @data, [$i, $self->{labels}{$i}, $self->{freqs}{$i} ];
		}
	}
	

	
	return \@data;
}

# �ͥ�٥����¸
sub label_save{
	my $self = shift;
	my $val  = shift;
	my $lab  = shift;
	
	if ($lab eq ''){                          # ��٥뤬���ξ��ϥ쥳���ɺ��
		mysql_exec->do("
			DELETE FROM outvar_lab
			WHERE
				var_id = $self->{id}
				AND val = \'$val\'
		",1);
	} else {
		my $exists = mysql_exec->select(     # �쥳���ɤ�̵ͭ���ǧ
			"SELECT *
			FROM outvar_lab
			WHERE 
				var_id = $self->{id}
				AND val = \'$val\'"
		)->hundle->rows;
		if ($exists){
			mysql_exec->do("
				UPDATE outvar_lab
				SET lab = \'$lab\'
				WHERE
					var_id = $self->{id}
					AND val = \'$val\'
			",1);
		} else {
			mysql_exec->do("
				INSERT INTO outvar_lab (var_id, val, lab)
				VALUES ($self->{id}, \'$val\', \'$lab\')
			",1);
		}
	}
}

1;