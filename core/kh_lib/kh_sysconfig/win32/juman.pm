package kh_sysconfig::juman;
use base qw(kh_sysconfig::win32);

sub config_morph{
	# �������̵��
}

sub path_check{
	my $self = shift;
	my $path = $self->juman_path;
	
	if (not (-e $path) or not ($path =~ /juman\.exe\Z/i) ){
		use gui_errormsg;
		gui_errormsg->open(
			type   => 'msg',
			window => \$gui_sysconfig::inis,
			msg    => "Juman.exe�Υѥ��������Ǥ�"
		);
		return 0;
	}
	return 1;
}


1;
__END__
