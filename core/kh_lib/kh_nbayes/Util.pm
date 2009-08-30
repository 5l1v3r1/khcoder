package kh_nbayes::Util;

use List::Util qw(max sum);

sub knb2csv{
	my $class = shift;
	my $self = {@_};
	bless $self, $class;
	
	# �ؽ���̤��ɤ߹���
	$self->{cls} = Algorithm::NaiveBayes->restore_state($self->{path});
	my $fixer = 0;
	foreach my $i (values %{$self->{cls}{model}{smoother}}){
		$fixer = $i if $fixer > $i;
	}
	
	# �ǡ�������
	my @labels = $self->{cls}->labels;
	my @rows;
	my %printed = ();
	foreach my $i (@labels){ # $i = ��٥�
		foreach my $h (keys %{$self->{cls}{model}{probs}{$i}}){ # $h = ��
			unless ( $printed{$h} ){
				my $current = [ kh_csv->value_conv($h) ];
				foreach my $k (@labels){ # $k = ��٥�
					push @{$current},
						(
							   $self->{cls}{model}{probs}{$k}{$h}
							|| $self->{cls}{model}{smoother}{$k} 
						)
						- $fixer
					;
				}
				push @rows, $current;
				$printed{$h} = 1;
			}
		}
	}
	
	# �񤭽Ф�
	open (COUT,">$self->{csv}") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => "$self->{csv}",
		);

	my $header = '';
	$header .= ',������,';
	for (my $n = 1; $n <= $#labels; ++$n){
		$header .= ',';
	}
	$header .= ",�Ԥ�%\n";

	$header .= "��и�,";
	foreach my $i (@labels){
		$header .= kh_csv->value_conv($i).',';
	}
	$header .= ',';
	foreach my $i (@labels){
		$header .= kh_csv->value_conv($i).',';
	}
	chop $header;
	print COUT "$header\n";

	my $c = @labels;
	foreach my $i (
		sort { sum( @{$b}[1..$c] ) <=> sum( @{$a}[1..$c] ) } 
		@rows
	){
		my $t = '';
		# ������
		foreach my $h ( @{$i} ){
			$t .= "$h,";
		}
		
		# �Ԥ�%
		$t .= ',';
		my $sum = sum( @{$i}[1..$c] );
		foreach my $h ( @{$i}[1..$c] ){
			$t .= $h / $sum * 100;
			$t .= ',';
		}
		
		chop $t;
		print COUT "$t\n";
	}
	close (COUT);
	kh_jchar->to_sjis($self->{csv}) if $::config_obj->os eq 'win32';
	
	return 1;
}

1;
