package kh_r_plot;
use strict;

my $if_font = 0;
my $if_lt25 = 0;

my $debug = 0;

sub new{
	my $class = shift;
	my %args = @_;
	my $self = \%args;
	bless $self, $class;
	
	return undef unless $::config_obj->R;
	
	# �ե�����̾
	my $icode = Jcode::getcode($::project_obj->file_datadir);
	my $dir   = Jcode->new($::project_obj->file_datadir, $icode)->euc;
	$dir =~ tr/\\/\//;
	$dir = Jcode->new($dir,'euc')->$icode
		if ( length($icode) and ( $icode ne 'ascii' ) );
	$self->{path} = $dir.'_'.$self->{name};
	
	# ���ޥ�ɤ�ʸ��������
	$self->{command_f} = Jcode->new($self->{command_f},'euc')->sjis
		if $::config_obj->os eq 'win32';
	$self->{command_a} = Jcode->new($self->{command_a},'euc')->sjis
		if $::config_obj->os eq 'win32' and length($self->{command_a});

	my $command = '';
	if (length($self->{command_a})){
		$command = $self->{command_a};
	} else {
		$command = $self->{command_f};
	}
	
	# Debug�ѽ���
	if ($::config_obj->r_plot_debug){
		my $file_debug = $self->{path}.'.r';
		open (RDEBUG, ">$file_debug") or 
			gui_errormsg->open(
				type    => 'file',
				thefile => $file_debug,
			)
		;
		print RDEBUG
			"# command_f\n",
			$self->{command_f},
			"\n\n# command_a\n",
			$self->{command_a}
		;
		close (RDEBUG)
	}
	
	# Linux�ѥե��������
	if ( ($::config_obj->os ne 'win32') and ($if_font == 0) ){
		system('xset fp rehash');
		$::config_obj->R->output_chk(0);
		if ( $::config_obj->R_version < 207 ){
			# 2.7����
			$::config_obj->R->send(
				 'options(X11fonts = c('
				.'"-*-gothic-%s-%s-normal--%d-*-*-*-*-*-*-*",'
				.'"-adobe-symbol-*-*-*-*-%d-*-*-*-*-*-*-*"))'
			);
		} else {
			# 2.7�ʹ�
			$::config_obj->R->send(
				 'X11.options(fonts = c('
				.'"-*-gothic-%s-%s-normal--%d-*-*-*-*-*-*-*",'
				.'"-adobe-symbol-*-*-*-*-%d-*-*-*-*-*-*-*"))'
			);
		}
		$::config_obj->R->send('options("bitmapType"="Xlib")'); # Mac��
		$::config_obj->R->output_chk(1);
		
		$if_font = 1;
	}

	# R�ΥС������2.5.0��꾮���������н�
	unless ($if_lt25){
		if ($::config_obj->R_version > 205){
			$if_lt25 = 1;
		} else {
			$::config_obj->R->output_chk(0);
			$::config_obj->R->send(
				'as.graphicsAnnot <- function(x) if (is.language(x) || !is.object(x)) x else as.character(x)'
			);
			$::config_obj->R->output_chk(1);
			$if_lt25 = 2;
			#print "as.graphicsAnnot defined.\n";
		}
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
	print "kh_r_plot::new lock ok.\n" if $debug;
	$self->{path} = $::config_obj->R_device(
		$self->{path},
		$self->{width},
		$self->{height},
	);
	print "kh_r_plot::new R.device ok.\n" if $debug;
	$self->set_par;
	print "kh_r_plot::new set_par ok.\n" if $debug;
	$::config_obj->R->send($command);
	print "kh_r_plot::new send ok.\n" if $debug;
	$self->{r_msg} = $::config_obj->R->read;
	print "kh_r_plot::new read ok.\n" if $debug;
	$::config_obj->R->send('dev.off()');
	print "kh_r_plot::new dev.off ok.\n" if $debug;
	$::config_obj->R->unlock;
	print "kh_r_plot::new unlock ok.\n" if $debug;
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
			window => \$::main_gui->mw,
			msg    =>
				"����ޤ�������˼��Ԥ��ޤ���\n\n"
				.Jcode->new($self->{r_msg})->euc
		);
		return 0;
	}
	
	# �ƥ����Ƚ���
	#my $txt = $self->{r_msg};
	#if ( length($txt) ){
	#	$txt = Jcode->new($txt)->sjis if $::config_obj->os eq 'win32';
	#	print "[Begin]--------------------------------------------------[R]\n";
	#	print "$txt\n";
	#	print "[End]----------------------------------------------------[R]\n";
	#}
	
	return $self;
}

sub clear_env{
	#$::config_obj->R->send('print( ls() )');
	#print "before: ", $::config_obj->R->read, "\n";

	$::config_obj->R->output_chk(0);
	$::config_obj->R->send("
		the_list <- ls()
		the_list <- the_list[substring(the_list,0,4) != \"PERL\"]
		if ( length(the_list) > 0 ){
			rm(list=the_list)
		}
		rm(the_list)
	");

	if ( $if_lt25 == 2 ){
		$::config_obj->R->send(
			'as.graphicsAnnot <- function(x) if (is.language(x) || !is.object(x)) x else as.character(x)'
		);
	}
	$::config_obj->R->output_chk(1);

	#$::config_obj->R->send('print( ls() )');
	#print "after: ", $::config_obj->R->read, "\n";

	#print "R env has been cleared.\n";
}

sub set_par{
	my $self = shift;
	$::config_obj->R->send(
		'par(mai=c(0,0,0,0), mar=c(4,4,1,1), omi=c(0,0,0,0), oma =c(0,0,0,0) )'
	);

	# ���ܸ�ʳ��ξ��ϡ�sans�ץե���Ȥ� # morpho_analyzer
	$::config_obj->R->output_chk(0);
	if (
		   $::project_obj->morpho_analyzer eq 'chasen'
		|| $::project_obj->morpho_analyzer eq 'mecab'
	) {
		$::config_obj->R->send("par(\"family\"=\"\")");
	} else {
		#print "family: sans\n";
		$::config_obj->R->send("par(\"family\"=\"sans\")");
	}
	$::config_obj->R->output_chk(1);

	return $self;
}

sub rotate_cls{
	my $self = shift;
	
	unless (eval 'require Image::Magick;'){
		print "Could not rotate the dendrogram: No Image-Magick.\n";
		return $self;
	}
	
	# temp�ե������̾��
	my $type = '';
	if ($self->{path} =~ /\.bmp$/){
		$type = 'bmp';
	} else {
		$type = 'png';
	}
	
	# temp�ե�����˥�͡���
	my $temp = "hoge";
	my $n = 0;
	while (-e "$temp$n.$type"){
		++$n;
	}
	$temp = "$temp$n.$type";
	rename($self->{path}, $temp);
	
	# �������
	my $p = Image::Magick->new;
	$p->Read($temp);
	$p->Rotate(degrees=>90);
	
	if ($self->{width} > 1000){
		# ����������ʬ�ڤ�Ф�
		$p->Crop(geometry=> "$self->{height}x41+0+0");
		
		# �����ڤ�Ф�
		$p->Read($temp);
		$p->[1]->Rotate(degrees=>90);
		my $start = int( $self->{width} * 0.033 + 33 - 10 );
		my $height = int( $self->{width} - $self->{width} * 0.033 +10)-$start;
		$p->[1]->Crop(geometry=> "$self->{height}x$height+0+$start");
		
		# Ž���碌
		$p = $p->append(stack => "true");
	}
	
	if ($type eq 'bmp'){ 
		$p->Write(filename=>"$temp", compression=>'None');
	} else {
		$p->Write($temp);
	}
	rename($temp, $self->{path});

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
	
	my $w = 7;
	if ($self->{width} > $self->{height}){
		$w = sprintf("%.5f", 7 * $self->{width} / $self->{height} );
	}
	
	# �ץ�åȺ���
	$::config_obj->R->output_chk(0);
	$::config_obj->R->lock;
	$::config_obj->R->send(
		 "win.metafile(filename=\"$path\", width = $w, height = 7 )"
	);
	$self->set_par;
	$::config_obj->R->send($self->{command_f});
	$::config_obj->R->send('dev.off()');
	$::config_obj->R->unlock;
	$::config_obj->R->output_chk(1);
	
	return 1;
}

sub _save_pdf{
	my $self = shift;
	my $path = shift;

	my $w = 7;
	if ($self->{width} > $self->{height}){
		$w = sprintf("%.5f", 7 * $self->{width} / $self->{height} );
	}

	# �ץ�åȺ���
	$::config_obj->R->output_chk(0);
	$::config_obj->R->lock;
	$::config_obj->R->send(
		 "pdf(file=\"$path\", height = 7, width = $w,"
		."family=\"Japan1GothicBBB\")"
	);
	$self->set_par;
	$::config_obj->R->send($self->{command_f});
	$::config_obj->R->send('dev.off()');
	$::config_obj->R->unlock;
	$::config_obj->R->output_chk(1);
	
	return 1;
}


sub _save_eps{
	my $self = shift;
	my $path = shift;

	my $w = 7;
	if ($self->{width} > $self->{height}){
		$w = sprintf("%.5f", 7 * $self->{width} / $self->{height} );
	}

	# �ץ�åȺ���
	$::config_obj->R->output_chk(0);
	$::config_obj->R->lock;
	$::config_obj->R->send(
		 "postscript(\"$path\", horizontal = FALSE, onefile = FALSE,"
		."paper = \"special\", height = 7, width = $w,"
		."family=\"Japan1GothicBBB\" )"
	);
	$self->set_par;
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
	$self->set_par;
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

#sub DESTROY{
#	my $self = shift;
#	print "DESTROYed: $self->{name}\n";
#}

1;