package kh_sysconfig::win32::stanford;
use base qw(kh_sysconfig::win32);

sub config_morph{
	# �������̵��
}

sub path_check{
	my $self = shift;
	return 1;

	if ( ! (
			   -e $::config_obj->os_path( $self->stanf_tagger_path )
			&& -e $::config_obj->os_path( $self->stanf_jar_path    )
		)){
		#gui_errormsg->open(
		#	type   => 'msg',
		#	window => \$gui_sysconfig::inis,
		#	msg    => kh_msg->get('path_error'),
		#);
		print "path error: stanford pos tagger\n";
		return 0;
	}
	
	return 1;
}


1;
__END__
