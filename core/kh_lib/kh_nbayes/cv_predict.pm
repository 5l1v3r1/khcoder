package kh_nbayes::cv_predict;
use base qw(kh_nbayes);

use strict;

sub each{
	my $self = shift;
	my $current = shift;
	my $last    = shift;
	
	unless ( $self->{cross_vl_c} == $self->{member_group}{$last} ){
		return 0;
	}
	
	my ($r, $r2) = $self->{cls}->predict(
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

	# ����¸
	if ($self->{cross_savel}){
		$self->{result_log}{$last} = $r2;
	}

	$self->{test_result_raw}{$last} = $max_lab;

	if ( $max_lab eq $self->{outvar_cnt}{$last} ){
		push @{$self->{test_result}}, 1;
		++$self->{test_count_hit};
	} else {
		push @{$self->{test_result}}, 0;
	}
	
	++$self->{test_count};
	return $self;
}


sub make_log_file{
	my $self = shift;

	# �Ǿ��ͤ�$fixer�Ȥ���
	my %labels;
	my $fixer = 0;
	foreach my $i (values %{$self->{result_log}}){  # $i = ��
		foreach my $h (values %{$i}){               # $h = ��и���
			foreach my $j (keys %{$h->{l}}){        # $j = ��٥�
				$labels{$j} = 1 unless $labels{$j} = 1;
				$fixer = $h->{l}{$j} if $fixer > $h->{l}{$j};
			}
		}
	}
	my @labels = sort (keys %labels);

	my $obj;
	$obj->{labels}     = \@labels;
	$obj->{fixer}      = $fixer;
	$obj->{tani}       = $self->{tani};
	$obj->{file_model} = '�ʸ���������';
	$obj->{outvar}     = '�ʸ���������';
	$obj->{log}        = $self->{result_log};
	$obj->{prior_probs}= undef;

	Storable::nstore($obj, $self->{cross_path});

	return 1;
}

# �ƥ����̤˻�����Ψ����¸
sub push_prior_probs{
	my $self = shift;
	
	foreach my $i (keys %{$self->{result_log}}){
		unless ( $self->{result_log}{$i}{'[������Ψ]'}{v} ){
			$self->{result_log}{$i}{'[������Ψ]'}{v} = 1;
			$self->{result_log}{$i}{'[������Ψ]'}{l} = 
				$self->{cls}{model}{prior_probs};
		}
	}
	return $self;
}

1;