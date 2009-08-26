package kh_nbayes;

use strict;
use List::Util qw(max sum);
use Algorithm::NaiveBayes;
use Algorithm::NaiveBayes::Model::Frequency;

# �w�K�֘A
# �E�w�K���ʂ̓��e���m�F
# �E�O���ϐ��̏o�͋@�\
# �E���ތ��ʂ̏ڍׂ����O�ɏo�͂���@�\
# �����̃t�@�C���̃��t�@�N�^�����O: �I�u�W�F�N�g���^�J�v�Z����

#----------#
#   �w�K   #

sub learn_from_ov{
	my $class = shift;
	my %args  = @_;
	my $self = \%args;
	bless $self, $class;

	unless ( length($self->{max}) ){
		$self->{max} = 0;
	}

	# �����̃t�@�C���ɒǉ����邩�ǂ���
	if ($self->{add_data}){
		$self->{cls} = Algorithm::NaiveBayes->restore_state($self->{path});
		rename($self->{path}, $self->{path}.'.tmp');
	} else {
		$self->{cls} = Algorithm::NaiveBayes->new(purge => 0);
	}

	# �w�K���[�h�ɃZ�b�g
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
	$self->{train_cnt} = 0;
	$self->out2;
	$self->{cls}->train;
	print $self->{cls}->instances, " instances. ok.\n";

	unlink($self->{path}) if -e $self->{path};
	$self->{cls}->save_state($self->{path});
	unlink($self->{path}.'.tmp');

	# use Data::Dumper;
	# print Dumper($self->{cls});

	my $n   = $self->{cls}->instances;
	my $n_c = $self->{train_cnt};

	# �����Ó���
	my ($tested, $correct, $kappa);
	if ( $self->{cross_vl} ){
		my @labels = $self->{cls}->labels;
		
		print "Cross validation:\n";
		$self->cross_validate;
		
		$tested  = @{$self->{test_result}};
		$correct = 0;
		foreach my $i (@{$self->{test_result}}){
			++$correct if $i;
		}
		
		# kappa�̌v�Z
		my (%outvar, $outvar_n);
		foreach my $h (values %{$self->{outvar_cnt}}){
			unless (
				   length($h) == 0
				|| $h eq '.'
				|| $h eq '�����l'
				|| $h =~ /missing/io
			){
				++$outvar{$h};
				++$outvar_n;
			}
		}
		
		my (%test, $test_n);
		foreach my $i ( @{$self->{test_result_raw}} ){
			++$test{$i};
			++$test_n;
		}
		
		my $pe = 0;
		foreach my $i (@labels){
			$pe += ($outvar{$i} / $outvar_n) * ( $test{$i} / $test_n );
		}
		
		my $pa = $correct / $tested;
		$kappa = ( $pa - $pe ) / ( 1 - $pe );
		
		print "Tested: $correct / $tested, kappa: $kappa\n";
	}

	undef $self;
	return {
		instances       => $n_c,
		instances_all   => $n,
		cross_vl_tested => $tested,
		cross_vl_ok     => $correct,
		kappa           => $kappa,
	};
}

sub add{
	my $self = shift;
	my $current = shift;
	my $last    = shift;
	unless (
		   length($self->{outvar_cnt}{$last}) == 0
		|| $self->{outvar_cnt}{$last} eq '.'
		|| $self->{outvar_cnt}{$last} eq '�����l'
		|| $self->{outvar_cnt}{$last} =~ /missing/io
	){
		$self->{cls}->add_instance(
			attributes => $current,
			label      => $self->{outvar_cnt}{$last},
		);
		++$self->{train_cnt};
		
		# �e�X�g�v�����g
		# print "out: $last\n";
		# print Jcode->new("label: $self->{outvar_cnt}{$last}\n", 'euc')->sjis;
		# foreach my $h (keys %{$current}){
		# 	print Jcode->new("at: $h, $current->{$h}\n", 'euc')->sjis;
		# }
	}
	return 1;
}

#----------------#
#   �����Ó���   #

sub cross_validate{
	my $self = shift;
	
	# �O���[�v����
	my $groups = $self->{cross_fl}; # �����̃O���[�v�ɕ����邩
	
	my $member_order;
	foreach my $i (keys %{$self->{outvar_cnt}}){
		unless (
			   length($self->{outvar_cnt}{$i}) == 0
			|| $self->{outvar_cnt}{$i} eq '.'
			|| $self->{outvar_cnt}{$i} eq '�����l'
			|| $self->{outvar_cnt}{$i} =~ /missing/io
		){
			$member_order->{$i} = rand();
		}
	}
	
	my $n = 1;
	foreach my $i (
		sort { $member_order->{$a} <=> $member_order->{$b} }
		keys %{$member_order}
	){
		$self->{member_group}{$i} = $n;
		# print "$i\t$n\n";
		++$n;
		$n = 1 if $n > $groups;
	}
	
	# �������[�v
	$self->{test_result} = undef;
	$self->{test_result_raw} = undef;
	for (my $c = 1; $c <= $groups; ++$c){
		$self->{cross_vl_c} = $c;
		$self->{cls} = Algorithm::NaiveBayes->new;
		print "  fold $c: ";
		
		# �w�K�t�F�[�Y
		$self->{mode} = 't';
		$self->{command} = sub {
			my $current = shift;
			my $last    = shift;
			$self->add_p($current,$last);
		};
		$self->out2;
		$self->{cls}->train;
		print "training ", $self->{cls}->instances, ",\t";

		# �e�X�g�t�F�[�Y
		$self->{test_count} = 0;
		$self->{test_count_hit} = 0;
		$self->{mode} = 'p';
		$self->{command} = sub {
			my $current = shift;
			my $last    = shift;
			$self->prd_p($current,$last);
		};
		$self->out2;
		print "test $self->{test_count_hit} / $self->{test_count}";
		print "\n";
	}
	
	return $self;
}

sub prd_p{
	my $self = shift;
	my $current = shift;
	my $last    = shift;
	
	unless ( $self->{cross_vl_c} == $self->{member_group}{$last} ){
		return 0;
	}
	
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
	
	if (
		   $cnt == 1
		&& $max >= 0.8
	) {
		push @{$self->{test_result_raw}}, $max_lab;
		if ( $max_lab eq $self->{outvar_cnt}{$last} ){
			push @{$self->{test_result}}, 1;
			++$self->{test_count_hit};
		} else {
			push @{$self->{test_result}}, 0;
		}
	} else {
		push @{$self->{test_result_raw}}, '.';
		push @{$self->{test_result}}, 0;
	}
	
	++$self->{test_count};
	return 1;
}

sub add_p{
	my $self = shift;
	my $current = shift;
	my $last    = shift;
	if (
		    $self->{member_group}{$last}
		and $self->{cross_vl_c} != $self->{member_group}{$last}
	){
		$self->{cls}->add_instance(
			attributes => $current,
			label      => $self->{outvar_cnt}{$last},
		);
	}
	return 1;
}

#----------#
#   ����   #

sub predict{
	my $class = shift;
	my $self = {@_};
	bless $self, $class;
	
	# �w�K���ʂ̓ǂݍ���
	$self->{cls} = Algorithm::NaiveBayes->restore_state($self->{path});
	
	# ���ރ��[�h�ɃZ�b�g
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
		print "labels: $i\n";
		if ($i =~ /[^0-9]/){
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
	
	#print "$last: ";
	if (
		   $cnt == 1
		&& $max >= 0.8
	) {
		push @{$self->{result}}, [$max_lab];
		#print "$max_lab\n";
	} else {
		push @{$self->{result}}, ['.'];
		#print ".\n";
	}
	
	return 1;
}

#--------------------------#
#   �w�K�Ɏg�p�����̐�   #

# �������̗]�n�������Ԃ��邩���c

sub wnum{
	my $class = shift;
	my $self = {@_};
	bless $self, $class;

	return undef unless length($self->{tani});
	return undef unless length($self->{outvar});

	my $missing = 0;
	$self->get_ov;
	foreach my $i (values %{$self->{outvar_cnt}}){
		if (
			   length($i) == 0
			|| $i eq '.'
			|| $i eq '�����l'
			|| $i =~ /missing/io
		){
			$missing = 1;
			last;
		}
	}
	
	if ( $missing == 0 ){     # �O���ϐ��Ɍ����l���Ȃ��ꍇ
		my $check = mysql_crossout::r_com->new(
			tani   => $self->{tani},
			hinshi => $self->{hinshi},
			max    => $self->{max},
			min    => $self->{min},
			max_df => $self->{max_df},
			min_df => $self->{min_df},
		)->wnum;
		return $check;
	} else {                  # �O���ϐ��Ɍ����l������ꍇ

		# �J�E���g���[�h�ɃZ�b�g
		$self->{mode} = 't';
		$self->{command} = sub {
			my $current = shift;
			my $last    = shift;
			$self->cnt($current,$last);
		} ;

		$self->make_list;
		$self->out2;

		$_ = keys %{$self->{count}};
		1 while s/(.*\d)(\d\d\d)/$1,$2/; # �ʎ��p�̃R���}��}��
		return $_;
	}
}

sub cnt{
	my $self = shift;
	my $current = shift;
	my $last    = shift;
	unless (
		   length($self->{outvar_cnt}{$last}) == 0
		|| $self->{outvar_cnt}{$last} eq '.'
		|| $self->{outvar_cnt}{$last} eq '�����l'
		|| $self->{outvar_cnt}{$last} =~ /missing/io
	){
		foreach my $k (keys %{$current}) {
			$self->{count}{$k} += $current->{$k};
		}
	}
	return $self;
}

#----------------#
#   �f�[�^����   #

sub out2{
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
	
	if ($self->{tani} eq $var_obj->{tani}){
		$sql .= "SELECT id, $var_obj->{column} FROM $var_obj->{table} ";
		$sql .= "ORDER BY id";
	} else {
		my $tani = $self->{tani};
		$sql .= "SELECT $tani.id, $var_obj->{table}.$var_obj->{column}\n";
		$sql .= "FROM $tani, $var_obj->{tani}, $var_obj->{table}\n";
		$sql .= "WHERE\n";
		$sql .= "	$var_obj->{tani}.id = $var_obj->{table}.id\n";
		foreach my $i ('h1','h2','h3','h4','h5','dan','bun'){
			$sql .= "	and $var_obj->{tani}.$i"."_id = $tani.$i"."_id\n";
			last if ($var_obj->{tani} eq $i);
		}
		$sql .= "ORDER BY $tani.id";
	}

	my $h = mysql_exec->select($sql,1)->hundle;

	my $outvar;
	while (my $i = $h->fetch){
		if ( length( $var_obj->{labels}{$i->[1]} ) ){
			$outvar->{$i->[0]} = $var_obj->{labels}{$i->[1]};
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