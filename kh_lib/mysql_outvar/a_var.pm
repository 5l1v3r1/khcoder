package mysql_outvar::a_var;
use strict;
use mysql_exec;

sub new{
	my $class = shift;
	my $self;
	$self->{name} = shift;
	$self->{id}   = shift;
	bless $self, $class;
	
	if ( length($self->{name}) ){                 # �ѿ�̾����¾�ξ�������
		my $i = mysql_exec->select("
			SELECT tab, col, tani, id
			FROM outvar
			where name = \'$self->{name}\'
		",1)->hundle->fetch;
		$self->{table}  = $i->[0];
		$self->{column} = $i->[1];
		$self->{tani}   = $i->[2];
		$self->{id}     = $i->[3];
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

# �ͥ�٥�⤷�����ͤ�Ϳ����줿���ˡ��ͤ��֤�
sub real_val{
	my $self = shift;
	my $val  = shift;
	
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
	
	# �ٿ���ñ�㽸�ס˼���
	my $f = mysql_exec->select("
		SELECT $self->{column}, COUNT(*)
		FROM   $self->{table}
		GROUP BY $self->{column}
	",1)->hundle;
	while (my $i = $f->fetch){
		$self->{freqs}{$i->[0]} = $i->[1];
	}
	
	# �꥿���󤹤�ɽ�����
	my @data;
	foreach my $i (sort keys %{$self->{freqs}}){
		push @data, [$i, $self->{labels}{$i}, $self->{freqs}{$i} ];
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