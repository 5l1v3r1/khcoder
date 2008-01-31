package gui_window::use_te_g;
use base qw(gui_window);
use strict;
use Tk;

#------------------#
#   Window�򳫤�   #

sub _new{
	my $self = shift;
	$self->{win_obj}->title(
		$self->gui_jchar('TermExtract�ˤ��ʣ���θ���','euc')
	);
	
	$self->{win_obj}->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => 'TKFN',
		-width => 8,
		-command => sub{
			$self->{win_obj}->after(10,sub{$self->close;})
		}
	)->pack(-anchor=>'e',-side => 'right',-padx => 2, -pady => 2);

	my $ok_btn = $self->{win_obj}->Button(
		-text  => 'OK',
		-font  => 'TKFN',
		-width => 8,
		-command => sub{ $self->{win_obj}->after
			(
				10,
				sub {
					$self->run;
				}
			);
		}
	)->pack(-anchor => 'e',-side => 'right',  -pady => 2);
	
	
	return $self;
}

#----------#
#   �¹�   #

sub run{
	my $self = shift;
	my $debug = 1;

	# �����ǲ���
	
	my $source = $::project_obj->file_target;
	my $dist   = $::project_obj->file_m_target;
	unlink($dist);
	my $icode = kh_jchar->check_code($source);
	open (MARKED,">$dist") or 
		gui_errormsg->open(
			type => 'file',
			thefile => $dist
		);
	open (SOURCE,"$source") or
		gui_errormsg->open(
			type => 'file',
			thefile => $source
		);
	while (<SOURCE>){
		chomp;
		my $text = Jcode->new($_,$icode)->h2z->euc;
		$text =~ s/ /��/go;
		print MARKED "$text\n";
	}
	close (SOURCE);
	close (MARKED);
	kh_jchar->to_sjis($dist) if $::config_obj->os eq 'win32';
	
	kh_morpho->run;

	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_euc($::project_obj->file_MorphoOut);
			my $ta2 = new Benchmark;
	}

	# �ե��륿����Ѥ�ñ̾��Υꥹ�Ȥ����
	my %is_alone = ();
	open (CHASEN,$::project_obj->file_MorphoOut) or 
			gui_errormsg->open(
				type    => 'file',
				thefile => $::project_obj->file_MorphoOut
			);
	while (<CHASEN>){
		$is_alone{(split /\t/, $_)[0]} = 1;
	}
	close (CHASEN);

	# TermExtract�μ¹�
	use TermExtract::Chasen;
	my $te_obj = new TermExtract::Chasen;
	my @noun_list = $te_obj->get_imp_word($::project_obj->file_MorphoOut);

	# ����
	my $target_csv = $::project_obj->file_HukugoListTE;
	open (OUT,">$target_csv") or
		gui_errormsg->open(
			type => 'file',
			thefile => $target_csv
		);;
	print OUT "�������,������\n";

	foreach (@noun_list) {
		next if $is_alone{$_->[0]};  # ñ̾��
		next if $_->[0] =~ /^(����)*(ʿ��)*(\d+ǯ)*(\d+��)*(\d+��)*(����)*(���)*(\d+��)*(\d+ʬ)*(\d+��)*$/; # ���ա�����
		my $tmp = Jcode->new($_->[0], 'euc')->tr('��-��','0-9'); # ���ͤΤ�
		next if $tmp =~ /^\d+$/;

		print OUT
			kh_csv->value_conv($_->[0]),
			",$_->[1]\n"
		;
	}
	close (OUT);
	kh_jchar->to_sjis("$target_csv") if $::config_obj->os eq 'win32';
	print "ok!!\n";
	gui_OtherWin->open($target_csv);
}

#--------------#
#   ��������   #

sub win_name{
	return 'w_use_te_g';
}
1;