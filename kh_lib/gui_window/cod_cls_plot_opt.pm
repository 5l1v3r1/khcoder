package gui_window::cod_cls_plot_opt;
use base qw(gui_window);

sub _new{
	my $self = shift;
	my %args = @_;
	
	$self->{command_f} = $args{command_f};
	
	$self->{win_obj}->title($self->gui_jt('���饹����ʬ�ϡʥ����ɡˤ�Ĵ��'));
	
	my $lf = $self->{win_obj}->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x', -expand => 0);

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
	$self->{entry_cluster_number}->insert(0,'0');
	$self->{entry_cluster_number}->bind("<Key-Return>",sub{$self->calc;});

	# �ե���ȥ�����
	my $ff = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 4,
	);

	$ff->Label(
		-text => $self->gui_jchar('�ե���ȥ�������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_font_size} = $ff->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_font_size}->insert(0,'80');
	$self->{entry_font_size}->bind("<Key-Return>",sub{$self->calc;});

	$ff->Label(
		-text => $self->gui_jchar('%'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$ff->Label(
		-text => $self->gui_jchar('  �ץ�åȥ�������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_plot_size} = $ff->Entry(
		-font       => "TKFN",
		-width      => 4,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_plot_size}->insert(0,'480');
	$self->{entry_plot_size}->bind("<Key-Return>",sub{$self->calc;});
	
	$self->{win_obj}->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $self->{win_obj}->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2, -pady => 2);

	$self->{win_obj}->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $self->{win_obj}->after(10,sub{$self->calc;});}
	)->pack(-side => 'right', -pady => 2);

	return $self;
}

sub calc{
	my $self = shift;

	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

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

	my $cluster_number = $self->gui_jg( $self->{entry_cluster_number}->get );

	my $r_command_2a = 
		 'plot(hclust(dist(d,method="binary"),method="'
			.'single'
			.'"),labels=rownames(d), main="", sub="", xlab="",ylab="",'
			."cex=$fontsize, hang=-1)\n"
	;
	$r_command_2a .= 
		'rect.hclust(hclust(dist(d,method="binary"),method="'
			.'single'
			.'"), k='.$cluster_number.', border="#FF8B00FF")'
		if $cluster_number > 1;
	
	my $r_command_2 = $r_command.$r_command_2a;

	my $r_command_3a = 
		 'plot(hclust(dist(d,method="binary"),method="'
			.'complete'
			.'"),labels=rownames(d), main="", sub="", xlab="",ylab="",'
			."cex=$fontsize, hang=-1)\n"
	;
	$r_command_3a .= 
		'rect.hclust(hclust(dist(d,method="binary"),method="'
			.'complete'
			.'"), k='.$cluster_number.', border="#FF8B00FF")'
		if $cluster_number > 1;
	my $r_command_3 = $r_command.$r_command_3a;

	$r_command .=
		'plot(hclust(dist(d,method="binary"),method="'
			.'average'
			.'"),labels=rownames(d), main="", sub="", xlab="",ylab="",'
			."cex=$fontsize, hang=-1)\n"
	;
	$r_command .= 
		'rect.hclust(hclust(dist(d,method="binary"),method="'
			.'average'
			.'"), k='.$cluster_number.', border="#FF8B00FF")'
		if $cluster_number > 1;

	# �ץ�åȺ���
	use kh_r_plot;
	my $plot1 = kh_r_plot->new(
		name      => 'codes_CLS1',
		command_f => $r_command,
		width     => $self->gui_jg( $self->{entry_plot_size}->get ),
		height    => 480,
	) or return 0;

	my $plot2 = kh_r_plot->new(
		name      => 'codes_CLS2',
		command_a => $r_command_2a,
		command_f => $r_command_2,
		width     => $self->gui_jg( $self->{entry_plot_size}->get ),
		height    => 480,
	) or return 0;

	my $plot3 = kh_r_plot->new(
		name      => 'codes_CLS3',
		command_a => $r_command_3a,
		command_f => $r_command_3,
		width     => $self->gui_jg( $self->{entry_plot_size}->get ),
		height    => 480,
	) or return 0;

	# �ץ�å�Window�򳫤�
	if ($::main_gui->if_opened('w_cod_cls_plot')){
		$::main_gui->get('w_cod_cls_plot')->close;
	}
	$self->close;
	gui_window::cod_cls_plot->open(
		plots       => [$plot1,$plot2,$plot3],
		no_geometry => 1,
	);

	return 1;
}

sub win_name{
	return 'w_cod_cls_plot_opt';
}

1;