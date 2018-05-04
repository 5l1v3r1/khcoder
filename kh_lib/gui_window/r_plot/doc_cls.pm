package gui_window::r_plot::doc_cls;
use base qw(gui_window::r_plot);

sub save{
	my $self = shift;

	# ��¸��λ���
	my @types = (
		[ "Encapsulated PostScript",[qw/.eps/] ],
		[ "PDF",[qw/.pdf/] ],
		[ "SVG",[qw/.svg/] ],
		[ "PNG",[qw/.png/] ],
		[ "R Source",[qw/.r/] ],
	);
	@types = ([ "Enhanced Metafile",[qw/.emf/] ], @types)
		if $::config_obj->os eq 'win32';

	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.eps',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jt(kh_msg->get('gui_window::r_plot->saving')), # �ץ�åȤ���¸
		-initialdir       => $self->gui_jchar($::config_obj->cwd)
	);

	$path = $self->gui_jg_filename_win98($path);
	$path = $self->gui_jg($path);
	$path = $::config_obj->os_path($path);
	
	# R�ե��������¸����������ӽ�����
	if ($path =~ /.*\.r$/){
		$self->save_r($path);
	} else {
		$self->{plots}[$self->{ax}]->save($path) if $path;
	}
	return 1;
}

# R�ե��������¸�������
sub save_r{
	my $self = shift;
	my $path = shift;
	
	# tmp�ե�����̾����
	my $file_tmp = '';
	if (
		$self->{plots}[0]->{command_f}
		=~ /read.csv\("(.+?)"\)\n/
	) {
		$file_tmp = $1;
		$file_tmp =~ s/\\\\/\\/g;
	}

	# tmp�ե��������¸�Ѥ˥��ԡ�
	my $file_csv = $path.'.csv';
	if (-e $file_csv){
		my $msg = Jcode->new($file_csv)->euc;
		my $ans = $self->win_obj->messageBox(
			-message => $self->gui_jchar
				(
				   kh_msg->get('gui_window::cls_height::doc->overwr') # ���Υե�������񤭤��Ƥ�����Ǥ�����
				   ."\n"
				   ."$file_csv"
				),
			-icon    => 'question',
			-type    => 'OKCancel',
			-title   => 'KH Coder'
		);
		unless ($ans =~ /ok/i){ return 0; }
		unlink($file_csv);
	}
	use File::Copy;
	copy($file_tmp, $file_csv)
		or gui_errormsg->open(
			type => 'file',
			file => $file_csv,
	);

	# r���ޥ�ɤ��ѹ�
	if ($::config_obj->os eq 'win32'){
		$file_csv = Jcode->new($file_csv)->euc;
		$file_csv =~ s/\\/\\\\/g;
		$file_csv = Jcode->new($file_csv,'euc')->sjis;
	}
	$self->{plots}[0]->{command_f}
		=~ s/^.+read.csv\(".+?"\)\n/\n/;
	$self->{plots}[0]->{command_f} =
		'd <- read.csv("'.$file_csv.'")'."\n"
		.$self->{plots}[0]->{command_f};

	$self->{plots}[0]->save($path) if $path;

	return 1;
}


sub photo_pane_width{
	return 490;
}

sub option1_options{
	return [ 'nothing' ];
}

sub option1_name{
	return '';
}

sub win_title{
	return kh_msg->get('win_title'); # ʸ��Υǥ�ɥ����
}

sub win_name{
	return 'w_doc_cls_plot';
}


sub base_name{
	return 'doc_cls';
}

1;