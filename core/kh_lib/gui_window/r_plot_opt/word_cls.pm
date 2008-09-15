package gui_window::r_plot_opt::word_cls;
use base qw(gui_window::r_plot_opt);

sub innner{
	my $self = shift;
	my $lf = $self->{labframe};

	# ���饹������
	my $f4 = $lf->Frame()->pack(
		-fill => 'x',
		-padx => 2,
		-pady => 2
	);
	$f4->Label(
		-text => $self->gui_jchar('���饹��������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_cluster_number} = $f4->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	if ( $self->{command_f} =~ /rect\.hclust.+k=([0-9]+)[, \)]/ ){
		$self->{entry_cluster_number}->insert(0,$1);
	} else {
		$self->{entry_cluster_number}->insert(0,'0');
	}
	$self->{entry_cluster_number}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_cluster_number});

	return $self;
}

sub calc{
	my $self = shift;

	my $r_command = '';
	if ($self->{command_f} =~ /\A(.+)# END: DATA.+/s){
		$r_command = $1;
		#print "chk: $r_command\n";
		$r_command = Jcode->new($r_command)->euc
			if $::config_obj->os eq 'win32';
	} else {
		gui_errormsg->open(
			type => 'msg',
			msg  => 'Ĵ���˼��Ԥ��ޤ��ޤ�����',
		);
		print "$self->{command_f}\n";
		$self->close;
		return 0;
	}

	$r_command .= "# END: DATA\n";

	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

	&gui_window::word_cls::make_plot(
		base_win       => $self,
		cluster_number => $self->gui_jg( $self->{entry_cluster_number}->get ),
		font_size      => $fontsize,
		plot_size      => $self->gui_jg( $self->{entry_plot_size}->get ),
		r_command      => $r_command,
	);

	return 1;
}

sub win_title{
	return '��и졦���饹����ʬ�Ϥ�Ĵ��';
}

sub win_name{
	return 'w_word_cls_plot_opt';
}

1;