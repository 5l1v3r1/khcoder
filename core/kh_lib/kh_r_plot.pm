package kh_r_plot;
use strict;
use Image::Magick;

my $if_font = 0;

sub new{
	my $class = shift;
	my %args = @_;
	my $self = \%args;
	bless $self, $class;
	
	return undef unless $::config_obj->R;
	
	# �ե�����̾
	my $icode = Jcode::getcode($::project_obj->dir_CoderData);
	my $dir   = Jcode->new($::project_obj->dir_CoderData, $icode)->euc;
	$dir =~ tr/\\/\//;
	$dir = Jcode->new($dir,'euc')->$icode unless $icode eq 'ascii';
	$self->{path} = $dir.$self->{name};
	unlink($self->{path}) if -e $self->{path};
	
	# ���ޥ�ɤ�ʸ��������
	$self->{command_f} = Jcode->new($self->{command_f})->sjis
		if $::config_obj->os eq 'win32';
	$self->{command_a} = Jcode->new($self->{command_a})->sjis
		if $::config_obj->os eq 'win32' and length($self->{command_a});
	my $command = '';
	
	if (length($self->{command_a})){
		$command = $self->{command_a};
		#print "com_a: $command\n";
	} else {
		$command = $self->{command_f};
	}
	
	# Linux�ѥե��������
	if ( ($::config_obj->os ne 'win32') and ($if_font == 0) ){
		system('xset fp rehash');
		
		# R 2.7�ʹߤξ��Ϥ��Υ��ޥ�ɤǤϤ��ᤫ�⡩
		$::config_obj->R->send(
			 'options(X11fonts = c('
			.'"-*-gothic-%s-%s-normal--%d-*-*-*-*-*-*-*",'
			.'"-adobe-symbol-*-*-*-*-%d-*-*-*-*-*-*-*"))'
		);
		
		$if_font = 1;
	}

	# width��height�Υ����å�
	unless (
		   (length($self->{width} ) == 0 || $self->{width}  =~ /^[0-9]+$/)
		&& (length($self->{height}) == 0 || $self->{height} =~ /^[0-9]+$/)
	){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ץ�åȥ������λ��꤬�����Ǥ���',
		);
		return 0;
	}

	# �ץ�åȺ���
	$::config_obj->R->output_chk(0);
	$::config_obj->R->lock;
	$self->{path} = $::config_obj->R_device(
		$self->{path},
		$self->{width},
		$self->{height},
	);
	$self->set_par;
	$::config_obj->R->send($command);
	$self->{r_msg} = $::config_obj->R->read;
	$::config_obj->R->send('dev.off()');
	$::config_obj->R->unlock;
	$::config_obj->R->output_chk(1);
	
	# ��̤Υ����å�
	if (
		not (-e $self->{path})
		or ( $self->{r_msg} =~ /error/i )
		or ( index($self->{r_msg},'���顼') > -1 )
		or ( index($self->{r_msg},Jcode->new('���顼','euc')->sjis) > -1 )
	) {
		gui_errormsg->open(
			type   => 'msg',
			window  => \$::main_gui->mw,
			msg    => "����ޤ�������˼��Ԥ��ޤ���\n\n".$self->{r_msg}
		);
		return 0;
	}
	#print "$self->{r_msg}\n";
	
	return $self;
}

sub set_par{
	my $self = shift;
	$::config_obj->R->send(
		'par(mai=c(0,0,0,0), mar=c(4,4,1,1), omi=c(0,0,0,0), oma =c(0,0,0,0) )'
	);
	return $self;
}

sub rotate_cls{
	my $self = shift;
	my $path_png = $self->{path};
	my $bmp_flg = 0;
	
	if ($path_png =~ /\.bmp$/){
		chop $path_png;
		chop $path_png;
		chop $path_png;
		$path_png .= 'png';
		
		$self->{width}  = 480 unless $self->{width};
		$self->{height} = 480 unless $self->{height};

		my $command = '';
		if (length($self->{command_a})){
			$command = $self->{command_a};
		} else {
			$command = $self->{command_f};
		}

		# �ץ�åȺ���
		$::config_obj->R->output_chk(0);
		$::config_obj->R->lock;
		$::config_obj->R->send(
			 "png(\"$path_png\", width=$self->{width},"
			."height=$self->{height}, unit=\"px\")"
		);
		$::config_obj->R->send($command);
		$::config_obj->R->send('dev.off()');
		$::config_obj->R->unlock;
		$::config_obj->R->output_chk(1);
		$bmp_flg = 1;
	}
	
	my $temp_png = "hoge";
	my $n = 0;
	while (-e "$temp_png$n.png"){
		++$n;
	}
	$temp_png = "$temp_png$n.png";
	rename($path_png, $temp_png);
	
	my $p = Image::Magick->new;
	$p->Read($temp_png);
	$p->Rotate(degrees=>90);
	
	if ($self->{width} > 1000){
		my $cut = int( $self->{width} - $self->{width} * 0.032 + 5);
		$p->Crop(geometry=> $self->{height}."x".$cut."+0+0");
	}
	
	if ($bmp_flg){ 
		$p->Write(filename=>"bmp:$self->{path}", compression=>'None');
	} else {
		$p->Write($temp_png);
		rename($temp_png, $path_png);
	}
	
	return $self;
}

sub save{
	my $self = shift;
	my $path = shift;
	
	my $icode = Jcode::getcode($path);
	$path = Jcode->new($path, $icode)->euc;
	$path =~ tr/\\/\//;
	$path = Jcode->new($path,'euc')->$icode unless $icode eq 'ascii';
	
	if ($path =~ /\.r$/i){
		$self->_save_r($path);
	}
	elsif ($path =~ /\.png$/i){
		$self->_save_png($path);
	}
	elsif ($path =~ /\.eps$/i){
		$self->_save_eps($path);
	}
	elsif ($path =~ /\.pdf$/i){
		$self->_save_pdf($path);
	}
	elsif ($path =~ /\.emf$/i){
		$self->_save_emf($path);
	}
	else {
		warn "The file type is not supported yet:\n$path\n";
	}
}

sub _save_emf{
	my $self = shift;
	my $path = shift;
	
	# �ץ�åȺ���
	$::config_obj->R->output_chk(0);
	$::config_obj->R->lock;
	$::config_obj->R->send(
		 "win.metafile(filename=\"$path\", width = 7, height = 7 )"
	);
	$::config_obj->R->send($self->{command_f});
	$::config_obj->R->send('dev.off()');
	$::config_obj->R->unlock;
	$::config_obj->R->output_chk(1);
	
	return 1;
}

sub _save_pdf{
	my $self = shift;
	my $path = shift;
	
	# �ץ�åȺ���
	$::config_obj->R->output_chk(0);
	$::config_obj->R->lock;
	$::config_obj->R->send(
		 "pdf(file=\"$path\", height = 7, width = 7,"
		."family=\"Japan1GothicBBB\")"
	);
	$::config_obj->R->send($self->{command_f});
	$::config_obj->R->send('dev.off()');
	$::config_obj->R->unlock;
	$::config_obj->R->output_chk(1);
	
	return 1;
}


sub _save_eps{
	my $self = shift;
	my $path = shift;
	
	# �ץ�åȺ���
	$::config_obj->R->output_chk(0);
	$::config_obj->R->lock;
	$::config_obj->R->send(
		 "postscript(\"$path\", horizontal = FALSE, onefile = FALSE,"
		."paper = \"special\", height = 7, width = 7,"
		."family=\"Japan1GothicBBB\" )"
	);
	$::config_obj->R->send($self->{command_f});
	$::config_obj->R->send('dev.off()');
	$::config_obj->R->unlock;
	$::config_obj->R->output_chk(1);
	
	return 1;
}

sub _save_png{
	my $self = shift;
	my $path = shift;
	
	$self->{width}  = 480 unless $self->{width};
	$self->{height} = 480 unless $self->{height};
	
	# �ץ�åȺ���
	$::config_obj->R->output_chk(0);
	$::config_obj->R->lock;
	$::config_obj->R->send(
		 "png(\"$path\", width=$self->{width},"
		."height=$self->{height}, unit=\"px\")"
	);
	$::config_obj->R->send($self->{command_f});
	$::config_obj->R->send('dev.off()');
	$::config_obj->R->unlock;
	$::config_obj->R->output_chk(1);
	
	return 1;
}

sub _save_r{
	my $self = shift;
	my $path = shift;
	
	open (OUTF,">$path") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => $path,
		);
	print OUTF $self->{command_f},"\n";
	close (OUTF);
	
	return 1;
}

sub command_f{
	my $self = shift;
	return $self->{command_f};
}

sub r_msg{
	my $self = shift;
	return $self->{r_msg};
}

sub path{
	my $self = shift;
	return $self->{path};
}

1;