package kh_nbayes;

use strict;
use Algorithm::NaiveBayes;

# �w�K�֘A
# �E�O���ϐ��̒P�ʂƕ��ޒP�ʂ���v���Ȃ��ꍇ�p�̎蓖�Ă�: get_ov
# �E�w�K�Ɏg�p������̐��̐��m�ȎZ�o: ...

sub learn_from_ov{
	my $class = shift;
	my %args  = @_;
	my $self = \%args;
	bless $self, $class;

	unless ( length($self->{max}) ){
		$self->{max} = 0;
	}

	# �w�K���[�h���w��
	$self->{mode} = 't';
	$self->{command} = sub {
		my $current = shift;
		my $last    = shift;
		$self->add($current,$last);
	} ;

	# ����
	$self->make_list;
	$self->get_ov;

	# ���s
	print "Start training... ";
	$self->{cls} = Algorithm::NaiveBayes->new;
	$self->out2;
	$self->{cls}->train;
	print $self->{cls}->instances, " instances. ok.\n";

	unlink($self->{path}) if -e $self->{path};
	$self->{cls}->save_state($self->{path});

	#use Data::Dumper;
	#print Dumper($self->{cls});

	undef $self;
	return 1;
}

sub add{
	my $self = shift;
	my $current = shift;
	my $last    = shift;
	unless (
		   length($self->{outvar_cnt}{$last}) == 0
		|| $self->{outvar_cnt}{$last} eq '.'
		|| $self->{outvar_cnt}{$last} eq '�����l'
		|| $self->{outvar_cnt}{$last} =~ /missing/i
	){
		$self->{cls}->add_instance(
			attributes => $current,
			label      => $self->{outvar_cnt}{$last},
		);
		
		# �e�X�g�v�����g
		 print "out: $last\n";
		 print Jcode->new("label: $self->{outvar_cnt}{$last}\n", 'euc')->sjis;
		 foreach my $h (keys %{$current}){
		 	print Jcode->new("at: $h, $current->{$h}\n", 'euc')->sjis;
		 }
	}
	return 1;
}


sub predict{
	my $class = shift;
	my $self = {@_};
	bless $self, $class;
	
	# �w�K���ʂ̓ǂݍ���
	use Algorithm::NaiveBayes::Model::Frequency;
	$self->{cls} = Algorithm::NaiveBayes->restore_state($self->{path});
	
	#print "$self->{path}, $self->{tani}, $self->{outvar}\n";
	
	# ���ރ��[�h���w��
	$self->{mode} = 'p';
	$self->{command} = sub {
		my $current = shift;
		my $last    = shift;
		$self->prd($current,$last);
	} ;
	
	# ����
	$self->make_hinshi_list;
	$self->{result} = undef;
	push @{$self->{result}}, [$self->{outvar}];
	
	# ���s
	$self->out2;
	
	# �ۑ�
	my $type = 'INT';
	foreach my $i ($self->{cls}->labels){
		if ($i =~ /^[0-9]/){
			$type = 'varchar';
			last;
		}
	}
	&mysql_outvar::read::save(
		data     => $self->{result},
		tani     => $self->{tani},
		var_type => $type,
	) or return 0;
	return 1;
}

sub prd{
	my $self = shift;
	my $current = shift;
	my $last    = shift;
	
	use List::Util qw(max sum);
	
	my $r = $self->{cls}->predict(
		attributes => $current
	);
	
	my $cnt     = 0;
	my $max     = 0;
	my $max_lab = 0;
	foreach my $i (keys %{$r}){
		++$cnt if $r->{$i} >= 0.6;
		if ($max < $r->{$i}){
			$max = $r->{$i};
			$max_lab = $i;
		}
	}
	
	print "$last: ";
	if (
		   $cnt == 1
		&& $max >= 0.8
	) {
		push @{$self->{result}}, [$max_lab];
		print "$max_lab\n";
	} else {
		push @{$self->{result}}, '.';
		print ".\n";
	}
	
	return 1;
}


#----------------#
#   �f�[�^�쐻   #

sub out2{                               # length�쐻������
	my $self = shift;
	
	# �Z�����e�̍쐻
	my $id = 1;
	my $last = 1;
	my %current = ();
	while (1){
		my $sth = mysql_exec->select(
			$self->sql2($id, $id + 100),
			1
		)->hundle;
		$id += 100;
		unless ($sth->rows > 0){
			last;
		}
		
		while (my $i = $sth->fetch){
			if ($last != $i->[0]){
				# �����o��
				&{$self->{command}}(\%current, $last);
				
				# ������
				%current = ();
				$last = $i->[0];
			}

			if (
				   ( $self->{mode} eq 't' && $self->{wName}{$i->[1]} )
				|| ( $self->{mode} eq 'p' && $self->{hName}{$i->[3]} )
			){
				my $t = '';
				$t .= $i->[2];
				$t .= '-';
				$t .= $self->{hName}{$i->[3]};
				
				++$current{$t};
			}
		}
		$sth->finish;
	}
	
	# �ŏI�s�̏����o��
	&{$self->{command}}(\%current, $last);



	return $self;
}

sub sql2{
	my $self = shift;
	my $d1   = shift;
	my $d2   = shift;


	my $sql;
	$sql .= "SELECT $self->{tani}.id, genkei.id, genkei.name, genkei.khhinshi_id\n";
	$sql .= "FROM   hyosobun, hyoso, genkei, $self->{tani}\n";
	$sql .= "WHERE\n";
	$sql .= "	hyosobun.hyoso_id = hyoso.id\n";
	$sql .= "	AND hyoso.genkei_id = genkei.id\n";
	
	my $flag = 0;
	foreach my $i ("bun","dan","h5","h4","h3","h2","h1"){
		if ($i eq $self->{tani}){ $flag = 1; }
		if ($flag){
			$sql .= "	AND hyosobun.$i"."_id = $self->{tani}.$i"."_id\n";
		}
	}
	$sql .= "	AND genkei.nouse = 0\n";
	$sql .= "	AND $self->{tani}.id >= $d1\n";
	$sql .= "	AND $self->{tani}.id <  $d2\n";
	$sql .= "ORDER BY hyosobun.id";
	return $sql;
}

#------------------------#
#   �O���ϐ��̒l���擾   #

sub get_ov{
	my $self = shift;

	my $var_obj = mysql_outvar::a_var->new(undef,$self->{outvar});
		
	my $sql = '';
	$sql .= "SELECT id, $var_obj->{column} FROM $var_obj->{table} ";
	$sql .= "ORDER BY id";

	my $h = mysql_exec->select($sql,1)->hundle;

	my $outvar;
	while (my $i = $h->fetch){
		if ( length( $var_obj->{labels}{$i->[1]} ) ){
			$outvar->{$i->{0}} = $var_obj->{labels}{$i->[1]};
		} else {
			$outvar->{$i->[0]} = $i->[1];
		}
	}
	
	$self->{outvar_cnt} = $outvar;
	
	return $self;
}


#------------------------------------#
#   �o�͂���P��E�i�����X�g�̍쐻   #

sub make_list{
	my $self = shift;
	
	# �P�ꃊ�X�g�̍쐻
	my $sql = "
		SELECT genkei.id, genkei.name, hselection.khhinshi_id
		FROM   genkei, hselection, df_$self->{tani}
		WHERE
			    genkei.khhinshi_id = hselection.khhinshi_id
			AND genkei.num >= $self->{min}
			AND genkei.nouse = 0
			AND genkei.id = df_$self->{tani}.genkei_id
			AND df_$self->{tani}.f >= $self->{min_df}
			AND (
	";
	
	my $n = 0;
	foreach my $i ( @{$self->{hinshi}} ){
		if ($n){ $sql .= ' OR '; }
		$sql .= "hselection.khhinshi_id = $i\n";
		++$n;
	}
	$sql .= ")\n";
	if ($self->{max}){
		$sql .= "AND genkei.num <= $self->{max}\n";
	}
	if ($self->{max_df}){
		$sql .= "AND df_$self->{tani}.f <= $self->{max_df}\n";
	}
	$sql .= "ORDER BY khhinshi_id, genkei.num DESC, genkei.name\n";
	
	my $sth = mysql_exec->select($sql, 1)->hundle;
	my (@list, %name, %hinshi);
	while (my $i = $sth->fetch) {
		push @list,        $i->[0];
		$name{$i->[0]}   = $i->[1];
		$hinshi{$i->[0]} = $i->[2];
	}
	$sth->finish;
	$self->{wList}   = \@list;
	$self->{wName}   = \%name;
	$self->{wHinshi} = \%hinshi;
	
	# �i�����X�g�̍쐻
	$sql = '';
	$sql .= "SELECT khhinshi_id, name\n";
	$sql .= "FROM   hselection\n";
	$sql .= "WHERE\n";
	$n = 0;
	foreach my $i ( @{$self->{hinshi}} ){
		if ($n){ $sql .= ' OR '; }
		$sql .= "khhinshi_id = $i\n";
		++$n;
	}
	$sth = mysql_exec->select($sql, 1)->hundle;
	while (my $i = $sth->fetch) {
		$self->{hName}{$i->[0]} = $i->[1];
		if ($i->[1] eq 'HTML�^�O'){
			$self->{use_html} = 1;
		}
	}
	
	return $self;
}

sub make_hinshi_list{
	my $self = shift;
	
	my $sql = '';
	$sql .= "SELECT khhinshi_id, name\n";
	$sql .= "FROM   hselection\n";
	$sql .= "WHERE ifuse = 1";
	
	my $sth = mysql_exec->select($sql, 1)->hundle;
	
	while (my $i = $sth->fetch) {
		$self->{hName}{$i->[0]} = $i->[1];
	}
	
	return $self;
}

1;