package gui_errormsg::file;
use strict;
use base qw(gui_errormsg);

sub get_msg{
	my $self = shift;
	my $msg = "�ե�����򳫤��ޤ���Ǥ�����\n";
	$msg .= "KH Coder��λ���ޤ���\n";
	$msg .= "�� ";
	Jcode::convert(\$msg,'sjis');
	$msg .= $self->{thefile};
	
	return $msg;
}

1;