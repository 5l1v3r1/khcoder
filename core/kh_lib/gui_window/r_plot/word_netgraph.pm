package gui_window::r_plot::word_netgraph;
use base qw(gui_window::r_plot);


sub start{
	my $self = shift;
	
	$self->{button_interactive} = $self->{bottom_frame}->Button(
		-text => kh_msg->get('interactive'), # ���󥿥饯�ƥ���
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub {
			my $html = $::project_obj->file_TempHTML;
			$self->{plots}[$self->{ax}]->save($html);
			gui_OtherWin->open($html);
		}
	)->pack(-side => 'right');
	
	$self->win_obj->bind(
		'<Key-i>',
		sub{
			$self->{button_interactive}->flash;
			$self->{button_interactive}->invoke;
		}
	);
	
	@{$self->{coordi}} = ();
	open(my $fh, '<:encoding(utf8)', $self->{coord}) or die("file: $self->{coord}");
	while (<$fh>) {
		chomp;
		push @{$self->{coordi}}, [split /\t/, $_];
	}
	close $fh;

	my ($mag, $xmag, $xo, $yo, $tw, $th) = (1.1, 1.105, 77, 30, 30, 11);
	$xo = $xo * $self->{img_height} / 640;
	$yo = $yo * $self->{img_height} / 640;
	$tw = $tw * $self->{img_height} / 640;
	$th = $th * $self->{img_height} / 640;
	
	$self->{coordin} = {};
	foreach my $i (@{$self->{coordi}}){
		my $x1 = $i->[1] * $self->{img_height} / $xmag + $xo - $tw;
		my $y1 = $self->{img_height} - ($i->[2] * $self->{img_height} / $mag  + $yo + $th);
		my $x2 = $i->[1] * $self->{img_height} / $xmag + $xo + $tw;
		my $y2 = $self->{img_height} - ($i->[2] * $self->{img_height} / $mag + $yo - $th);
		
		$x1 = int($x1);
		$x2 = int($x2);
		$y1 = int($y1);
		$y2 = int($y2);
		
		my $id = $self->{canvas}->createRectangle(
			$x1,$y1, $x2, $y2,
			-outline => ""
		);
		
		$self->{canvas}->bind(
			$id,
			"<Enter>",
			sub { $self->decorate($id); }
		);
		$self->{canvas}->bind(
			$id,
			"<Button-1>",
			sub { $self->show_kwic($id); }
		);
		$self->{canvas}->bind(
			1,
			"<Button-1>",
			sub { $self->undecorate; }
		);
		
		$self->{coordin}{$id} = {
			'x1' => $x1,
			'x2' => $x2,
			'y1' => $y1,
			'y2' => $y2,
			'name' => $i->[0],
		};
	}
}

sub show_kwic{
	my $self = shift;
	my $id = shift;

	# ���󥳡����󥹤θƤӽФ�
	my $conc = gui_window::word_conc->open;
	$conc->entry->delete(0,'end');
	$conc->entry4->delete(0,'end');
	$conc->entry2->delete(0,'end');
	$conc->entry->insert('end', $self->{coordin}{$id}{name});
	$conc->search;
	
}

sub decorate{
	my $self = shift;
	my $id = shift;
	
	print "decorate: $id, $self->{coordin}{$id}{x1}\n";
	
	return 1 if $self->{coordin}{$id}{did};
	
	# show
	$self->{coordin}{$id}{did} = $self->{canvas}->createRectangle(
		$self->{coordin}{$id}{x1} -1,
		$self->{coordin}{$id}{y1} +1,
		$self->{coordin}{$id}{x2} +1,
		$self->{coordin}{$id}{y2} -1,
		-outline => '#778899',
		-width   => 1,
	);
	
	# unshow others
	foreach my $i (@{$self->{coordin}{decorated}}){
		if ($i == $id) {
			next;
		}
		if ( $self->{coordin}{$i}{did} ){
			$self->{canvas}->delete( $self->{coordin}{$i}{did} );
			$self->{coordin}{$i}{did} = undef;
		}
	}
	@{$self->{coordin}{decorated}} = ();
	
	push @{$self->{coordin}{decorated}}, $id;
}

sub undecorate{
	my $self = shift;
	
	print "undecorate\n";
	
	foreach my $i (@{$self->{coordin}{decorated}}){
		if ( $self->{coordin}{$i}{did} ){
			$self->{canvas}->delete( $self->{coordin}{$i}{did} );
			$self->{coordin}{$i}{did} = undef;
		}
	}
	@{$self->{coordin}{decorated}} = ();

}



sub option1_options{
	my $self = shift;
	
	if (@{$self->{plots}} == 2){
		return [
			kh_msg->get('gui_window::r_plot::word_netgraph->col'), # ���顼
			kh_msg->get('gui_window::r_plot::word_netgraph->gray'), # ���졼
		] ;
	}
	elsif (@{$self->{plots}} == 8){
		return [
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_b'), # �濴�����޲��
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_d'), # �濴���ʼ�����
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_v'), # �濴���ʸ�ͭ�٥��ȥ��
			kh_msg->get('gui_window::r_plot::word_netgraph->com_b'), # ���֥���ո��С��޲��
			kh_msg->get('gui_window::r_plot::word_netgraph->com_r'),
			kh_msg->get('gui_window::r_plot::word_netgraph->com_m'), # ���֥���ո��С�modularity��
			kh_msg->get('gui_window::r_plot::word_netgraph->cor'),  # ���
			kh_msg->get('gui_window::r_plot::word_netgraph->none'),  # �ʤ�
		];
	} else {
		return [
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_b'), # �濴�����޲��
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_d'), # �濴���ʼ�����
			kh_msg->get('gui_window::r_plot::word_netgraph->cnt_v'), # �濴���ʸ�ͭ�٥��ȥ��
			kh_msg->get('gui_window::r_plot::word_netgraph->com_b'), # ���֥���ո��С��޲��
			kh_msg->get('gui_window::r_plot::word_netgraph->com_r'),
			kh_msg->get('gui_window::r_plot::word_netgraph->com_m'), # ���֥���ո��С�modularity��
			kh_msg->get('gui_window::r_plot::word_netgraph->none'),  # �ʤ�
		];
	}

}

sub save{
	my $self = shift;

	# ��¸��λ���
	my @types = (
		[ "PDF",[qw/.pdf/] ],
		[ "Encapsulated PostScript",[qw/.eps/] ],
		[ "SVG",[qw/.svg/] ],
		[ "PNG",[qw/.png/] ],
		[ "GraphML",[qw/.graphml/] ],
		[ "Pajek",[qw/.net/] ],
		[ "Interactive HTML",[qw/.html/] ],
		[ "R Source",[qw/.r/] ],
	);
	@types = ([ "Enhanced Metafile",[qw/.emf/] ], @types)
		if $::config_obj->os eq 'win32';

	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.pdf',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jt(kh_msg->get('gui_window::r_plot->saving')), # �ץ�åȤ���¸
		-initialdir       => $self->gui_jchar($::config_obj->cwd)
	);

	$path = $self->gui_jg_filename_win98($path);
	$path = $self->gui_jg($path);
	$path = $::config_obj->os_path($path);

	$self->{plots}[$self->{ax}]->save($path) if $path;

	return 1;
}

sub option1_name{
	return kh_msg->get('gui_window::r_plot::word_netgraph->color'); #  ���顼��
}

sub win_title{
	return kh_msg->get('win_title'); # ��и졦�����ͥåȥ��
}

sub win_name{
	return 'w_word_netgraph_plot';
}


sub base_name{
	return 'word_netgraph';
}

1;