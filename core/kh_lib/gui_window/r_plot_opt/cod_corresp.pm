package gui_window::r_plot_opt::cod_corresp;
use base qw(gui_window::r_plot_opt);

sub innner{
	my $self = shift;
	my $lf = $self->{labframe};

	# ��ħ�������
	my $fs = $lf->Frame()->pack(
		-fill => 'x',
		#-padx => 2,
		-pady => 2,
	);

	$fs->Checkbutton(
		-text     => $self->gui_jchar('��ħŪ�ʥ����ɤ�����'),
		-variable => \$self->{check_filter},
		-command  => sub{ $self->refresh_flt;},
	)->pack(
		-anchor => 'w',
		-side  => 'left',
	);

	$self->{entry_flt_l1} = $fs->Label(
		-text => $self->gui_jchar(' �� ��̡�'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_flt} = $fs->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 0);
	$self->{entry_flt}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_flt});

	$self->{entry_flt_l2} = $fs->Label(
		-text => $self->gui_jchar('��'),
		-font => "TKFN",
	)->pack(-side => 'left');

	# ��ʬ
	my $fd = $lf->Frame()->pack(
		-fill => 'x',
		#-padx => 2,
		-pady => 4,
	);

	$fd->Label(
		-text => $self->gui_jchar('�ץ�åȤ�����ʬ'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$fd->Label(
		-text => $self->gui_jchar(' �� X����'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_d_x} = $fd->Entry(
		-font       => "TKFN",
		-width      => 2,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_d_x}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_d_x});

	$fd->Label(
		-text => $self->gui_jchar('  Y����'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_d_y} = $fd->Entry(
		-font       => "TKFN",
		-width      => 2,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_d_y}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_d_y});
	
	if ( $self->{command_f} =~ /\nd_x <\- ([0-9]+)\nd_y <\- ([0-9]+)\n/ ){
		my ($d_x, $d_y) = ($1, $2);
		$self->{entry_d_x}->insert(0,$d_x);
		$self->{entry_d_y}->insert(0,$d_y);
	} else {
		$self->{entry_d_x}->insert(0,'1');
		$self->{entry_d_y}->insert(0,'2');
	}

	if ( $self->{command_f} =~ /\nflt <\- ([0-9]+)\n/ ){
		if ($1){
			$self->{check_filter} = 1;
			$self->{entry_flt}->insert(0,$1);
		} else {
			$self->{check_filter} = 0;
			$self->{entry_flt}->insert(0,'50');
		}
		$self->refresh_flt;
	}

	return $self;
}

# ����ħ������ܡפΥ����å��ܥå���
sub refresh_flt{
	my $self = shift;
	if ( $self->{check_filter} ){
		$self->{entry_flt}   ->configure(-state => 'normal');
		$self->{entry_flt_l1}->configure(-state => 'normal');
		#$self->{entry_flt_l2}->configure(-state => 'normal');
	} else {
		$self->{entry_flt}   ->configure(-state => 'disabled');
		$self->{entry_flt_l1}->configure(-state => 'disabled');
		#$self->{entry_flt_l2}->configure(-state => 'disabled');
	}
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

	my $biplot = 0;
	$biplot = 1 if $self->{command_f} =~ /rscore/;

	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

	my $filter = 0;
	if ( $self->{check_filter} ){
		$filter = $self->gui_jg( $self->{entry_flt}->get );
	}

	&gui_window::word_corresp::make_plot(
		base_win     => $self,
		d_x          => $self->gui_jg( $self->{entry_d_x}->get ),
		d_y          => $self->gui_jg( $self->{entry_d_y}->get ),
		flt          => $filter,
		biplot       => $biplot,
		plot_size    => $self->gui_jg( $self->{entry_plot_size}->get ),
		font_size    => $fontsize,
		r_command    => $r_command,
		plotwin_name => 'cod_corresp',
	);

	$self->close
}

sub win_title{
	return '�����ǥ��󥰡��б�ʬ�ϡ�Ĵ��';
}

sub win_name{
	return 'w_cod_corresp_plot_opt';
}

1;