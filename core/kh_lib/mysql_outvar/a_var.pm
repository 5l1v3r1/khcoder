package mysql_outvar::a_var;
use strict;
use mysql_exec;

sub new{
	my $class = shift;
	my $self;
	$self->{name} = shift;
	bless $self, $class;
	
	my $i = mysql_exec->select("
		SELECT tab, col, tani, id
		FROM outvar
		where name = \'$self->{name}\'
	",1)->hundle->fetch;
	$self->{table}  = $i->[0];
	$self->{column} = $i->[1];
	$self->{tani}   = $i->[2];
	$self->{id}     = $i->[3];
	
	$i = mysql_exec->select("
		SELECT val, lab
		FROM outvar_lab
		WHERE var_id = $self->{id}
	",1)->hundle->fetchall_arrayref;
	foreach my $h (@{$i}){
		$self->{labels}{$h->[0]} = $h->[1];
	}
	
	return $self;
}

sub detail_tab{
	my $self = shift;
	
	# �x���i�P���W�v�j�擾
	my $f = mysql_exec->select("
		SELECT $self->{column}, COUNT(*)
		FROM   $self->{table}
		GROUP BY $self->{column}
	",1)->hundle;
	while (my $i = $f->fetch){
		$self->{freqs}{$i->[0]} = $i->[1];
	}
	
	# ���^�[������\���쐬
	my @data;
	foreach my $i (sort keys %{$self->{freqs}}){
		push @data, [$i, $self->{labels}{$i}, $self->{freqs}{$i} ];
	}
	
	return \@data;
}

sub label_save{
	my $self = shift;
	my $val  = shift;
	my $lab  = shift;
	
	print "lab: $lab\n";
	
	if ($lab eq ''){                          # ���x������̏ꍇ�̓��R�[�h�폜
		mysql_exec->do("
			DELETE FROM outvar_lab
			WHERE
				var_id = $self->{id}
				AND val = \'$val\'
		",1);
	} else {
		my $exists = mysql_exec->select(     # ���R�[�h�̗L�����m�F
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