package gui_window::cod_corresp_plot_opt;
use base qw(gui_window);

sub _new{
	my $self = shift;
	my %args = @_;
	
	$self->{command_f} = $args{command_f};
	
	$self->{win_obj}->title($self->gui_jt('�б�ʬ�ϥץ�åȡʥ����ɡˤ�Ĵ��'));
	
	my $lf = $self->{win_obj}->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x', -expand => 0);
	
	
	# ��ʬ
	my $fd = $lf->Frame()->pack(
		-fill => 'x',
		#-padx => 2,
		-pady => 4,
	);

	$fd->Label(
		-text => $self->gui_jchar('��ʬ����'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_d_n} = $fd->Entry(
		-font       => "TKFN",
		-width      => 2,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_d_n}->insert(0,'2');
	$self->{entry_d_n}->bind("<Key-Return>",sub{$self->calc;});

	$fd->Label(
		-text => $self->gui_jchar('  x������ʬ��'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_d_x} = $fd->Entry(
		-font       => "TKFN",
		-width      => 2,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_d_x}->insert(0,'1');
	$self->{entry_d_x}->bind("<Key-Return>",sub{$self->calc;});

	$fd->Label(
		-text => $self->gui_jchar('  y������ʬ��'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_d_y} = $fd->Entry(
		-font       => "TKFN",
		-width      => 2,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_d_y}->insert(0,'2');
	$self->{entry_d_y}->bind("<Key-Return>",sub{$self->calc;});
	
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
	
	my $d_n = $self->gui_jg( $self->{entry_d_n}->get );
	my $d_x = $self->gui_jg( $self->{entry_d_x}->get );
	my $d_y = $self->gui_jg( $self->{entry_d_y}->get );
	
	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

	my $r_command = '';
	if ($self->{command_f} =~ /\A(.+)library\(MASS\).+/s){
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

	$r_command .= "library(MASS)\n";
	$r_command .= "c <- corresp(d, nf=$d_n)\n";

	my $r_command_tmp = $r_command;
	$r_command_tmp = Jcode->new($r_command_tmp)->sjis
		if $::config_obj->os eq 'win32';
	$::config_obj->R->send($r_command_tmp);
	
	# ��ͿΨ�μ���
	$::config_obj->R->send(
		'print( paste("khcoder", min(nrow(d), ncol(d)), sep="" ) )'
	);
	my $count = $::config_obj->R->read;
	my $kiyo1;
	my $kiyo2;
	if ($count =~ /"khcoder(.+)"/){
		$count = $1;
	} else {
		$count = -1;
	}
	while ($count > 0){
		#print "$count\n";
		$::config_obj->R->send(
			 'print( paste("khcoder",round('
			."c(c\$cor[$d_x], c\$cor[$d_y])^2"
			.'/sum(corresp(d, nf='
			.$count
			.')$cor^2) * 100,2), sep=""))'
		);
		my $t = $::config_obj->R->read;
		if ($t =~ /"khcoder(.+)".*"khcoder(.+)"/){
			$kiyo1 = $1;
			$kiyo2 = $2;
			last;
		}
		--$count;
	}

	# �ץ�åȤΤ����R���ޥ��
	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

	my ($r_command_2a, $r_command_2, $r_command_a);
	if (not ($self->{command_f} =~ /rscore/)){              # Ʊ�����֤ʤ�
		# ��٥�ȥɥåȤ�ץ�å�
		$r_command_2a = 
			 "plot(cbind(c\$cscore[,$d_x], c\$cscore[,$d_y]),col=\"red\","
				.'pch=20,xlab="��ʬ'.$d_x
				.' ('.$kiyo1.'%)",ylab="��ʬ'.$d_y.' ('.$kiyo2.'%)")'
				."\n"
			."library(maptools)\n"
			."pointLabel(x=c\$cscore[,$d_x], y=c\$cscore[,$d_y], offset=0,"
				."labels=rownames(c\$cscore), cex=$fontsize)\n";
		;
		$r_command_2 = $r_command.$r_command_2a;
		
		# �ɥåȤΤߥץ�å�
		$r_command_a .=
			 "plot(cbind(c\$cscore[,$d_x], c\$cscore[,$d_y]),"
				.'xlab="��ʬ'.$d_x
				.' ('.$kiyo1.'%)",ylab="��ʬ'.$d_y.' ('.$kiyo2.'%)")'
				."\n"
		;
	} else {                                      # Ʊ�����֤���
		# ��٥�ȥɥåȤ�ץ�å�
		$r_command_2a .= 
			 'plot(cb <- rbind('
				."cbind(c\$cscore[,$d_x], c\$cscore[,$d_y], 1),"
				."cbind(c\$rscore[,$d_x], c\$rscore[,$d_y], 2)"
				.'), xlab="��ʬ'.$d_x.' ('.$kiyo1
				.'%)", ylab="��ʬ'.$d_y.' ('.$kiyo2
				.'%)",pch=c(20,0)[cb[,3]], col=c("red","red")[cb[,3]] )'."\n"
			."library(maptools)\n"
			."pointLabel("
				."x=c(c\$cscore[,$d_x], c\$rscore[,$d_x]),"
				."y=c(c\$cscore[,$d_y], c\$rscore[,$d_y]),"
				."labels=c(rownames(c\$cscore),rownames(c\$rscore)),"
				."cex=$fontsize, col=c(\"black\",\"blue\")[cb[,3]])"
		;
		$r_command_2 = $r_command.$r_command_2a;
		
		# �ɥåȤΤߤ�ץ�å�
		$r_command_a .=
			 'plot(cb <- rbind('
				."cbind(c\$cscore[,$d_x], c\$cscore[,$d_y], 1),"
				."cbind(c\$rscore[,$d_x], c\$rscore[,$d_y], 2)"
				.'), xlab="��ʬ'.$d_x.' ('.$kiyo1
				.'%)", ylab="��ʬ'.$d_y.' ('.$kiyo2
				.'%)",pch=c(1,15)[cb[,3]] )'."\n"
		;
	}

	$r_command .= $r_command_a;

	# �ץ�åȺ���
	use kh_r_plot;
	my $plot1 = kh_r_plot->new(
		name      => 'codes_CORRESP1',
		command_a => $r_command_a,
		command_f => $r_command,
		width     => $self->gui_jg( $self->{entry_plot_size}->get ),
		height    => $self->gui_jg( $self->{entry_plot_size}->get ),
	) or return 0;

	my $plot2 = kh_r_plot->new(
		name      => 'codes_CORRESP2',
		command_a => $r_command_2a,
		command_f => $r_command_2,
		width     => $self->gui_jg( $self->{entry_plot_size}->get ),
		height    => $self->gui_jg( $self->{entry_plot_size}->get ),
	) or return 0;

	# �ץ�å�Window�򳫤�
	if ($::main_gui->if_opened('w_cod_corresp_plot')){
		$::main_gui->get('w_cod_corresp_plot')->close;
	}
	$self->close;
	gui_window::cod_corresp_plot->open(
		plots       => [$plot2,$plot1],
		no_geometry => 1,
	);
}

sub win_name{
	return 'w_cod_corresp_plot_opt';
}

1;